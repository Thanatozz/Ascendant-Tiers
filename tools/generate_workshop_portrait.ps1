param(
    [string]$OutputPath = (Join-Path $PSScriptRoot "AscendantTiers.png"),
    [int]$Width = 768,
    [int]$Height = 768,
    [string]$RomanText = "II"
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$fontRoot = Join-Path $repoRoot "fonts"
$script:PrivateFontCollection = $null
$script:RomanFontFamily = $null

function Initialize-RomanFontFamily {
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
            $script:RomanFontFamily = $family
            Write-Host "Using local font file for roman text: $fontFile"
            return
        }

        $pfc.Dispose()
        Write-Warning "Could not resolve font family from $fontFile. Falling back to installed fonts."
    }
    catch {
        Write-Warning "Failed to load local font file $fontFile. Falling back to installed fonts. Error: $($_.Exception.Message)"
    }
}

function New-RomanFont {
    param(
        [single]$FontSize
    )

    if ($script:RomanFontFamily) {
        try {
            return New-Object System.Drawing.Font($script:RomanFontFamily, $FontSize, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
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

    return New-Object System.Drawing.Font("Segoe UI Black", $FontSize, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
}

function Get-TextGlyphBounds {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text,
        [Parameter(Mandatory = $true)]
        [System.Drawing.Font]$Font
    )

    $fmt = New-Object System.Drawing.StringFormat
    $fmt.FormatFlags = [System.Drawing.StringFormatFlags]::NoClip
    $fmt.Alignment = [System.Drawing.StringAlignment]::Near
    $fmt.LineAlignment = [System.Drawing.StringAlignment]::Near

    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    try {
        $path.AddString($Text, $Font.FontFamily, [int]$Font.Style, $Font.Size, (New-Object System.Drawing.PointF(0.0, 0.0)), $fmt)
        return $path.GetBounds()
    }
    finally {
        $path.Dispose()
        $fmt.Dispose()
    }
}

function Draw-OpticallyCenteredText {
    param(
        [Parameter(Mandatory = $true)]
        [System.Drawing.Graphics]$Graphics,
        [Parameter(Mandatory = $true)]
        [string]$Text,
        [Parameter(Mandatory = $true)]
        [System.Drawing.Font]$Font,
        [Parameter(Mandatory = $true)]
        [System.Drawing.SolidBrush]$Brush,
        [Parameter(Mandatory = $true)]
        [System.Drawing.SolidBrush]$ShadowBrush,
        [Parameter(Mandatory = $true)]
        [single]$CenterX,
        [Parameter(Mandatory = $true)]
        [single]$CenterY,
        [single]$OpticalOffsetX = 0,
        [single]$OpticalOffsetY = 0,
        [single]$ShadowOffsetX = 4,
        [single]$ShadowOffsetY = 6
    )

    $fmt = New-Object System.Drawing.StringFormat
    $fmt.FormatFlags = [System.Drawing.StringFormatFlags]::NoClip
    $fmt.Alignment = [System.Drawing.StringAlignment]::Near
    $fmt.LineAlignment = [System.Drawing.StringAlignment]::Near

    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    try {
        $path.AddString($Text, $Font.FontFamily, [int]$Font.Style, $Font.Size, (New-Object System.Drawing.PointF(0.0, 0.0)), $fmt)
        $bounds = $path.GetBounds()

        $targetCenterX = [single]($CenterX + $OpticalOffsetX)
        $targetCenterY = [single]($CenterY + $OpticalOffsetY)
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
                $shadowTransform.Translate($ShadowOffsetX, $ShadowOffsetY)
                $shadowPath.Transform($shadowTransform)
            }
            finally {
                $shadowTransform.Dispose()
            }

            $Graphics.FillPath($ShadowBrush, $shadowPath)
            $Graphics.FillPath($Brush, $path)
        }
        finally {
            $shadowPath.Dispose()
        }
    }
    finally {
        $path.Dispose()
        $fmt.Dispose()
    }
}

$bitmap = New-Object System.Drawing.Bitmap($Width, $Height)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)

try {
    Initialize-RomanFontFamily

    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

    $bgRect = New-Object System.Drawing.Rectangle -ArgumentList @(0, 0, $Width, $Height)
    $bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        $bgRect,
        [System.Drawing.Color]::FromArgb(255, 16, 35, 68),
        [System.Drawing.Color]::FromArgb(255, 52, 79, 126),
        25
    )
    try {
        $graphics.FillRectangle($bgBrush, $bgRect)
    }
    finally {
        $bgBrush.Dispose()
    }

    $outerBorder = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(230, 235, 198, 120), 7)
    $innerBorder = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(220, 153, 178, 211), 2)
    try {
        $graphics.DrawRectangle($outerBorder, 8, 8, $Width - 16, $Height - 16)
        $graphics.DrawRectangle($innerBorder, 22, 22, $Width - 44, $Height - 44)
    }
    finally {
        $outerBorder.Dispose()
        $innerBorder.Dispose()
    }

    $ascendantFont = New-Object System.Drawing.Font("Segoe UI Black", 104, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
    $tiersFont = New-Object System.Drawing.Font("Segoe UI Black", 118, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
    $romanFont = New-RomanFont -FontSize 246
    $ascendantBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(245, 245, 245))
    $tiersBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 198, 90))
    $romanBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(112, 197, 233))
    $shadowBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(160, 4, 16, 40))

    try {
        $line1Height = [single][math]::Ceiling((Get-TextGlyphBounds -Text "Ascendant" -Font $ascendantFont).Height)
        $line2Height = [single][math]::Ceiling((Get-TextGlyphBounds -Text "Tiers" -Font $tiersFont).Height)
        $line3Height = [single][math]::Ceiling((Get-TextGlyphBounds -Text $RomanText -Font $romanFont).Height)

        $gap12 = 6
        $gap23 = 18
        $groupHeight = $line1Height + $gap12 + $line2Height + $gap23 + $line3Height
        $startY = [single][math]::Floor(($Height - $groupHeight) / 2.0)

        $line1Top = $startY
        $line2Top = [single]($line1Top + $line1Height + $gap12)
        $line3Top = [single]($line2Top + $line2Height + $gap23)

        $centerX = [single]($Width / 2.0)
        $line1CenterY = [single]($line1Top + ($line1Height / 2.0))
        $line2CenterY = [single]($line2Top + ($line2Height / 2.0))
        $line3CenterY = [single]($line3Top + ($line3Height / 2.0))

        Draw-OpticallyCenteredText -Graphics $graphics -Text "Ascendant" -Font $ascendantFont -Brush $ascendantBrush -ShadowBrush $shadowBrush -CenterX $centerX -CenterY $line1CenterY
        Draw-OpticallyCenteredText -Graphics $graphics -Text "Tiers" -Font $tiersFont -Brush $tiersBrush -ShadowBrush $shadowBrush -CenterX $centerX -CenterY $line2CenterY
        Draw-OpticallyCenteredText -Graphics $graphics -Text $RomanText -Font $romanFont -Brush $romanBrush -ShadowBrush $shadowBrush -CenterX $centerX -CenterY $line3CenterY
    }
    finally {
        $ascendantFont.Dispose()
        $tiersFont.Dispose()
        $romanFont.Dispose()
        $ascendantBrush.Dispose()
        $tiersBrush.Dispose()
        $romanBrush.Dispose()
        $shadowBrush.Dispose()
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
    if ($script:PrivateFontCollection) {
        $script:PrivateFontCollection.Dispose()
    }
}

Write-Host "[OK] Workshop portrait generated:" $OutputPath
