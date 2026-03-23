param(
    [string]$OutputPath = (Join-Path (Join-Path $PSScriptRoot "..") "mod\workshop_grid_t2.png"),
    [int]$Width = 1920,
    [int]$Height = 1080
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

function Get-RandomSubset {
    param(
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo[]]$Items,
        [Parameter(Mandatory = $true)]
        [int]$Count
    )

    if ($Items.Count -eq 0 -or $Count -le 0) {
        return @()
    }

    if ($Items.Count -ge $Count) {
        return $Items | Get-Random -Count $Count
    }

    $result = New-Object System.Collections.Generic.List[System.IO.FileInfo]
    for ($i = 0; $i -lt $Count; $i++) {
        $result.Add(($Items | Get-Random -Count 1))
    }
    return $result.ToArray()
}

function Draw-CategoryGrid {
    param(
        [Parameter(Mandatory = $true)]
        [System.Drawing.Graphics]$Graphics,
        [Parameter(Mandatory = $true)]
        [System.Drawing.RectangleF]$PanelRect,
        [Parameter(Mandatory = $true)]
        [string]$Title,
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo[]]$Files,
        [Parameter(Mandatory = $true)]
        [System.Drawing.Color]$PanelColor,
        [int]$Cols = 4,
        [int]$Rows = 3
    )

    $titleHeight = 68
    $padding = 18
    $cellGap = 10

    $panelBrush = New-Object System.Drawing.SolidBrush($PanelColor)
    $panelBorder = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(200, 255, 255, 255), 2)
    $titleFont = New-Object System.Drawing.Font("Segoe UI Semibold", 30, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
    $titleBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(245, 245, 245))

    try {
        $Graphics.FillRectangle($panelBrush, $PanelRect)
        $Graphics.DrawRectangle($panelBorder, $PanelRect.X, $PanelRect.Y, $PanelRect.Width, $PanelRect.Height)

        $titleFmt = New-Object System.Drawing.StringFormat
        $titleFmt.Alignment = [System.Drawing.StringAlignment]::Center
        $titleFmt.LineAlignment = [System.Drawing.StringAlignment]::Center
        $titleRect = New-Object System.Drawing.RectangleF -ArgumentList @([single]$PanelRect.X, [single]($PanelRect.Y + 6), [single]$PanelRect.Width, [single]$titleHeight)
        $Graphics.DrawString($Title, $titleFont, $titleBrush, $titleRect, $titleFmt)
        $titleFmt.Dispose()

        $gridX = $PanelRect.X + $padding
        $gridY = $PanelRect.Y + $titleHeight + $padding
        $gridW = $PanelRect.Width - (2 * $padding)
        $gridH = $PanelRect.Height - $titleHeight - (2 * $padding)

        $cellW = [math]::Floor(($gridW - (($Cols - 1) * $cellGap)) / $Cols)
        $cellH = [math]::Floor(($gridH - (($Rows - 1) * $cellGap)) / $Rows)
        $iconSize = [math]::Min($cellW, $cellH)

        $drawCount = [math]::Min($Files.Count, $Cols * $Rows)
        for ($i = 0; $i -lt $drawCount; $i++) {
            $col = $i % $Cols
            $row = [math]::Floor($i / $Cols)
            $x = $gridX + ($col * ($cellW + $cellGap)) + [math]::Floor(($cellW - $iconSize) / 2)
            $y = $gridY + ($row * ($cellH + $cellGap)) + [math]::Floor(($cellH - $iconSize) / 2)

            $iconPath = $Files[$i].FullName
            $icon = [System.Drawing.Image]::FromFile($iconPath)
            try {
                $shadowBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(90, 0, 0, 0))
                $Graphics.FillRectangle($shadowBrush, $x + 5, $y + 5, $iconSize, $iconSize)
                $shadowBrush.Dispose()

                $Graphics.DrawImage($icon, $x, $y, $iconSize, $iconSize)
            }
            finally {
                $icon.Dispose()
            }
        }
    }
    finally {
        $panelBrush.Dispose()
        $panelBorder.Dispose()
        $titleFont.Dispose()
        $titleBrush.Dispose()
    }
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$componentsDir = Join-Path $repoRoot "mod\textures\icons\components"
$framesDir = Join-Path $repoRoot "mod\textures\icons\frame"

if (-not (Test-Path -LiteralPath $componentsDir)) {
    throw "Missing components icons folder: $componentsDir"
}
if (-not (Test-Path -LiteralPath $framesDir)) {
    throw "Missing frame icons folder: $framesDir"
}

