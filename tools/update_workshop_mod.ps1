param(
    [string]$ModItemId = "3680820491",
    [string]$ZipPath = (Join-Path (Join-Path $PSScriptRoot "..") "dist\AscendantTiers.zip"),
    [string]$UploaderExe = (Join-Path (Join-Path $PSScriptRoot "..") "dist\DesyncedModUploader.exe")
)

$ErrorActionPreference = "Stop"
$exitCode = 0

function Wait-ForAnyKey {
    Write-Host ""
    Write-Host "Presiona cualquier tecla para cerrar..."
    try {
        $null = [Console]::ReadKey($true)
    }
    catch {
        Read-Host "No se pudo capturar tecla. Presiona Enter para cerrar"
    }
}

try {
    if (-not (Test-Path -LiteralPath $UploaderExe)) {
        throw "No se encontro DesyncedModUploader.exe en: $UploaderExe"
    }

    if (-not (Test-Path -LiteralPath $ZipPath)) {
        throw "No se encontro el zip del mod en: $ZipPath"
    }

    $resolvedUploader = (Resolve-Path -LiteralPath $UploaderExe).Path
    $resolvedZipPath = (Resolve-Path -LiteralPath $ZipPath).Path

    Write-Host "[RUN] $resolvedUploader -u $ModItemId $resolvedZipPath"
    & $resolvedUploader -u $ModItemId $resolvedZipPath
    $exitCode = $LASTEXITCODE
}
catch {
    Write-Error ("[ERROR] " + $_.Exception.Message)
    if ($exitCode -eq 0) {
        $exitCode = 1
    }
}
finally {
    Wait-ForAnyKey
    exit $exitCode
}
