<#
.SYNOPSIS
  Copy ForeverProbe and its two SavedVariables companions from this repo into the
  WoW Forever beta AddOns folder.

.DESCRIPTION
  By default installs three addons: ForeverProbe, plus ForeverProbeSV_First and
  ForeverProbeSV_Late, the cold-start companions that differ only by
  `## LoadSavedVariablesFirst: 1` (research/test-plan-70009.md). Pass -Addon to
  install a subset.

.EXAMPLE
  .\scripts\install-addon.ps1
  .\scripts\install-addon.ps1 -Addon ForeverProbe
  .\scripts\install-addon.ps1 -WowRoot "D:\Games\World of Warcraft" -Flavor _beta_
#>
[CmdletBinding()]
param(
    [string]$WowRoot,
    [string]$Flavor = "_classic_beta_",
    [string[]]$Addon = @("ForeverProbe", "ForeverProbeSV_First", "ForeverProbeSV_Late"),
    [switch]$ResetExternalData
)

$ErrorActionPreference = "Stop"
$repo = Split-Path -Parent $PSScriptRoot

# Locate the WoW install if not given.
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
    Write-Error "Could not find the WoW install. Pass -WowRoot explicitly, e.g. -WowRoot 'D:\Games\World of Warcraft'"
}

$flavorPath = Join-Path $WowRoot $Flavor
if (-not (Test-Path $flavorPath)) {
    Write-Host "Flavor folder '$Flavor' not found under $WowRoot. Available:" -ForegroundColor Yellow
    Get-ChildItem $WowRoot -Directory | Where-Object { $_.Name -like "_*_" } | ForEach-Object { "  $($_.Name)" }
    Write-Error "Pass the right one with -Flavor"
}

# The two companions share Core.lua byte for byte; only the .toc directive and
# the literal names in Init.lua differ. A drifted copy would make the with/without
# comparison measure two different programs, so refuse rather than warn.
$first = Join-Path $repo "addons\ForeverProbeSV_First\Core.lua"
$late  = Join-Path $repo "addons\ForeverProbeSV_Late\Core.lua"
if (($Addon -contains "ForeverProbeSV_First") -and ($Addon -contains "ForeverProbeSV_Late")) {
    if ((Get-FileHash $first).Hash -ne (Get-FileHash $late).Hash) {
        Write-Error "addons\ForeverProbeSV_First\Core.lua and addons\ForeverProbeSV_Late\Core.lua differ. Copy one over the other before installing."
    }
}

# Syntax-gate the install. A Lua parse error means the addon never loads and
# /fprobe is simply not there in game, which is a slow and confusing way to find
# out. LuaJIT is preferred: it parses Lua 5.1, which is what WoW runs. luac 5.4
# is a usable second choice - it accepts everything 5.1 does and a little more.
$luajit = Get-Command luajit -ErrorAction SilentlyContinue
$luac   = Get-Command luac   -ErrorAction SilentlyContinue

foreach ($name in $Addon) {
    $src = Join-Path $repo "addons\$name"
    if (-not (Test-Path $src)) { Write-Error "Addon source not found: $src" }

    if ($luajit -or $luac) {
        $checker = if ($luajit) { "luajit (5.1)" } else { "luac (5.4)" }
        foreach ($file in Get-ChildItem $src -Filter *.lua -Recurse) {
            if ($luajit) { & $luajit.Source -bl $file.FullName | Out-Null }
            else         { & $luac.Source -p $file.FullName }
            if ($LASTEXITCODE -ne 0) { Write-Error "Lua syntax error in $name\$($file.Name) - not installing." }
        }
        Write-Host "$name - Lua syntax OK ($checker)" -ForegroundColor Green
    } else {
        Write-Host "No lua/luajit on PATH - skipping the syntax check. Install with: winget install DEVCOM.LuaJIT" -ForegroundColor Yellow
    }

    $dest = Join-Path $flavorPath "Interface\AddOns\$name"
    New-Item -ItemType Directory -Force -Path $dest | Out-Null

    # ExternalData.lua is the inbound channel, not source: write-external-data.ps1 owns
    # the installed copy, and reinstalling would silently wipe a payload that is
    # mid-test. Preserve whatever is there unless -ResetExternalData is passed.
    $externalData = Join-Path $dest "ExternalData.lua"
    $keepExternalData = $null
    if ((Test-Path $externalData) -and -not $ResetExternalData) {
        $keepExternalData = [System.IO.File]::ReadAllText($externalData)
    }

    Copy-Item -Path (Join-Path $src "*") -Destination $dest -Recurse -Force

    if ($keepExternalData) {
        [System.IO.File]::WriteAllText($externalData, $keepExternalData, (New-Object System.Text.UTF8Encoding($false)))
        Write-Host "Kept the installed ExternalData.lua (-ResetExternalData to overwrite it)" -ForegroundColor Yellow
    }

    Write-Host "Installed $name -> $dest" -ForegroundColor Green
}

Write-Host ""
Write-Host "Next:" -ForegroundColor Cyan
Write-Host "  0. For the build 70009 session, follow research/test-plan-70009.md step by step instead."
Write-Host "  1. The .toc files declare 16001, the interface number measured on build 1.60.1.69893."
Write-Host "     If /fprobe is missing, check 'Load out of date AddOns' and correct the number from /fprobe's output."
Write-Host "  2. On the character screen, AddOns: ForeverProbe, ForeverProbeSV_First and ForeverProbeSV_Late enabled."
Write-Host "  3. In game, out of combat:  /fprobe"
Write-Host "  4. At an auction house:     /fprobe ah, then /fprobe ah browse (free), then"
Write-Host "                              /fprobe ah scan (burns the 15 min throttle), stay logged"
Write-Host "                              in, then /fprobe ah throttle"
Write-Host "  5. Pull a mob, then:        /fprobe combat"
Write-Host "  6. External data test:      .\scripts\write-external-data.ps1, then /reload and /fprobe external"
Write-Host "  7. /reload, then run:       .\scripts\collect-savedvars.ps1"
Write-Host ""
Write-Host "Note: SavedVariables read-back was broken through build 69977 (findings P.23, P.27) and is" -ForegroundColor Yellow
Write-Host "      reported fixed in 70009 (watch-findings W.32), not yet measured here. /fprobe cold" -ForegroundColor Yellow
Write-Host "      with the two companions is the measurement." -ForegroundColor Yellow