$componentFiles = Get-ChildItem -LiteralPath $componentsDir -Filter "*_t2.png" -File
$frameFiles = Get-ChildItem -LiteralPath $framesDir -Filter "*_t2.png" -File
$unitFiles = $frameFiles | Where-Object { $_.Name -match "^f_.*_t2\.png$" }
$buildingFiles = $frameFiles | Where-Object { $_.Name -match "^(building_|storage_).+_t2\.png$" }

if ($componentFiles.Count -eq 0) { throw "No T2 component icons found." }
if ($unitFiles.Count -eq 0) { throw "No T2 unit icons found." }
if ($buildingFiles.Count -eq 0) { throw "No T2 building icons found." }

$panelIconCount = 12
$componentsRandom = Get-RandomSubset -Items $componentFiles -Count $panelIconCount
$unitsRandom = Get-RandomSubset -Items $unitFiles -Count $panelIconCount
$buildingsRandom = Get-RandomSubset -Items $buildingFiles -Count $panelIconCount

$bitmap = New-Object System.Drawing.Bitmap($Width, $Height)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)

try {
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

    $bgRect = New-Object System.Drawing.Rectangle -ArgumentList @(0, 0, $Width, $Height)
    $bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        $bgRect,
        [System.Drawing.Color]::FromArgb(255, 12, 20, 38),
        [System.Drawing.Color]::FromArgb(255, 36, 62, 105),
        25
    )
    try {
        $graphics.FillRectangle($bgBrush, $bgRect)
    }
    finally {
        $bgBrush.Dispose()
    }

    $headerFont = New-Object System.Drawing.Font("Segoe UI Black", 64, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
    $headerBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(245, 245, 245))
    try {
        $fmt = New-Object System.Drawing.StringFormat
        $fmt.Alignment = [System.Drawing.StringAlignment]::Center
        $fmt.LineAlignment = [System.Drawing.StringAlignment]::Center

        $headerRect = New-Object System.Drawing.RectangleF -ArgumentList @([single]0, [single]20, [single]$Width, [single]78)
        $graphics.DrawString("Ascendant Tiers", $headerFont, $headerBrush, $headerRect, $fmt)

        $fmt.Dispose()
    }
    finally {
        $headerFont.Dispose()
        $headerBrush.Dispose()
    }

    $outerMargin = 32
    $panelGap = 20
    $panelTop = 156
    $panelHeight = $Height - $panelTop - 34
    $panelWidth = [math]::Floor(($Width - (2 * $outerMargin) - (2 * $panelGap)) / 3)

    $panel1 = New-Object System.Drawing.RectangleF -ArgumentList @([single]$outerMargin, [single]$panelTop, [single]$panelWidth, [single]$panelHeight)
    $panel2 = New-Object System.Drawing.RectangleF -ArgumentList @([single]($outerMargin + $panelWidth + $panelGap), [single]$panelTop, [single]$panelWidth, [single]$panelHeight)
    $panel3 = New-Object System.Drawing.RectangleF -ArgumentList @([single]($outerMargin + (2 * ($panelWidth + $panelGap))), [single]$panelTop, [single]$panelWidth, [single]$panelHeight)

    Draw-CategoryGrid -Graphics $graphics -PanelRect $panel1 -Title "Components II" -Files $componentsRandom -PanelColor ([System.Drawing.Color]::FromArgb(96, 29, 58, 96))
    Draw-CategoryGrid -Graphics $graphics -PanelRect $panel2 -Title "Units II" -Files $unitsRandom -PanelColor ([System.Drawing.Color]::FromArgb(96, 44, 79, 59))
    Draw-CategoryGrid -Graphics $graphics -PanelRect $panel3 -Title "Buildings II" -Files $buildingsRandom -PanelColor ([System.Drawing.Color]::FromArgb(96, 84, 64, 34))

    $borderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(220, 255, 204, 120), 4)
    try {
        $graphics.DrawRectangle($borderPen, 8, 8, $Width - 16, $Height - 16)
    }
    finally {
        $borderPen.Dispose()
    }

    $outDir = Split-Path -Parent $OutputPath
    if (-not (Test-Path -LiteralPath $outDir)) {
        New-Item -ItemType Directory -Path $outDir -Force | Out-Null
    }

    $bitmap.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
}
finally {
    $graphics.Dispose()
    $bitmap.Dispose()
}

Write-Host "[OK] Workshop grid generated:" $OutputPath
