# Assemble the "SexLab Survival Framework" mod: dist\SexLab Survival Framework\ (Data layout), deploy it to the
# MO2 mod folder (replacing only our own files) and pack a versioned .7z.
# Run after: xmake build SLSurvivalFramework; tools\build_papyrus.ps1
#
# Run: powershell -ExecutionPolicy Bypass -File tools\package.ps1 [-NoArchive]
param([switch]$NoArchive)
$ErrorActionPreference = 'Stop'

$root    = Split-Path -Parent $PSScriptRoot
$name    = 'SexLab Survival Framework'
$version = (Select-String -Path (Join-Path $root 'xmake.lua') -Pattern 'set_version\("([^"]+)"\)').Matches[0].Groups[1].Value
$stage   = Join-Path $root "dist\$name"
$archive = Join-Path $root "dist\$name $version.7z"
$deploy  = "C:\Modding\MO2\mods\$name"

if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }
New-Item -ItemType Directory -Force "$stage\SKSE\Plugins", "$stage\Scripts\Source", "$stage\docs" | Out-Null

$build = Join-Path $root 'build\windows\x64\releasedbg'
Copy-Item "$build\SLSurvivalFramework.dll", "$build\SLSurvivalFramework.pdb" "$stage\SKSE\Plugins\"
# every shipped script must be compiled from the source shipped beside it
foreach ($psc in Get-ChildItem (Join-Path $root 'papyrus\source') -Filter *.psc) {
    $pex = Join-Path $root "papyrus\out\$($psc.BaseName).pex"
    if (-not (Test-Path $pex) -or (Get-Item $pex).LastWriteTime -lt $psc.LastWriteTime) { throw "stale or missing $pex - run build_papyrus.ps1" }
    Copy-Item $pex "$stage\Scripts\"
    Copy-Item $psc.FullName "$stage\Scripts\Source\"
}
Copy-Item (Join-Path $root "docs\$name`__README.md") "$stage\docs\"
# loose data overrides (SKSE\Plugins\StorageUtilData\...): our tuned copies of SLS JSON
Copy-Item (Join-Path $root 'data\*') $stage -Recurse -Force

$files = Get-ChildItem $stage -Recurse -File
$files | Select-Object @{ n = 'file'; e = { $_.FullName.Substring($stage.Length) } }, Length | Format-Table -AutoSize | Out-String -Width 200

# deploy: replace our own files only; keep meta.ini and anything MO2 put there
New-Item -ItemType Directory -Force $deploy | Out-Null
$locked = @()
foreach ($f in $files) {
    $dst = Join-Path $deploy $f.FullName.Substring($stage.Length + 1)
    New-Item -ItemType Directory -Force (Split-Path $dst) | Out-Null
    try { Copy-Item $f.FullName $dst -Force -ErrorAction Stop }
    catch [System.IO.IOException] { $locked += $f.FullName.Substring($stage.Length + 1) }  # the running game holds the DLL
}
if ($locked) { Write-Warning "not deployed (in use - close the game and re-run): $($locked -join ', ')" }
if (-not (Test-Path "$deploy\meta.ini")) {
    Set-Content "$deploy\meta.ini" "[General]`r`nmodid=0`r`nversion=$version`r`ninstalled=true`r`n" -Encoding ascii
}
"deployed to $deploy"

# manifest: every deployed file with its size and SHA-256 (tools/verify.ps1 checks an installed copy against it)
$manifest = [ordered]@{ name = $name; version = $version; files = @() }
foreach ($f in $files | Sort-Object FullName) {
    $manifest.files += [ordered]@{ path = $f.FullName.Substring($stage.Length + 1); size = $f.Length; sha256 = (Get-FileHash $f.FullName -Algorithm SHA256).Hash }
}
$manifestJson = $manifest | ConvertTo-Json -Depth 4
Set-Content (Join-Path $stage 'docs\SexLab Survival Framework__manifest.json') $manifestJson -Encoding utf8
Set-Content (Join-Path $deploy 'docs\SexLab Survival Framework__manifest.json') $manifestJson -Encoding utf8
"manifest: $($manifest.files.Count) files"

if (-not $NoArchive) {
    # FOMOD layout: 00 Core (DLL, scripts, docs), 10 SteepFall (tuned JSON), 20 TNG (SkyPatcher ini)
    $release = Join-Path $root 'dist\release'
    if (Test-Path $release) { Remove-Item $release -Recurse -Force }
    $core = Join-Path $release '00 Core'
    Copy-Item $stage $core -Recurse
    $optional = @{ '10 SteepFall' = 'SKSE\Plugins\StorageUtilData'; '20 TNG' = 'SKSE\Plugins\SkyPatcher' }
    foreach ($option in $optional.GetEnumerator()) {
        $from = Join-Path $core $option.Value
        $to = Join-Path (Join-Path $release $option.Key) $option.Value
        New-Item -ItemType Directory -Force (Split-Path $to) | Out-Null
        Move-Item $from $to
    }
    $fomod = Join-Path $release 'fomod'
    New-Item -ItemType Directory -Force $fomod | Out-Null
    (Get-Content (Join-Path $root 'fomod\info.xml') -Raw).Replace('@VERSION@', $version) | Set-Content (Join-Path $fomod 'info.xml') -Encoding utf8
    Copy-Item (Join-Path $root 'fomod\ModuleConfig.xml') $fomod
    # the archive ships without the debug symbols
    Remove-Item (Join-Path $core 'SKSE\Plugins\SLSurvivalFramework.pdb') -ErrorAction SilentlyContinue

    $7z = 'C:\Program Files\7-Zip\7z.exe'
    if (Test-Path $archive) { Remove-Item $archive }
    Push-Location $release
    & $7z a -t7z -mx=9 $archive * | Out-Null
    Pop-Location
    "archive: $archive"
}
