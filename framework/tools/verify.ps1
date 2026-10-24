# Check an installed SexLab Survival Framework against its manifest (docs\SexLab Survival Framework__manifest.json):
# every listed file present with the same SHA-256, and which of them another mod overrides in MO2.
#
# Run: powershell -ExecutionPolicy Bypass -File tools\verify.ps1 [-ModDir <mod folder>] [-ModsRoot <MO2 mods>] [-Profile <modlist.txt>]
param(
    [string]$ModDir = 'C:\Modding\MO2\mods\SexLab Survival Framework',
    [string]$ModsRoot = 'C:\Modding\MO2\mods',
    [string]$Profile = 'C:\Modding\MO2\profiles\Default\modlist.txt'
)
$ErrorActionPreference = 'Stop'

$manifestPath = Join-Path $ModDir 'docs\SexLab Survival Framework__manifest.json'
if (-not (Test-Path $manifestPath)) { throw "no manifest at $manifestPath" }
$manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
"$($manifest.name) $($manifest.version): $($manifest.files.Count) files"

$missing = @(); $changed = @()
foreach ($entry in $manifest.files) {
    $path = Join-Path $ModDir $entry.path
    if ($entry.path -like '*__manifest.json') { continue }
    if (-not (Test-Path $path)) {
        # the FOMOD options (tuned SteepFall.json, TNG SkyPatcher patch) may be left out on purpose
        if ($entry.path -like 'SKSE\Plugins\StorageUtilData\*' -or $entry.path -like 'SKSE\Plugins\SkyPatcher\*') { "  optional, not installed: $($entry.path)" }
        else { $missing += $entry.path }
        continue
    }
    if ((Get-FileHash $path -Algorithm SHA256).Hash -ne $entry.sha256) { $changed += $entry.path }
}

# MO2: enabled mods above ours (listed earlier in modlist.txt = higher priority) that ship the same file
$overridden = @()
if (Test-Path $Profile) {
    $self = Split-Path $ModDir -Leaf
    $above = @()
    foreach ($line in Get-Content $Profile) {
        if (-not $line.StartsWith('+')) { continue }
        $mod = $line.Substring(1)
        if ($mod -eq $self) { break }
        $above += $mod
    }
    foreach ($entry in $manifest.files) {
        if ($entry.path -like 'docs\*') { continue }
        foreach ($mod in $above) {
            if (Test-Path (Join-Path (Join-Path $ModsRoot $mod) $entry.path)) { $overridden += "$($entry.path)  <-  $mod"; break }
        }
    }
}

if ($missing) { 'MISSING:'; $missing | ForEach-Object { "  $_" } }
if ($changed) { 'CHANGED (hash differs):'; $changed | ForEach-Object { "  $_" } }
if ($overridden) { 'OVERRIDDEN in MO2 (another mod wins the file):'; $overridden | ForEach-Object { "  $_" } }
if (-not ($missing -or $changed -or $overridden)) { 'OK: every file present, unchanged and winning' }
