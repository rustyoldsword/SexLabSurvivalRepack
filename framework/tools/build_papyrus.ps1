# Compile the framework's Papyrus scripts: SLSFW.psc and the SLS scripts whose bodies it changes.
# Import order: papyrus\source (ours) -> SLS_integration\src (the shipped "SL Survival - Patches" winners) -> its stubs ->
# the crajjjj 0.716 repo's ppj import list (SLS sources and bundled dependencies) -> game SKSE + vanilla sources.
#
# Run: powershell -ExecutionPolicy Bypass -File tools\build_papyrus.ps1 [-Targets a,b]
param([string[]]$Targets)
$ErrorActionPreference = 'Stop'

$root     = Split-Path -Parent $PSScriptRoot
$srcDir   = Join-Path $root 'papyrus\source'
$outDir   = Join-Path $root 'papyrus\out'
$integ    = 'C:\Modding\MO2\work\SLS_integration'
$slsRepo  = Join-Path $integ 'sls_repo'
$compiler = 'C:\Modding\MO2\basegame\Papyrus Compiler\PapyrusCompiler.exe'
$skse     = 'C:\Modding\MO2\basegame\Data\Scripts\Source'
$vanilla  = 'C:\Modding\MO2\basegame\Data\Source\Scripts'
$wfng     = 'C:\Modding\MO2\work\WetFunctionNG\papyrus\source'
$smi      = 'C:\Modding\MO2\mods\Survival Mode Improved - SKSE\Source\Scripts'  # SurvivalModeImprovedApi (import only)

New-Item -ItemType Directory -Force $outDir | Out-Null

[xml]$ppj = Get-Content (Join-Path $slsRepo 'skyrimse.ppj')
$imports = foreach ($i in $ppj.PapyrusProject.Imports.Import) {
    $v = [string]$i
    if ($v -eq '@ImportsFolder') { Join-Path $slsRepo 'scripts\source' }
    elseif ($v -eq '@SkyrimScripts') { $skse; $vanilla }
    else { Join-Path $slsRepo ($v -replace '^\.\\', '') }
}
$importList = @($srcDir, (Join-Path $integ 'src'), (Join-Path $integ 'stubs'), $wfng, $smi) + $imports
$importArg = ($importList | Where-Object { Test-Path $_ }) -join ';'

$Targets = @($Targets | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$files = if ($Targets) { $Targets | ForEach-Object { Get-Item (Join-Path $srcDir "$_.psc") } } else { Get-ChildItem $srcDir -Filter *.psc }

# the compiler also searches its working directory - never run it from inside a source folder
Push-Location $env:TEMP
$failed = @()
try {
    foreach ($f in $files) {
        $ErrorActionPreference = 'Continue'  # the compiler writes warnings to stderr
        $log = & $compiler $f.FullName -f='TESV_Papyrus_Flags.flg' -i="$importArg" -o="$outDir" 2>&1 | Out-String
        $ErrorActionPreference = 'Stop'
        $pex = Join-Path $outDir ($f.BaseName + '.pex')
        # a failed compile leaves the old .pex in place: require it to be newer than its source
        if (($log -match '(\d+) error' -and $Matches[1] -ne '0') -or -not (Test-Path $pex) -or (Get-Item $pex).LastWriteTime -lt $f.LastWriteTime) {
            $failed += $f.Name
            Write-Host "FAIL $($f.Name)"
            $log -split "`n" | Where-Object { $_ -match 'error|\(\d+,\d+\)' } | Select-Object -First 25 | ForEach-Object { "    $_" }
        } else {
            Write-Host "ok   $($f.Name)"
        }
    }
} finally { Pop-Location }
if ($failed) { throw "failed: $($failed -join ', ')" }
