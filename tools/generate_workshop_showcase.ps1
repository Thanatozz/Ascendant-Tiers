param(
    [string]$OutputDir = (Join-Path (Join-Path $PSScriptRoot "..") "mod"),
    [int]$Width = 1920,
    [int]$Height = 1080
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

function Get-SortedFiles {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Filter,
        [scriptblock]$Where = $null
    )

    $files = Get-ChildItem -LiteralPath $Path -Filter $Filter -File | Sort-Object Name
    if ($Where) {
        $files = $files | Where-Object $Where
    }
    return @($files)
}

function Draw-CategoryPage {
    param(
        [Parameter(Mandatory = $true)]
        [string]$OutputPath,
        [Parameter(Mandatory = $true)]
        [string]$Title,
        [Parameter(Mandatory = $true)]
        [string]$Subtitle,
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo[]]$PageFiles,
        [Parameter(Mandatory = $true)]
        [int]$Cols,
        [Parameter(Mandatory = $true)]
        [int]$Rows,
        [Parameter(Mandatory = $true)]
        [System.Drawing.Color]$PanelColor,
        [Parameter(Mandatory = $true)]
        [int]$CanvasWidth,
        [Parameter(Mandatory = $true)]
        [int]$CanvasHeight
    )

    $bitmap = New-Object System.Drawing.Bitmap($CanvasWidth, $CanvasHeight)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)

    try {
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

        $bgRect = New-Object System.Drawing.Rectangle -ArgumentList @(0, 0, $CanvasWidth, $CanvasHeight)
        $bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
            $bgRect,
            [System.Drawing.Color]::FromArgb(255, 11, 19, 36),
            [System.Drawing.Color]::FromArgb(255, 32, 56, 92),
            25
        )
        try {
            $graphics.FillRectangle($bgBrush, $bgRect)
        }
        finally {
            $bgBrush.Dispose()
        }

        $titleFont = New-Object System.Drawing.Font("Segoe UI Black", 58, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
        $subFont = New-Object System.Drawing.Font("Segoe UI", 27, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
        $titleBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(245, 245, 245))
        $subBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 198, 90))

        try {
            $fmt = New-Object System.Drawing.StringFormat
            $fmt.Alignment = [System.Drawing.StringAlignment]::Center
            $fmt.LineAlignment = [System.Drawing.StringAlignment]::Center

            $titleRect = New-Object System.Drawing.RectangleF -ArgumentList @([single]0, [single]12, [single]$CanvasWidth, [single]78)
            $subRect = New-Object System.Drawing.RectangleF -ArgumentList @([single]0, [single]88, [single]$CanvasWidth, [single]48)
            $graphics.DrawString($Title, $titleFont, $titleBrush, $titleRect, $fmt)
            $graphics.DrawString($Subtitle, $subFont, $subBrush, $subRect, $fmt)

            $fmt.Dispose()
        }
        finally {
            $titleFont.Dispose()
            $subFont.Dispose()
            $titleBrush.Dispose()
            $subBrush.Dispose()
        }

        $outerMargin = 40
        $panelTop = 150
        $panelHeight = $CanvasHeight - $panelTop - 36
        $panelWidth = $CanvasWidth - (2 * $outerMargin)
        $panelRect = New-Object System.Drawing.RectangleF -ArgumentList @([single]$outerMargin, [single]$panelTop, [single]$panelWidth, [single]$panelHeight)

        $panelBrush = New-Object System.Drawing.SolidBrush($PanelColor)
        $panelBorder = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(200, 255, 255, 255), 2)

        try {
            $graphics.FillRectangle($panelBrush, $panelRect)
            $graphics.DrawRectangle($panelBorder, $panelRect.X, $panelRect.Y, $panelRect.Width, $panelRect.Height)
        }
        finally {
            $panelBrush.Dispose()
            $panelBorder.Dispose()
        }

        $padding = 24
        $cellGap = 12
        $gridX = $panelRect.X + $padding
        $gridY = $panelRect.Y + $padding
        $gridW = $panelRect.Width - (2 * $padding)
        $gridH = $panelRect.Height - (2 * $padding)

        $cellW = [math]::Floor(($gridW - (($Cols - 1) * $cellGap)) / $Cols)
        $cellH = [math]::Floor(($gridH - (($Rows - 1) * $cellGap)) / $Rows)
        $iconSize = [math]::Min($cellW, $cellH)

        for ($i = 0; $i -lt $PageFiles.Count; $i++) {
            $col = $i % $Cols
            $row = [math]::Floor($i / $Cols)
            $x = $gridX + ($col * ($cellW + $cellGap)) + [math]::Floor(($cellW - $iconSize) / 2)
            $y = $gridY + ($row * ($cellH + $cellGap)) + [math]::Floor(($cellH - $iconSize) / 2)

            $icon = [System.Drawing.Image]::FromFile($PageFiles[$i].FullName)
            try {
                $shadowBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(90, 0, 0, 0))
                $graphics.FillRectangle($shadowBrush, $x + 4, $y + 4, $iconSize, $iconSize)
                $shadowBrush.Dispose()
                $graphics.DrawImage($icon, $x, $y, $iconSize, $iconSize)
            }
            finally {
                $icon.Dispose()
            }
        }

        $borderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(220, 255, 204, 120), 4)
        try {
            $graphics.DrawRectangle($borderPen, 8, 8, $CanvasWidth - 16, $CanvasHeight - 16)
        }
        finally {
            $borderPen.Dispose()
        }

        $outParent = Split-Path -Parent $OutputPath
        if (-not (Test-Path -LiteralPath $outParent)) {
            New-Item -ItemType Directory -Path $outParent -Force | Out-Null
        }

        $bitmap.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    }
    finally {
        $graphics.Dispose()
        $bitmap.Dispose()
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

$excludedComponentIcons = @(
    "c_light_t2.png",
    "c_light_rgb_t2.png"
)

$components = Get-SortedFiles -Path $componentsDir -Filter "*_t2.png" -Where {
    ($excludedComponentIcons -notcontains $_.Name.ToLowerInvariant())
}
$buildings = Get-SortedFiles -Path $framesDir -Filter "*_t2.png" -Where { $_.Name -match "^(building_|storage_).+_t2\.png$" }
$units = Get-SortedFiles -Path $framesDir -Filter "*_t2.png" -Where { $_.Name -match "^f_.*_t2\.png$" }

if ($components.Count -eq 0) { throw "No T2 component icons found." }
if ($buildings.Count -eq 0) { throw "No T2 building icons found." }
if ($units.Count -eq 0) { throw "No T2 unit icons found." }

if (-not (Test-Path -LiteralPath $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

Get-ChildItem -LiteralPath $OutputDir -Filter "workshop_components_t2*.png" -File -ErrorAction SilentlyContinue |
    Remove-Item -Force -ErrorAction SilentlyContinue

$categories = @(
    @{
        Key = "buildings"
        Title = "Ascendant Tiers - Buildings [T2]"
        Subtitle = "All T2 building frames"
        Files = $buildings
        Cols = 6
        Rows = 4
        BaseName = "workshop_buildings_t2"
        PanelColor = [System.Drawing.Color]::FromArgb(96, 84, 64, 34)
    },
    @{
        Key = "units"
        Title = "Ascendant Tiers - Units [T2]"
        Subtitle = "All T2 robot unit frames"
        Files = $units
        Cols = 5
        Rows = 3
        BaseName = "workshop_units_t2"
        PanelColor = [System.Drawing.Color]::FromArgb(96, 44, 79, 59)
    },
    @{
        Key = "components"
        Title = "Ascendant Tiers - Components [T2]"
        Subtitle = "All T2 components"
        Files = $components
        Cols = 8
        Rows = 5
        BaseName = "workshop_components_t2"
        PanelColor = [System.Drawing.Color]::FromArgb(96, 29, 58, 96)
    }
)

$generated = New-Object System.Collections.Generic.List[string]

foreach ($category in $categories) {
    $files = @($category.Files)
    $capacity = [int]$category.Cols * [int]$category.Rows
    $pageCount = [math]::Ceiling($files.Count / $capacity)

    for ($page = 0; $page -lt $pageCount; $page++) {
        $start = $page * $capacity
        $end = [math]::Min($start + $capacity - 1, $files.Count - 1)
        $pageFiles = @()
        for ($i = $start; $i -le $end; $i++) {
            $pageFiles += $files[$i]
        }

        $pageNumber = $page + 1
        $suffix = if ($pageCount -gt 1) { "_$pageNumber" } else { "" }
        $outputPath = Join-Path $OutputDir ("{0}{1}.png" -f $category.BaseName, $suffix)
        $rangeText = "{0}-{1} of {2}" -f ($start + 1), ($end + 1), $files.Count
        $subtitle = "{0} | Items {1}" -f $category.Subtitle, $rangeText

        Draw-CategoryPage `
            -OutputPath $outputPath `
            -Title $category.Title `
            -Subtitle $subtitle `
            -PageFiles $pageFiles `
            -Cols $category.Cols `
            -Rows $category.Rows `
            -PanelColor $category.PanelColor `
            -CanvasWidth $Width `
            -CanvasHeight $Height

        $generated.Add($outputPath)
    }
}

Write-Host "[OK] Generated workshop showcase images:"
foreach ($path in $generated) {
    Write-Host " - $path"
}
