# Compile the dialogue fragment scripts of SL Survival - Hopeless Escorts Dialogue.esp (scripts\ -> scripts_out\).
# Imports: these fragments, the SL Survival integration patch sources (_SLSHE_Escort, _SLS_TollUtil...), its stubs,
# Simple Follower Framework (DialogueFollowerScript), the SLS repo's own import list and the game's SKSE + vanilla sources.
#
# Run: powershell -ExecutionPolicy Bypass -File build_scripts.ps1 [-Targets a,b]
param([string[]]$Targets)
$ErrorActionPreference = 'Stop'

$root     = $PSScriptRoot
$integ    = 'C:\Modding\MO2\work\SLS_integration'
$slsRepo  = Join-Path $integ 'sls_repo'
$compiler = 'C:\Modding\MO2\basegame\Papyrus Compiler\PapyrusCompiler.exe'
$skse     = 'C:\Modding\MO2\basegame\Data\Scripts\Source'
$vanilla  = 'C:\Modding\MO2\basegame\Data\Source\Scripts'
$sff      = 'C:\Modding\MO2\mods\Simple Follower Framework\Source\Scripts'
$wfng     = 'C:\Modding\MO2\work\WetFunctionNG\papyrus\source'
$smi      = 'C:\Modding\MO2\mods\Survival Mode Improved - SKSE\Source\Scripts'
$srcDir   = Join-Path $root 'scripts'
$outDir   = Join-Path $root 'scripts_out'
New-Item -ItemType Directory -Force $outDir | Out-Null

[xml]$ppj = Get-Content (Join-Path $slsRepo 'skyrimse.ppj')
$imports = foreach ($i in $ppj.PapyrusProject.Imports.Import) {
    $v = [string]$i
    if ($v -eq '@ImportsFolder') { Join-Path $slsRepo 'scripts\source' }
    elseif ($v -eq '@SkyrimScripts') { $skse; $vanilla }
    else { Join-Path $slsRepo ($v -replace '^\.\\', '') }
}
$importList = @($srcDir, (Join-Path $integ 'src'), (Join-Path $integ 'stubs'), $sff, $wfng, $smi) + $imports
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
