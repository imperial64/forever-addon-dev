<#
.SYNOPSIS
  Seed a differently-tokenised probe file into every candidate SavedVariables
  path at once, so the in-game probe can report which one the client actually
  reads back at load.

.DESCRIPTION
  Reports from other developers disagree about which SavedVariables path the
  Forever client reads. Rather than guess, this writes a small, harmless
  ForeverProbeSeed table - never the addon's real DB global, so the live
  capture is never touched - to each of the four candidate locations, each
  with its own unique token. Start the client (or /reload), then run
  /fprobe sv in game: whichever token comes back names the real path.

  Account, realm and character names are discovered by walking the existing
  WTF\Account directory tree. If a needed level cannot be found, that
  candidate is skipped rather than guessed.

.EXAMPLE
  .\scripts\seed-savedvars.ps1
  .\scripts\seed-savedvars.ps1 -WowRoot "D:\Games\World of Warcraft"
  .\scripts\seed-savedvars.ps1 -Restore
#>
[CmdletBinding()]
param(
    [string]$WowRoot,
    [string]$Flavor = "_classic_beta_",
    [string]$Addon  = "ForeverProbe",
    [switch]$Restore
)

$ErrorActionPreference = "Stop"

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

$flavorRoot = Join-Path $WowRoot $Flavor
$accountRoot = Join-Path $flavorRoot "WTF\Account"

# Discover account / realm / character by walking the existing tree. An
# account folder is any child of WTF\Account that isn't "SavedVariables".
# Realm and character are the two directory levels below that.
$account = $null
$realm = $null
$character = $null

if (Test-Path $accountRoot) {
    $accountDir = Get-ChildItem -Path $accountRoot -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -ne "SavedVariables" } |
        Select-Object -First 1
    if ($accountDir) {
        $account = $accountDir.Name
        $realmDir = Get-ChildItem -Path $accountDir.FullName -Directory -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -ne "SavedVariables" } |
            Select-Object -First 1
        if ($realmDir) {
            $realm = $realmDir.Name
            $characterDir = Get-ChildItem -Path $realmDir.FullName -Directory -ErrorAction SilentlyContinue |
                Where-Object { $_.Name -ne "SavedVariables" } |
                Select-Object -First 1
            if ($characterDir) {
                $character = $characterDir.Name
            }
        }
    }
}

# Build the candidate list. Each entry needs the discovered pieces it
# depends on; a candidate whose pieces are missing is skipped below.
$candidateDefs = @()

if ($account) {
    $candidateDefs += [pscustomobject]@{
        Label = "account-scoped"
        Path  = Join-Path $flavorRoot "WTF\Account\$account\SavedVariables\$Addon.lua"
    }
}
$candidateDefs += [pscustomobject]@{
    Label = "account-root"
    Path  = Join-Path $flavorRoot "WTF\Account\SavedVariables\$Addon.lua"
}
$candidateDefs += [pscustomobject]@{
    Label = "wtf-root"
    Path  = Join-Path $flavorRoot "WTF\SavedVariables\$Addon.lua"
}
if ($account -and $realm -and $character) {
    $candidateDefs += [pscustomobject]@{
        Label = "per-character"
        Path  = Join-Path $flavorRoot "WTF\Account\$account\$realm\$character\SavedVariables\$Addon.lua"
    }
} else {
    Write-Host "Skipping per-character: could not discover a full account/realm/character path under $accountRoot" -ForegroundColor Yellow
}
if (-not $account) {
    Write-Host "Skipping account-scoped: could not discover an account folder under $accountRoot" -ForegroundColor Yellow
}

$globalName = "${Addon}Seed"

if ($Restore) {
    Write-Host "Restoring seeded SavedVariables files..." -ForegroundColor Cyan
    foreach ($c in $candidateDefs) {
        $bak = "$($c.Path).bak"
        if (Test-Path $bak) {
            Move-Item -Path $bak -Destination $c.Path -Force
            Write-Host ("  {0,-16} {1} - restored from backup" -f $c.Label, $c.Path) -ForegroundColor Green
        } elseif (Test-Path $c.Path) {
            $body = Get-Content $c.Path -Raw
            if ($body -match [regex]::Escape($globalName)) {
                Remove-Item $c.Path -Force
                Write-Host ("  {0,-16} {1} - removed seed file (no backup existed)" -f $c.Label, $c.Path) -ForegroundColor Green
            } else {
                Write-Host ("  {0,-16} {1} - left alone (does not look like a seed file)" -f $c.Label, $c.Path) -ForegroundColor Yellow
            }
        } else {
            Write-Host ("  {0,-16} {1} - nothing to restore" -f $c.Label, $c.Path) -ForegroundColor DarkGray
        }
    }
    return
}

$stamp = (Get-Date).ToString("yyyyMMdd-HHmmss")
$written = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")

Write-Host "Seeding $globalName into $($candidateDefs.Count) candidate path(s)..." -ForegroundColor Cyan
Write-Host ""

foreach ($c in $candidateDefs) {
    $suffix = "{0:D4}" -f (Get-Random -Minimum 0 -Maximum 10000)
    $token = "seed-$stamp-$suffix"

    $status = "created"
    $parent = Split-Path -Parent $c.Path
    if (-not (Test-Path $parent)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }
    if (Test-Path $c.Path) {
        $bak = "$($c.Path).bak"
        Copy-Item -Path $c.Path -Destination $bak -Force
        $status = "overwritten (backed up to $(Split-Path -Leaf $bak))"
    }

    $lua = @"
$globalName = {
    ["path"] = "$($c.Label)",
    ["token"] = "$token",
    ["written"] = "$written",
}
"@

    [System.IO.File]::WriteAllText($c.Path, $lua, (New-Object System.Text.UTF8Encoding($false)))

    Write-Host ("  {0,-16} {1}" -f $c.Label, $c.Path) -ForegroundColor Green
    Write-Host ("    token: {0}" -f $token)
    Write-Host ("    status: {0}" -f $status)
}

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Start the client (or /reload if it's already running)."
Write-Host "  2. Run /fprobe sv in game - it reports which token arrived, naming the real path."
Write-Host "  3. Once settled, run .\scripts\seed-savedvars.ps1 -Restore to put things back."
