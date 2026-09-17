<#
.SYNOPSIS
  Copy ForeverProbe from this repo into the WoW Forever beta AddOns folder.

.EXAMPLE
  .\scripts\install-addon.ps1
  .\scripts\install-addon.ps1 -WowRoot "D:\Games\World of Warcraft" -Flavor _beta_
#>
[CmdletBinding()]
param(
    [string]$WowRoot,
    [string]$Flavor = "_beta_",
    [string]$Addon  = "ForeverProbe"
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

$src = Join-Path $repo "addons\$Addon"
if (-not (Test-Path $src)) { Write-Error "Addon source not found: $src" }

$dest = Join-Path $flavorPath "Interface\AddOns\$Addon"
New-Item -ItemType Directory -Force -Path $dest | Out-Null
Copy-Item -Path (Join-Path $src "*") -Destination $dest -Recurse -Force

Write-Host "Installed $Addon -> $dest" -ForegroundColor Green
Write-Host ""
Write-Host "Next:" -ForegroundColor Cyan
Write-Host "  1. At the character screen, enable 'Load out of date AddOns' (the .toc interface number is a guess)."
Write-Host "  2. In game, out of combat:  /fprobe"
Write-Host "  3. Pull a mob, then:        /fprobe combat"
Write-Host "  4. /reload, then run:       .\scripts\collect-savedvars.ps1"
