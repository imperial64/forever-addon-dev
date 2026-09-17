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

# Syntax-gate the install. A Lua parse error means the addon never loads and
# /fprobe is simply not there in game, which is a slow and confusing way to find
# out. LuaJIT is preferred: it parses Lua 5.1, which is what WoW runs. luac 5.4
# is a usable second choice - it accepts everything 5.1 does and a little more.
$luajit = Get-Command luajit -ErrorAction SilentlyContinue
$luac   = Get-Command luac   -ErrorAction SilentlyContinue
if ($luajit -or $luac) {
    $checker = if ($luajit) { "luajit (5.1)" } else { "luac (5.4)" }
    foreach ($file in Get-ChildItem $src -Filter *.lua -Recurse) {
        if ($luajit) { & $luajit.Source -bl $file.FullName | Out-Null }
        else         { & $luac.Source -p $file.FullName }
        if ($LASTEXITCODE -ne 0) { Write-Error "Lua syntax error in $($file.Name) - not installing." }
    }
    Write-Host "Lua syntax OK ($checker)" -ForegroundColor Green
} else {
    Write-Host "No lua/luajit on PATH - skipping the syntax check. Install with: winget install DEVCOM.LuaJIT" -ForegroundColor Yellow
}

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
