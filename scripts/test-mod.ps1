#requires -Version 7.0
# Packages and tests No Aquilo with the real Factorio engine in isolated directories.
# Requires PowerShell 7 and a local Factorio 2.1 Space Age installation.
[CmdletBinding()]
param([string]$FactorioPath = (Join-Path $PSScriptRoot '../../../bin/x64/factorio.exe'))

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path $PSScriptRoot -Parent
$executable = (Resolve-Path -LiteralPath $FactorioPath).Path
$dataPath = [IO.Path]::GetFullPath((Join-Path (Split-Path $executable -Parent) '../../data'))
$baseInfo = Get-Content (Join-Path $dataPath 'base/info.json') -Raw | ConvertFrom-Json
if ($baseInfo.version -notmatch '^2\.1\.') { throw "Expected Factorio 2.1, found $($baseInfo.version)." }
$runRoot = Join-Path $repositoryRoot "_factorio-test/$([guid]::NewGuid().ToString('N'))"
$archivePath = & (Join-Path $PSScriptRoot 'package-mod.ps1') -OutputDirectory (Join-Path $runRoot 'package')
Write-Host "Testing Factorio $($baseInfo.version); evidence: $runRoot"

function Invoke-FactorioCheck([string]$Name, [string[]]$Arguments) {
	$stdout = Join-Path $script:caseRoot "$Name.stdout.txt"
	$stderr = Join-Path $script:caseRoot "$Name.stderr.txt"
	$allArguments = @('--config', (Join-Path $script:caseRoot 'config.ini'),
		'--mod-directory', (Join-Path $script:caseRoot 'mods'), '--disable-audio') + $Arguments
	$quotedArguments = $allArguments | ForEach-Object { '"' + $_ + '"' }
	$process = Start-Process -FilePath $executable -ArgumentList $quotedArguments -WindowStyle Hidden `
		-RedirectStandardOutput $stdout -RedirectStandardError $stderr -PassThru -Wait
	if ($process.ExitCode -ne 0) {
		Get-Content $stdout -Tail 30 | Write-Host
		throw "Factorio $Name failed with exit code $($process.ExitCode). See $stderr"
	}
	Write-Host "PASS $Name"
	return Get-Content $stdout -Raw
}

foreach ($qualityEnabled in $true, $false) {
	$caseName = if ($qualityEnabled) { 'with-quality' } else { 'without-quality' }
	$script:caseRoot = Join-Path $runRoot $caseName
	$modsRoot = Join-Path $caseRoot 'mods'
	$writeRoot = Join-Path $caseRoot 'write'
	New-Item -ItemType Directory -Force -Path $modsRoot, $writeRoot | Out-Null
	Copy-Item -LiteralPath $archivePath -Destination $modsRoot
	$mods = @('base', 'elevated-rails', 'recycler', 'space-age', 'no-aquilo') | ForEach-Object {
		@{name = $_; enabled = $true}
	}
	$mods += @{name = 'quality'; enabled = $qualityEnabled}
	@{mods = $mods} | ConvertTo-Json -Depth 4 | Set-Content (Join-Path $modsRoot 'mod-list.json')
	@"
[path]
read-data=$($dataPath.Replace('\', '/'))
write-data=$($writeRoot.Replace('\', '/'))
[general]
check-updates=false
"@ | Set-Content (Join-Path $caseRoot 'config.ini')
	$dumpOutput = Invoke-FactorioCheck "$caseName-dump" @('--dump-data', '--check-unused-prototype-data')
	if ($dumpOutput -match 'Warning|Error|was not used') { throw "Inspect prototype warnings in $caseRoot" }
	$dumpPath = Join-Path $writeRoot 'script-output/data-raw-dump.json'
	if (-not (Test-Path -LiteralPath $dumpPath)) { throw 'Factorio did not produce a prototype dump.' }

	# First load the exact release without test instrumentation, then exercise engine behavior.
	$savePath = Join-Path $caseRoot 'new-game.zip'
	$null = Invoke-FactorioCheck "$caseName-create" @('--create', $savePath, '--map-gen-seed', '12345')
	if (-not (Test-Path -LiteralPath $savePath)) { throw 'Factorio did not produce a new game.' }
	$benchmarkOutput = Invoke-FactorioCheck "$caseName-benchmark" @('--benchmark', $savePath, '--benchmark-ticks', '60')
	if ($benchmarkOutput -notmatch 'Performed 60 updates') { throw 'The new game did not complete 60 updates.' }

	Copy-Item -LiteralPath (Join-Path $repositoryRoot 'tests/runtime-contract') `
		-Destination (Join-Path $modsRoot 'no-aquilo-runtime-contract') -Recurse
	$mods += @{name = 'no-aquilo-runtime-contract'; enabled = $true}
	@{mods = $mods} | ConvertTo-Json -Depth 4 | Set-Content (Join-Path $modsRoot 'mod-list.json')
	$contractOutput = Invoke-FactorioCheck "$caseName-contract" @('--create', (Join-Path $caseRoot 'contract.zip'), '--map-gen-seed', '12345')
	if ($contractOutput -notmatch 'NO_AQUILO_RUNTIME_CONTRACT_OK') { throw 'Runtime contract did not complete.' }
}

$vulcanusOutput = Invoke-FactorioCheck 'vulcanus-preview' @('--generate-map-preview',
	(Join-Path $caseRoot 'vulcanus.png'), '--map-preview-planet', 'vulcanus', '--map-preview-size', '4096',
	'--map-gen-seed', '12345', '--report-quantities', 'fluorite,calcite')
foreach ($resource in 'fluorite', 'calcite') {
	if ($vulcanusOutput -notmatch "$resource`: totalEntityCount=[1-9][0-9]*, totalRichness=[1-9][0-9]*,") {
		throw "Vulcanus did not generate $resource."
	}
}
$aquiloOutput = Invoke-FactorioCheck 'aquilo-preview' @('--generate-map-preview',
	(Join-Path $caseRoot 'aquilo.png'), '--map-preview-planet', 'aquilo', '--map-preview-size', '512',
	'--map-gen-seed', '12345', '--report-quantities', 'crude-oil,lithium-brine,fluorine-vent')
foreach ($resource in 'crude-oil', 'lithium-brine', 'fluorine-vent') {
	if ($aquiloOutput -notmatch "$resource`: totalEntityCount=0, totalRichness=0,") {
		throw "Aquilo still generates $resource."
	}
}
Write-Host 'PASS resource quantities: Vulcanus fluorite/calcite present; Aquilo resources absent.'
Write-Host "All checks passed. Evidence and tested ZIP: $runRoot"
