# Compile the SL Survival integration patch scripts.
# Sources: src\ (our edits of crajjjj/SLSurvival tag 0.716, see orig\SOURCE_COMMIT.txt), stubs\ (compile-time only,
# never shipped), the SLS repo's own import list (skyrimse.ppj) and the game's SKSE + vanilla script sources.
#
# Run: powershell -ExecutionPolicy Bypass -File build.ps1 [-Sources orig] [-Out out_orig] [-Targets a,b]
param(
    [string]$Sources = 'src',
    [string]$Out = 'out',
    [string[]]$Targets
)
$ErrorActionPreference = 'Stop'

$root     = $PSScriptRoot
$slsRepo  = if ($env:SLS_REPO) { $env:SLS_REPO } else { Join-Path $root 'sls_repo' }
$compiler = 'C:\Modding\MO2\basegame\Papyrus Compiler\PapyrusCompiler.exe'
$skse     = 'C:\Modding\MO2\basegame\Data\Scripts\Source'
$vanilla  = 'C:\Modding\MO2\basegame\Data\Source\Scripts'
$wfng     = 'C:\Modding\MO2\work\WetFunctionNG\papyrus\source'
$smi      = 'C:\Modding\MO2\mods\Survival Mode Improved - SKSE\Source\Scripts'  # SurvivalModeImprovedApi (import only, _SLS_IntCcs)

if (-not (Test-Path (Join-Path $slsRepo 'skyrimse.ppj'))) { throw "SLS repo not found at $slsRepo (set SLS_REPO)" }

$srcDir = Join-Path $root $Sources
$outDir = Join-Path $root $Out
New-Item -ItemType Directory -Force $outDir | Out-Null

# the ppj import list, with its two variables resolved
[xml]$ppj = Get-Content (Join-Path $slsRepo 'skyrimse.ppj')
$imports = foreach ($i in $ppj.PapyrusProject.Imports.Import) {
    $v = [string]$i
    if ($v -eq '@ImportsFolder') { Join-Path $slsRepo 'scripts\source' }
    elseif ($v -eq '@SkyrimScripts') { $skse; $vanilla }
    else { Join-Path $slsRepo ($v -replace '^\.\\', '') }
}
# our sources first so they shadow the repo copies, then stubs for mods whose scripts are not installed as source
$importList = @($srcDir, (Join-Path $root 'stubs'), $wfng, $smi) + $imports
$importArg = ($importList | Where-Object { Test-Path $_ }) -join ';'

$Targets = @($Targets | ForEach-Object { $_ -split "," } | Where-Object { $_ })
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
