param(
    [string]$ModFolder = (Join-Path (Join-Path $PSScriptRoot "..") "mod"),
    [string]$ZipName = "AscendedTiers.zip",
    [string]$DeployPath = "C:\Program Files (x86)\Steam\steamapps\common\Desynced\Desynced\Content\mods"
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

function New-ZipWithNormalizedPaths {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SourceFolder,
        [Parameter(Mandatory = $true)]
        [string]$ZipPath
    )

    $sourceRoot = (Resolve-Path -LiteralPath $SourceFolder).Path
    $files = Get-ChildItem -LiteralPath $sourceRoot -Recurse -File

    $zipStream = [System.IO.File]::Open($ZipPath, [System.IO.FileMode]::Create)
    try {
        $archive = New-Object System.IO.Compression.ZipArchive($zipStream, [System.IO.Compression.ZipArchiveMode]::Create, $false)
        try {
            foreach ($file in $files) {
                $relativePath = $file.FullName.Substring($sourceRoot.Length).TrimStart('\', '/')
                $entryName = $relativePath -replace '\\', '/'
                $entry = $archive.CreateEntry($entryName, [System.IO.Compression.CompressionLevel]::Optimal)

                $entryStream = $entry.Open()
                try {
                    $fileStream = [System.IO.File]::OpenRead($file.FullName)
                    try {
                        $fileStream.CopyTo($entryStream)
                    }
                    finally {
                        $fileStream.Dispose()
                    }
                }
                finally {
                    $entryStream.Dispose()
                }
            }
        }
        finally {
            $archive.Dispose()
        }
    }
    finally {
        $zipStream.Dispose()
    }
}

try {
    if (-not (Test-Path -LiteralPath $ModFolder)) {
        throw "No existe la carpeta del mod: $ModFolder"
    }

    $resolvedModFolder = (Resolve-Path -LiteralPath $ModFolder).Path
    $repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path
    $distPath = Join-Path $repoRoot "dist"
    $zipOutputPath = Join-Path $distPath $ZipName
    $deployZipPath = Join-Path $DeployPath $ZipName

    if (-not (Test-Path -LiteralPath $distPath)) {
        New-Item -ItemType Directory -Path $distPath | Out-Null
    }

    if (Test-Path -LiteralPath $zipOutputPath) {
        Remove-Item -LiteralPath $zipOutputPath -Force
    }

    New-ZipWithNormalizedPaths -SourceFolder $resolvedModFolder -ZipPath $zipOutputPath

    if (-not (Test-Path -LiteralPath $DeployPath)) {
        New-Item -ItemType Directory -Path $DeployPath -Force | Out-Null
    }

    Copy-Item -LiteralPath $zipOutputPath -Destination $deployZipPath -Force

    Write-Host "[OK] Zip generado:" $zipOutputPath
    Write-Host "[OK] Zip copiado a:" $deployZipPath
}
catch {
    Write-Error ("[ERROR] " + $_.Exception.Message)
    exit 1
}
