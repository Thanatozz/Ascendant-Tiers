param(
    [string]$ModItemId = "3680820491",
    [string]$ImagePath = (Join-Path $PSScriptRoot "AscendantTiers.png"),
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

    if (-not (Test-Path -LiteralPath $ImagePath)) {
        throw "No se encontro la imagen del mod en: $ImagePath"
    }

    $resolvedUploader = (Resolve-Path -LiteralPath $UploaderExe).Path
    $resolvedImagePath = (Resolve-Path -LiteralPath $ImagePath).Path

    Write-Host "[RUN] $resolvedUploader -u $ModItemId $resolvedImagePath"
    & $resolvedUploader -u $ModItemId $resolvedImagePath
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
