#requires -Version 7.0
# Builds a Factorio ZIP on Windows using the same runtime allowlist as package-mod.sh.
# Requires PowerShell 7; emits the absolute archive path for validation callers.
[CmdletBinding()]
param([string]$OutputDirectory = (Join-Path $PSScriptRoot '../dist'))

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path $PSScriptRoot -Parent
$info = Get-Content (Join-Path $repositoryRoot 'info.json') -Raw | ConvertFrom-Json
if ($info.name -notmatch '^[A-Za-z0-9_-]+$' -or $info.version -notmatch '^\d+\.\d+\.\d+$') {
	throw 'Invalid mod name or version in info.json.'
}
foreach ($requiredPath in 'info.json', 'data.lua', 'data-updates.lua', 'data-final-fixes.lua', 'prototypes', 'locale') {
	if (-not (Test-Path -LiteralPath (Join-Path $repositoryRoot $requiredPath))) {
		throw "Required release path is missing: $requiredPath"
	}
}

$runtimePaths = @(
	'info.json', 'thumbnail.png', 'data.lua', 'data-updates.lua', 'data-final-fixes.lua',
	'control.lua', 'settings.lua', 'settings-updates.lua', 'settings-final-fixes.lua',
	'prototypes', 'locale', 'graphics', 'sounds', 'simulations', 'scenarios', 'migrations'
)
$packageName = "$($info.name)_$($info.version)"
$outputRoot = [IO.Path]::GetFullPath($OutputDirectory)
[IO.Directory]::CreateDirectory($outputRoot) | Out-Null
$archivePath = Join-Path $outputRoot "$packageName.zip"
$stream = [IO.File]::Open($archivePath, [IO.FileMode]::Create)
try {
	$archive = [IO.Compression.ZipArchive]::new($stream, [IO.Compression.ZipArchiveMode]::Create)
	try {
		foreach ($runtimePath in $runtimePaths) {
			$source = Join-Path $repositoryRoot $runtimePath
			if (-not (Test-Path -LiteralPath $source)) { continue }
			$files = if (Test-Path -LiteralPath $source -PathType Container) {
				Get-ChildItem -LiteralPath $source -Recurse -File
			} else {
				Get-Item -LiteralPath $source
			}
			foreach ($file in $files) {
				$relativePath = [IO.Path]::GetRelativePath($repositoryRoot, $file.FullName).Replace('\', '/')
				[IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
					$archive, $file.FullName, "$packageName/$relativePath", [IO.Compression.CompressionLevel]::Optimal
				) | Out-Null
			}
		}
	} finally {
		$archive.Dispose()
	}
} finally {
	$stream.Dispose()
}
Write-Host "Built $archivePath"
$archivePath
