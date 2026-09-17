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
    [string]$Flavor = "_beta_",
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
$dataDir = Join-Path $repo "data"
New-Item -ItemType Directory -Force -Path $dataDir | Out-Null

foreach ($f in $found) {
    $suffix = if ($Label) { "_$Label" } else { "" }
    $target = Join-Path $dataDir "$Addon`_$stamp$suffix.lua"
    Copy-Item $f.FullName $target -Force
    $kb = [math]::Round($f.Length / 1KB, 1)
    Write-Host "Collected $($f.FullName) ($kb KB)" -ForegroundColor Green
    Write-Host "       -> $target" -ForegroundColor Green
}

Write-Host ""
Write-Host "Quick look at what was captured:" -ForegroundColor Cyan
$content = Get-Content $target -Raw
foreach ($key in @("tocversion", "maskedReads", "flatBan", "combatOnly", "C_AuctionHouse", "C_AssistedCombat")) {
    $hit = if ($content -match [regex]::Escape($key)) { "present" } else { "not found" }
    Write-Host ("  {0,-18} {1}" -f $key, $hit)
}
Write-Host ""
Write-Host "Hand the file in data/ to Claude for analysis." -ForegroundColor Cyan
