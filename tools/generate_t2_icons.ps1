param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing

$baseGameRoot = Join-Path $RepoRoot "base-game"
$modRoot = Join-Path $RepoRoot "mod"
$fontRoot = Join-Path $RepoRoot "fonts"

# Requested visual rule:
# - top-right badge
# - 40% width / 40% height footprint
# - Roman numeral "II" using Roboto Slab SemiBold 600
$badgeScale = 0.40
$fontScale = 0.72
$marginScale = 0.025
$romanOpticalOffsetX = 0.0
$romanOpticalOffsetY = -0.5
$script:PrivateFontCollection = $null
$script:PreferredFontFamily = $null

$mappings = @(
    # Existing modular T2 frame icons
    @{ SourceRelative = "textures/icons/frame/building_1x1_c.png";  TargetRelative = "textures/icons/frame/building_1x1_4s_t2.png" },
    @{ SourceRelative = "textures/icons/frame/building_1x1_d.png";  TargetRelative = "textures/icons/frame/building_1x1_2s_t2.png" },
    @{ SourceRelative = "textures/icons/frame/building_1x1_f.png";  TargetRelative = "textures/icons/frame/storage_16_t2.png" },
    @{ SourceRelative = "textures/icons/frame/building_1x1_g.png";  TargetRelative = "textures/icons/frame/storage_32_t2.png" },
    @{ SourceRelative = "textures/icons/frame/building_1x1_e.png";  TargetRelative = "textures/icons/frame/storage_48_t2.png" },
    @{ SourceRelative = "textures/icons/frame/Building_1x1_A.png";  TargetRelative = "textures/icons/frame/building_1x1_2m_t2.png" },
    @{ SourceRelative = "textures/icons/frame/building_1x1_h.png";  TargetRelative = "textures/icons/frame/building_1x1_2m_defense_t2.png" },
    @{ SourceRelative = "textures/icons/frame/Building_1x1_B.png";  TargetRelative = "textures/icons/frame/building_1x1_2l_t2.png" },
    @{ SourceRelative = "textures/icons/frame/building_2x1_a.png";  TargetRelative = "textures/icons/frame/building_2x1_4m_basic_t2.png" },
    @{ SourceRelative = "textures/icons/frame/building_2x1_c.png";  TargetRelative = "textures/icons/frame/building_2x1_4m_t2.png" },
    @{ SourceRelative = "textures/icons/frame/building_2x1_d.png";  TargetRelative = "textures/icons/frame/building_2x1_2m_storage_t2.png" },
    @{ SourceRelative = "textures/icons/frame/building_2x1_e.png";  TargetRelative = "textures/icons/frame/building_2x1_4s2m_t2.png" },
    @{ SourceRelative = "textures/icons/frame/building_2x1_f.png";  TargetRelative = "textures/icons/frame/building_2x1_2m2s_t2.png" },
    @{ SourceRelative = "textures/icons/frame/building_2x1_g.png";  TargetRelative = "textures/icons/frame/building_2x1_2m_compact_t2.png" },
    @{ SourceRelative = "textures/icons/frame/building_2x1_b.png";  TargetRelative = "textures/icons/frame/building_2x1_2m2l_t2.png" },
    @{ SourceRelative = "textures/icons/frame/building_2x2_e.png";  TargetRelative = "textures/icons/frame/building_2x2_2m6s_t2.png" },
    @{ SourceRelative = "textures/icons/frame/Building_2x2_A.png";  TargetRelative = "textures/icons/frame/building_2x2_4m2l_t2.png" },
    @{ SourceRelative = "textures/icons/frame/building_2x2_F.png";  TargetRelative = "textures/icons/frame/building_2x2_4m_t2.png" },
    @{ SourceRelative = "textures/icons/frame/Building_2x2_B.png";  TargetRelative = "textures/icons/frame/building_2x2_6m_t2.png" },
    @{ SourceRelative = "textures/icons/frame/building_2x2_c.png";  TargetRelative = "textures/icons/frame/building_2x2_4m2l_a_t2.png" },
    @{ SourceRelative = "textures/icons/frame/building_2x2_d.png";  TargetRelative = "textures/icons/frame/building_2x2_4m2l_b_t2.png" },
    @{ SourceRelative = "textures/icons/frame/building_3x2_a.png";  TargetRelative = "textures/icons/frame/building_3x2_2l6m_t2.png" },
    @{ SourceRelative = "textures/icons/frame/building_3x2_B.png";  TargetRelative = "textures/icons/frame/building_3x2_4m4s_t2.png" },

    # Component T2 icons: Productivity
    @{ SourceRelative = "textures/icons/components/Component_Miner_01_S.png";             TargetRelative = "textures/icons/components/c_miner_t2.png" },
    @{ SourceRelative = "textures/icons/components/Component_Miner_02_S.png";             TargetRelative = "textures/icons/components/c_adv_miner_t2.png" },
    @{ SourceRelative = "textures/icons/components/Component_Storage_01_S.png";           TargetRelative = "textures/icons/components/c_small_storage_t2.png" },
    @{ SourceRelative = "textures/icons/components/Component_Storage_01_M.png";           TargetRelative = "textures/icons/components/c_medium_storage_t2.png" },
    @{ SourceRelative = "textures/icons/components/Component_LargeStorage_01_L.png";      TargetRelative = "textures/icons/components/c_large_storage_t2.png" },
    @{ SourceRelative = "textures/icons/components/Component_Repairer_01_M.png";          TargetRelative = "textures/icons/components/c_repairer_t2.png" },
    @{ SourceRelative = "textures/icons/components/repairkit.png";                        TargetRelative = "textures/icons/components/c_repairkit_t2.png" },
    @{ SourceRelative = "textures/icons/components/Component_Repairer_01_S_aoe.png";      TargetRelative = "textures/icons/components/c_repairer_small_aoe_t2.png" },
    @{ SourceRelative = "textures/icons/components/Component_Repairer_01_M_aoe.png";      TargetRelative = "textures/icons/components/c_repairer_aoe_t2.png" },
    @{ SourceRelative = "textures/icons/components/portable_shieldgenerator_purple.png";  TargetRelative = "textures/icons/components/c_shield_generator_t2.png" },
    @{ SourceRelative = "textures/icons/components/portable_shieldgenerator.png";         TargetRelative = "textures/icons/components/c_shield_generator2_t2.png" },
    @{ SourceRelative = "textures/icons/components/portable_shieldgenerator_red.png";     TargetRelative = "textures/icons/components/c_shield_generator3_t2.png" },

    # Component T2 icons: Energy
    @{ SourceRelative = "textures/icons/components/component_crystalpower_01_s.png";      TargetRelative = "textures/icons/components/c_crystal_power_t2.png" },
    @{ SourceRelative = "textures/icons/components/component_light_01_s.png";             TargetRelative = "textures/icons/components/c_light_t2.png" },
    @{ SourceRelative = "textures/icons/components/component_light_02_s.png";             TargetRelative = "textures/icons/components/c_light_rgb_t2.png" },
    @{ SourceRelative = "textures/icons/components/powerrelay.png";                       TargetRelative = "textures/icons/components/c_portable_relay_t2.png" },
    @{ SourceRelative = "textures/icons/components/Component_PowerRelay_01_S.png";        TargetRelative = "textures/icons/components/c_small_relay_t2.png" },
    @{ SourceRelative = "textures/icons/components/Component_SolarPanel_01_S.png";        TargetRelative = "textures/icons/components/c_solar_cell_t2.png" },
    @{ SourceRelative = "textures/icons/components/component_capacitor_01_s.png";         TargetRelative = "textures/icons/components/c_small_battery_t2.png" },
    @{ SourceRelative = "textures/icons/components/capacitor.png";                        TargetRelative = "textures/icons/components/c_capacitor_t2.png" },
    @{ SourceRelative = "textures/icons/components/Component_WindTurbine_01_M.png";       TargetRelative = "textures/icons/components/c_wind_turbine_t2.png" },
    @{ SourceRelative = "textures/icons/components/component_crystalbattery_01_m.png";    TargetRelative = "textures/icons/components/c_medium_capacitor_t2.png" },
    @{ SourceRelative = "textures/icons/components/Component_PowerRelay_01_M.png";        TargetRelative = "textures/icons/components/c_power_relay_t2.png" },
    @{ SourceRelative = "textures/icons/components/Component_WindTurbine_01_M.png";       TargetRelative = "textures/icons/components/c_wind_turbine_l_t2.png" },
    @{ SourceRelative = "textures/icons/components/Component_PowerTransmitter_01_M.png";  TargetRelative = "textures/icons/components/c_power_transmitter_t2.png" },
    @{ SourceRelative = "textures/icons/components/Component_Battery_01_M.png";           TargetRelative = "textures/icons/components/c_battery_t2.png" },
    @{ SourceRelative = "textures/icons/components/Component_SolarPanel_01_M.png";        TargetRelative = "textures/icons/components/c_solar_panel_t2.png" },
    @{ SourceRelative = "textures/icons/components/component_powercore_01_l.png";         TargetRelative = "textures/icons/components/c_power_core_t2.png" },
    @{ SourceRelative = "textures/icons/components/powercell.png";                        TargetRelative = "textures/icons/components/c_power_cell_t2.png" },
    @{ SourceRelative = "textures/icons/components/Component_PowerTransmitter_01_M.png";  TargetRelative = "textures/icons/components/c_large_power_transmitter_t2.png" },

    # Component T2 icons: Weaponry
    @{ SourceRelative = "textures/icons/components/Component_StarterTurret_01_S.png";     TargetRelative = "textures/icons/components/c_portable_turret_t2.png" },
    @{ SourceRelative = "textures/icons/components/component_melee_pulse.png";            TargetRelative = "textures/icons/components/c_melee_pulse_t2.png" },
    @{ SourceRelative = "textures/icons/components/Component_PulseLasers_01_M.png";       TargetRelative = "textures/icons/components/c_pulselasers_t2.png" },
    @{ SourceRelative = "textures/icons/components/Component_AdvancedTurret_01_S.png";    TargetRelative = "textures/icons/components/c_adv_portable_turret_t2.png" },
    @{ SourceRelative = "textures/icons/components/Component_PulseDisrupter_01_M.png";    TargetRelative = "textures/icons/components/c_pulse_disrupter_t2.png" },
    @{ SourceRelative = "textures/icons/components/component_standardTurret_01_m.png";    TargetRelative = "textures/icons/components/c_turret_t2.png" },
    @{ SourceRelative = "textures/icons/components/Component_PhotonCannon_01_M.png";      TargetRelative = "textures/icons/components/c_photon_cannon_t2.png" },
    @{ SourceRelative = "textures/icons/components/Component_PhotonBeam_01_M.png";        TargetRelative = "textures/icons/components/c_photon_beam_t2.png" },
    @{ SourceRelative = "textures/icons/components/Component_ViralPulse_01_S.png";        TargetRelative = "textures/icons/components/c_viral_pulse_t2.png" },
    @{ SourceRelative = "textures/icons/components/component_laserturret_01_m.png";       TargetRelative = "textures/icons/components/c_laser_turret_t2.png" },
    @{ SourceRelative = "textures/icons/components/Component_PlasmaCannon_01_M.png";      TargetRelative = "textures/icons/components/c_plasma_cannon_t2.png" },

    # Robot unit T2 icons
    @{ SourceRelative = "textures/icons/frame/carrier_bot.png";                           TargetRelative = "textures/icons/frame/f_carrier_bot_t2.png" },
    @{ SourceRelative = "textures/icons/frame/bot_1s_a.png";                              TargetRelative = "textures/icons/frame/f_bot_1s_a_t2.png" },
    @{ SourceRelative = "textures/icons/frame/bot_1s_b.png";                              TargetRelative = "textures/icons/frame/f_bot_1s_b_t2.png" },
    @{ SourceRelative = "textures/icons/frame/bot_2s_a.png";                              TargetRelative = "textures/icons/frame/f_bot_2s_t2.png" },
    @{ SourceRelative = "textures/icons/frame/bot_1m_a.png";                              TargetRelative = "textures/icons/frame/f_bot_1m_a_t2.png" },
    @{ SourceRelative = "textures/icons/frame/transport_bot.png";                         TargetRelative = "textures/icons/frame/f_transport_bot_t2.png" },
    @{ SourceRelative = "textures/icons/frame/bot_1m1s_a.png";                            TargetRelative = "textures/icons/frame/f_bot_1m1s_t2.png" },
    @{ SourceRelative = "textures/icons/frame/bot_1m_b.png";                              TargetRelative = "textures/icons/frame/f_bot_1m_b_t2.png" },
    @{ SourceRelative = "textures/icons/frame/bot_1l_a.png";                              TargetRelative = "textures/icons/frame/f_bot_1l_a_t2.png" },
    @{ SourceRelative = "textures/icons/frame/bot_1m_c.png";                              TargetRelative = "textures/icons/frame/f_bot_1m_c_t2.png" },
    @{ SourceRelative = "textures/icons/frame/bot_1s_ad.png";                             TargetRelative = "textures/icons/frame/f_bot_1s_as_t2.png" },
    @{ SourceRelative = "textures/icons/frame/bot_1s_adw.png";                            TargetRelative = "textures/icons/frame/f_bot_1s_adw_t2.png" },
    @{ SourceRelative = "textures/icons/frame/bot_2m_ad.png";                             TargetRelative = "textures/icons/frame/f_bot_2m_as_t2.png" }
)

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

    # Primary requirement: local RobotoSlab-SemiBold.ttf from /fonts (repo root)
    if ($script:PreferredFontFamily) {
        try {
            return New-Object System.Drawing.Font($script:PreferredFontFamily, $FontSize, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
        }
        catch {}
    }

    # Secondary requirement: installed Roboto Slab SemiBold 600
    try {
        return New-Object System.Drawing.Font("Roboto Slab SemiBold", $FontSize, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
    }
    catch {}

    # Secondary fallback: Roboto Slab family in bold (closest available GDI style to 600)
    try {
        return New-Object System.Drawing.Font("Roboto Slab", $FontSize, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
    }
    catch {}

    # Final fallback for systems without Roboto Slab installed
    return New-Object System.Drawing.Font("Segoe UI Semibold", $FontSize, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
}

function Draw-OpticallyCenteredRoman {
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

        # Optical centering based on glyph outlines (not text line box).
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

foreach ($map in $mappings) {
    $sourcePath = Join-Path $baseGameRoot $map.SourceRelative
    $targetPath = Join-Path $modRoot $map.TargetRelative
    $targetDir = Split-Path $targetPath -Parent
    if (-not (Test-Path $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    }

    if (-not (Test-Path $sourcePath)) {
        throw "Missing source icon: $sourcePath"
    }

    $source = [System.Drawing.Image]::FromFile($sourcePath)
    try {
        $bitmap = New-Object System.Drawing.Bitmap($source.Width, $source.Height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        try {
            $g = [System.Drawing.Graphics]::FromImage($bitmap)
            try {
                $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
                $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
                $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

                $g.DrawImage($source, 0, 0, $source.Width, $source.Height)

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
                        $g.FillPath($fillBrush, $path)
                        $g.DrawPath($borderPen, $path)
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
                    $text = "II"
                    Draw-OpticallyCenteredRoman -Graphics $g -Rect $rect -Font $font -Text $text -OpticalOffsetX $romanOpticalOffsetX -OpticalOffsetY $romanOpticalOffsetY
                }
                finally {
                    $font.Dispose()
                }
            }
            finally {
                $g.Dispose()
            }

            $bitmap.Save($targetPath, [System.Drawing.Imaging.ImageFormat]::Png)
            Write-Host "Generated: $($map.TargetRelative)"
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
