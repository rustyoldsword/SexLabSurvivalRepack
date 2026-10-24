# Deploy the SL Survival integration patch to its MO2 mod folder (scripts only, no plugin).
# Run after build.ps1: powershell -ExecutionPolicy Bypass -File package.ps1
$ErrorActionPreference = 'Stop'
$root   = $PSScriptRoot
$deploy = 'C:\Modding\MO2\mods\SL Survival - Patches'  # merged folder: only Scripts\ and the integration doc are managed here

$sources = Get-ChildItem (Join-Path $root 'src') -Filter *.psc
foreach ($s in $sources) {
    $pex = Join-Path $root "out\$($s.BaseName).pex"
    if (-not (Test-Path $pex)) { throw "missing $pex - run build.ps1" }
    if ((Get-Item $pex).LastWriteTime -lt $s.LastWriteTime) { throw "$($s.BaseName).pex is older than its source - run build.ps1" }
}

New-Item -ItemType Directory -Force $deploy | Out-Null
Remove-Item -Recurse -Force "$deploy\Scripts" -ErrorAction SilentlyContinue  # textures/json of the merged folder stay untouched
New-Item -ItemType Directory -Force "$deploy\Scripts\Source" | Out-Null
foreach ($s in $sources) {
    Copy-Item (Join-Path $root "out\$($s.BaseName).pex") "$deploy\Scripts\"
    Copy-Item $s.FullName "$deploy\Scripts\Source\"
}
Copy-Item (Join-Path $root 'README.md') "$deploy\SL Survival - Integration Patch.md"
$files = Get-ChildItem "$deploy\Scripts" -Recurse -File
if ($files.Count -ne 2 * $sources.Count) { throw "expected $(2 * $sources.Count) script files, deployed $($files.Count)" }
"deployed $($sources.Count) scripts to $deploy"
