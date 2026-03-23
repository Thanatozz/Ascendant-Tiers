param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
    [string]$BadgeText = "A",
    [string]$SourcePath = "",
    [string]$TargetPath = "",
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing

$modRoot = Join-Path $RepoRoot "mod"
$fontRoot = Join-Path $RepoRoot "fonts"

# Keep the exact same visual style as generate_t2_icons.ps1.
$badgeScale = 0.40
$fontScale = 0.72
$marginScale = 0.025
$glyphOpticalOffsetX = 0.0
$glyphOpticalOffsetY = -0.5
$script:PrivateFontCollection = $null
$script:PreferredFontFamily = $null

function New-RoundedRectPath {
    param(
        [System.Drawing.RectangleF]$Rect,
        [float]$Radius
    )

    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $diameter = [Math]::Max(0.0, $Radius * 2.0)

    if ($diameter -lt 1.0) {
        $path.AddRectangle($Rect)
        return $path
    }

    $arc = New-Object System.Drawing.RectangleF($Rect.X, $Rect.Y, $diameter, $diameter)
    $path.AddArc($arc, 180, 90)

    $arc.X = $Rect.Right - $diameter
    $path.AddArc($arc, 270, 90)

    $arc.Y = $Rect.Bottom - $diameter
    $path.AddArc($arc, 0, 90)

    $arc.X = $Rect.X
    $path.AddArc($arc, 90, 90)

    $path.CloseFigure()
    return $path
}

function Initialize-LocalFontFamily {
    $fontFile = Join-Path $fontRoot "RobotoSlab-SemiBold.ttf"
    if (-not (Test-Path $fontFile)) {
        Write-Warning "Local font file not found at $fontFile. Falling back to installed fonts."
        return
    }

    try {
        $pfc = New-Object System.Drawing.Text.PrivateFontCollection
        $pfc.AddFontFile($fontFile)

        $family = $pfc.Families | Where-Object { $_.Name -eq "Roboto Slab" } | Select-Object -First 1
        if (-not $family) {
            $family = $pfc.Families | Select-Object -First 1
        }

        if ($family) {
            $script:PrivateFontCollection = $pfc
            $script:PreferredFontFamily = $family
            Write-Host "Using local font file: $fontFile"
            return
        }

        $pfc.Dispose()
        Write-Warning "Could not resolve font family from $fontFile. Falling back to installed fonts."
    }
    catch {
        Write-Warning "Failed to load local font file $fontFile. Falling back to installed fonts. Error: $($_.Exception.Message)"
    }
}

