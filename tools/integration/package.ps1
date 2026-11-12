# Deploy the SL Survival integration patch to its MO2 mod folder (scripts only, no plugin).
# Run after build.ps1: powershell -ExecutionPolicy Bypass -File package.ps1
$ErrorActionPreference = 'Stop'
$root   = $PSScriptRoot
$deploy = 'C:\Modding\MO2\mods\SexLab Survival Repack'  # the merged SLS mod (RUS-142): only our scripts + the doc are written

# the framework ships its own build of some of these (_SLS_TollUtil, _SLS_IntSlsfw, _SLS_IntCcs): before the merge its
# folder won over ours, now its package.ps1 owns those files in the merged mod and we must not overwrite them
$framework = (Get-ChildItem 'C:\Modding\MO2\work\SLSFramework\papyrus\source' -Filter *.psc).BaseName
$sources = Get-ChildItem (Join-Path $root 'src') -Filter *.psc | Where-Object { $framework -notcontains $_.BaseName }
foreach ($s in $sources) {
    $pex = Join-Path $root "out\$($s.BaseName).pex"
    if (-not (Test-Path $pex)) { throw "missing $pex - run build.ps1" }
    if ((Get-Item $pex).LastWriteTime -lt $s.LastWriteTime) { throw "$($s.BaseName).pex is older than its source - run build.ps1" }
}

if (-not (Test-Path "$deploy\Scripts\Source")) { throw "$deploy is not the merged SLS mod" }
# Scripts\ also holds stock SLS, the framework's and the escorts' scripts: overwrite only ours, never clear the folder
foreach ($s in $sources) {
    $pex = Join-Path $root "out\$($s.BaseName).pex"
    Copy-Item $pex "$deploy\Scripts\"
    Copy-Item $s.FullName "$deploy\Scripts\Source\"
    if ((Get-FileHash $pex).Hash -ne (Get-FileHash "$deploy\Scripts\$($s.BaseName).pex").Hash) { throw "copy failed: $($s.BaseName).pex" }
}
Copy-Item (Join-Path $root 'README.md') "$deploy\docs\SL Survival - Integration Patch__README.md"
"deployed $($sources.Count) scripts to $deploy"
