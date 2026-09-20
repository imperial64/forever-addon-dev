<#
.SYNOPSIS
  Pull ForeverProbe SavedVariables out of the WoW install into this repo's data/ folder,
  timestamped so successive runs can be diffed.

.EXAMPLE
  .\scripts\collect-savedvars.ps1
  .\scripts\collect-savedvars.ps1 -WowRoot "D:\Games\World of Warcraft" -Label "post-patch"
#>
[CmdletBinding()]
param(
    [string]$WowRoot,
    [string]$Flavor = "_classic_beta_",
    [string]$Addon  = "ForeverProbe",
    [string]$Label
)

$ErrorActionPreference = "Stop"
$repo = Split-Path -Parent $PSScriptRoot

if (-not $WowRoot) {
    $candidates = @(
        "C:\Program Files (x86)\World of Warcraft",
        "C:\Program Files\World of Warcraft",
        "D:\World of Warcraft",
        "D:\Games\World of Warcraft",
        "E:\World of Warcraft",
        "F:\World of Warcraft",
        "F:\Games\World of Warcraft"
    )
    $WowRoot = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
}
if (-not $WowRoot -or -not (Test-Path $WowRoot)) {
    Write-Error "Could not find the WoW install. Pass -WowRoot explicitly."
}

$wtf = Join-Path $WowRoot "$Flavor\WTF\Account"
if (-not (Test-Path $wtf)) { Write-Error "No WTF/Account folder at $wtf" }

$found = Get-ChildItem -Path $wtf -Recurse -Filter "$Addon.lua" -ErrorAction SilentlyContinue
if (-not $found) {
    Write-Error "No $Addon.lua found. Did you /reload or log out after running /fprobe? SavedVariables only flush then."
}

$stamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
$dataDir = Join-Path $repo "research\captures"
New-Item -ItemType Directory -Force -Path $dataDir | Out-Null

$targets = @()

foreach ($f in $found) {
    $suffix = if ($Label) { "_$Label" } else { "" }

    # The addon now ships both ## SavedVariables and ## SavedVariablesPerCharacter,
    # so the client writes two files that share the same leaf name. Building the
    # destination from $Addon/$stamp/$Label alone made both resolve to one path,
    # and the second copy silently clobbered the first - a collector that quietly
    # throws away half of what it collected is the worst failure mode available
    # to it. Disambiguate by where the file actually came from instead.
    $relPath = $f.FullName.Substring($wtf.Length).TrimStart('\')
    $relParts = $relPath -split '\\'
    # Expected shapes relative to WTF\Account:
    #   <account>\SavedVariables\<file>                       -> account-wide (3 parts)
    #   <account>\<realm>\<character>\SavedVariables\<file>   -> per-character (5 parts)
    if ($relParts.Count -eq 3 -and $relParts[1] -eq "SavedVariables") {
        $scopeSuffix = ""
    } elseif ($relParts.Count -eq 5 -and $relParts[3] -eq "SavedVariables") {
        $character = $relParts[2]
        $safeCharacter = ($character -replace '[^A-Za-z0-9_-]', '-')
        $scopeSuffix = "_$safeCharacter"
    } else {
        $relDir = Split-Path -Parent $relPath
        $safeDir = ($relDir -replace '[\\/]', '-')
        $scopeSuffix = "_$safeDir"
    }

    $target = Join-Path $dataDir "$Addon`_$stamp$suffix$scopeSuffix.lua"

    # Guard against any remaining collision (e.g. two characters sanitising to the
    # same name) so a silent overwrite is never reachable, no matter what.
    if (Test-Path $target) {
        $base = [System.IO.Path]::GetFileNameWithoutExtension($target)
        $ext = [System.IO.Path]::GetExtension($target)
        $n = 2
        do {
            $candidate = Join-Path $dataDir "$base`_$n$ext"
            $n++
        } while (Test-Path $candidate)
        Write-Host "  WARNING: destination $target already exists - collision between $($f.FullName) and a previous source. Writing to $candidate instead." -ForegroundColor Red
        $target = $candidate
    }

    Copy-Item $f.FullName $target -Force
    $targets += $target
    $kb = [math]::Round($f.Length / 1KB, 1)
    Write-Host "Collected $($f.FullName) ($kb KB)" -ForegroundColor Green
    if ($f.Length -gt 1MB) {
        # The API documentation dump is the only thing here that runs to megabytes.
        # A truncated flush is the failure mode worth catching now rather than
        # halfway through the generator, so check the file actually closed.
        $tail = Get-Content $f.FullName -Tail 3 | Out-String
        if ($tail -notmatch '\}') {
            Write-Host "  WARNING: file does not end in a closing brace - the flush may be truncated." -ForegroundColor Red
            Write-Host "  Re-dump in passes: /fprobe docs dump 1 100, /reload, collect, then 101 100." -ForegroundColor Red
        } else {
            Write-Host "  Large capture, closes cleanly." -ForegroundColor Green
        }
    }
    Write-Host "       -> $target" -ForegroundColor Green
}

Write-Host ""
Write-Host "Quick look at what was captured:" -ForegroundColor Cyan
foreach ($target in $targets) {
    Write-Host "  $target" -ForegroundColor Cyan
    $content = Get-Content $target -Raw
    foreach ($key in @("tocversion", "maskedReads", "flatBan", "combatOnly", "secrecyDelta",
                       "C_AuctionHouse", "C_AssistedCombat", "C_Secrets", "C_EncodingUtil",
                       "registerFailures", "apiDocs", "apiDocsProbe")) {
        $hit = if ($content -match [regex]::Escape($key)) { "present" } else { "not found" }
        Write-Host ("    {0,-18} {1}" -f $key, $hit)
    }
}
Write-Host ""
Write-Host "The capture in research/captures/ is the input to tools/build_reference.py." -ForegroundColor Cyan