function New-BadgeFont {
    param(
        [single]$FontSize
    )

    if ($script:PreferredFontFamily) {
        try {
            return New-Object System.Drawing.Font($script:PreferredFontFamily, $FontSize, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
        }
        catch {}
    }

    try {
        return New-Object System.Drawing.Font("Roboto Slab SemiBold", $FontSize, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
    }
    catch {}

    try {
        return New-Object System.Drawing.Font("Roboto Slab", $FontSize, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
    }
    catch {}

    return New-Object System.Drawing.Font("Segoe UI Semibold", $FontSize, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
}

function Draw-OpticallyCenteredGlyph {
    param(
        [System.Drawing.Graphics]$Graphics,
        [System.Drawing.RectangleF]$Rect,
        [System.Drawing.Font]$Font,
        [string]$Text,
        [single]$OpticalOffsetX,
        [single]$OpticalOffsetY
    )

    $format = New-Object System.Drawing.StringFormat
    $format.FormatFlags = [System.Drawing.StringFormatFlags]::NoClip
    $format.Alignment = [System.Drawing.StringAlignment]::Near
    $format.LineAlignment = [System.Drawing.StringAlignment]::Near

    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    try {
        $path.AddString($Text, $Font.FontFamily, [int]$Font.Style, $Font.Size, (New-Object System.Drawing.PointF(0.0, 0.0)), $format)
        $bounds = $path.GetBounds()

        $targetCenterX = [single]($Rect.X + ($Rect.Width / 2.0) + $OpticalOffsetX)
        $targetCenterY = [single]($Rect.Y + ($Rect.Height / 2.0) + $OpticalOffsetY)
        $glyphCenterX = [single]($bounds.X + ($bounds.Width / 2.0))
        $glyphCenterY = [single]($bounds.Y + ($bounds.Height / 2.0))

        $dx = [single]($targetCenterX - $glyphCenterX)
        $dy = [single]($targetCenterY - $glyphCenterY)

        $transform = New-Object System.Drawing.Drawing2D.Matrix
        try {
            $transform.Translate($dx, $dy)
            $path.Transform($transform)
        }
        finally {
            $transform.Dispose()
        }

        $shadowPath = $path.Clone()
        try {
            $shadowTransform = New-Object System.Drawing.Drawing2D.Matrix
            try {
                $shadowTransform.Translate(1.0, 1.0)
                $shadowPath.Transform($shadowTransform)
            }
            finally {
                $shadowTransform.Dispose()
            }

            $shadowBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(150, 0, 0, 0))
            $textBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 245, 250, 255))
            try {
                $Graphics.FillPath($shadowBrush, $shadowPath)
                $Graphics.FillPath($textBrush, $path)
            }
            finally {
                $shadowBrush.Dispose()
                $textBrush.Dispose()
            }
        }
        finally {
            $shadowPath.Dispose()
        }
    }
    finally {
        $path.Dispose()
        $format.Dispose()
    }
}

Initialize-LocalFontFamily

$sourceFiles = @()
$jobs = @()

if (([string]::IsNullOrWhiteSpace($SourcePath)) -xor ([string]::IsNullOrWhiteSpace($TargetPath))) {
    throw "Use both -SourcePath and -TargetPath together."
}

if (-not [string]::IsNullOrWhiteSpace($SourcePath)) {
    $resolvedSourcePath = $SourcePath
    if (-not [System.IO.Path]::IsPathRooted($resolvedSourcePath)) {
        $resolvedSourcePath = Join-Path $RepoRoot $resolvedSourcePath
    }

    $resolvedTargetPath = $TargetPath
    if (-not [System.IO.Path]::IsPathRooted($resolvedTargetPath)) {
        $resolvedTargetPath = Join-Path $RepoRoot $resolvedTargetPath
    }

    if (-not (Test-Path $resolvedSourcePath)) {
        throw "Source file not found: $resolvedSourcePath"
    }

    $jobs += [PSCustomObject]@{
        SourcePath = $resolvedSourcePath
        TargetPath = $resolvedTargetPath
    }
}
else {
    $sourceFolders = @(
        (Join-Path $modRoot "textures/icons/components"),
        (Join-Path $modRoot "textures/icons/frame")
    )

    foreach ($folder in $sourceFolders) {
        if (-not (Test-Path $folder)) {
            continue
        }

        $sourceFiles += Get-ChildItem -Path $folder -File -Filter "*_t2.png" | Sort-Object Name
    }

    if ($sourceFiles.Count -eq 0) {
        throw "No source files found. Expected *_t2.png under mod/textures/icons/components or mod/textures/icons/frame."
    }

    foreach ($file in $sourceFiles) {
        $derivedTargetPath = [Regex]::Replace($file.FullName, "_t2\\.png$", "_a.png", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        $jobs += [PSCustomObject]@{
            SourcePath = $file.FullName
            TargetPath = $derivedTargetPath
        }
    }
}

foreach ($job in $jobs) {
    $sourcePath = $job.SourcePath
    $targetPath = $job.TargetPath
    if ($targetPath.StartsWith($modRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        $relativeTarget = $targetPath.Substring($modRoot.Length + 1) -replace "\\", "/"
    }
    else {
        $relativeTarget = $targetPath
    }

    if ($DryRun) {
        Write-Host "[DRY] $relativeTarget"
        continue
    }

    $source = [System.Drawing.Image]::FromFile($sourcePath)
    try {
        $bitmap = New-Object System.Drawing.Bitmap($source.Width, $source.Height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        try {
            $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
            try {
                $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
                $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
                $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

                $graphics.DrawImage($source, 0, 0, $source.Width, $source.Height)

                $badgeW = [Math]::Max(12, [int][Math]::Round($source.Width * $badgeScale))
                $badgeH = [Math]::Max(12, [int][Math]::Round($source.Height * $badgeScale))
                $margin = [Math]::Max(2, [int][Math]::Round($source.Width * $marginScale))

                $badgeX = $source.Width - $badgeW - $margin
                $badgeY = $margin

                $rect = New-Object System.Drawing.RectangleF([single]$badgeX, [single]$badgeY, [single]$badgeW, [single]$badgeH)
                $cornerRadius = [single][Math]::Max(3.0, $badgeH * 0.18)
                $path = New-RoundedRectPath -Rect $rect -Radius $cornerRadius
                try {
                    $fillBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(215, 24, 35, 50))
                    $borderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(245, 235, 240, 248), [single][Math]::Max(1.0, $source.Width * 0.012))
                    try {
                        $graphics.FillPath($fillBrush, $path)
                        $graphics.DrawPath($borderPen, $path)
                    }
                    finally {
                        $fillBrush.Dispose()
                        $borderPen.Dispose()
                    }
                }
                finally {
                    $path.Dispose()
                }

                $fontSize = [single][Math]::Max(8.0, $badgeH * $fontScale)
                $font = New-BadgeFont -FontSize $fontSize
                try {
                    Draw-OpticallyCenteredGlyph -Graphics $graphics -Rect $rect -Font $font -Text $BadgeText -OpticalOffsetX $glyphOpticalOffsetX -OpticalOffsetY $glyphOpticalOffsetY
                }
                finally {
                    $font.Dispose()
                }
            }
            finally {
                $graphics.Dispose()
            }

            $targetDir = Split-Path -Parent $targetPath
            if (-not (Test-Path $targetDir)) {
                New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
            }

            $bitmap.Save($targetPath, [System.Drawing.Imaging.ImageFormat]::Png)
            Write-Host "Generated: $relativeTarget"
        }
        finally {
            $bitmap.Dispose()
        }
    }
    finally {
        $source.Dispose()
    }
}

if ($script:PrivateFontCollection) {
    $script:PrivateFontCollection.Dispose()
}
