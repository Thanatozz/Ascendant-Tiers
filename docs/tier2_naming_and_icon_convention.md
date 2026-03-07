# Tier 2 Naming and Icon Convention

This document defines the standard for **all modular building Tier 2 variants** in this mod.

## Naming Rules

- Visible name suffix: ` [T2]`
- Internal ID suffix: `_t2`
- Applies only to new upgraded modular variants (not vanilla entries)

Examples:

- `Building 1x1 (4S) [T2]`
- `Storage Block (32) [T2]`
- `f_building1x1_4s_t2`
- `f_storage32_t2`

## Icon Rules

- Use baked icon variants (no runtime overlay assumptions)
- Base must remain the original vanilla icon
- Add a Tier 2 badge at top-right
- Badge footprint: **40% width x 40% height** of the icon
- Badge text: **Roman numeral `II`** using **Roboto Slab SemiBold 600**
  from `fonts/RobotoSlab-SemiBold.ttf` (fallback only if file is unavailable)
- Roman numeral placement uses **optical centering** (glyph-outline centering), not plain text-box centering
- Keep the original icon identity intact

## File Location and Naming

- Output folder: `mod/textures/icons/frame/`
- File suffix: `_t2.png`

Current Tier 2 modular icon targets:

- `building_1x1_4s_t2.png`
- `building_1x1_2s_t2.png`
- `storage_16_t2.png`
- `building_1x1_2m_t2.png`
- `building_1x1_2m_defense_t2.png`
- `storage_32_t2.png`
- `storage_48_t2.png`
- `building_1x1_2l_t2.png`
- `building_2x1_4m_basic_t2.png`
- `building_2x1_4m_t2.png`
- `building_2x1_2m_storage_t2.png`
- `building_2x1_4s2m_t2.png`
- `building_2x1_2m2s_t2.png`
- `building_2x1_2m_compact_t2.png`
- `building_2x1_2m2l_t2.png`
- `building_2x2_2m6s_t2.png`
- `building_2x2_4m_t2.png`
- `building_2x2_4m2l_t2.png`
- `building_2x2_6m_t2.png`
- `building_2x2_4m2l_a_t2.png`
- `building_2x2_4m2l_b_t2.png`
- `building_3x2_2l6m_t2.png`
- `building_3x2_4m4s_t2.png`

## Technology Grouping

All modular building Tier 2 unlocks are grouped under these custom technologies:

- `tech_small_buildings_t2`
- `tech_medium_buildings_t2`
- `tech_large_buildings_t2`

## Generation Pipeline

Use the provided script to regenerate all T2 icons:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\generate_t2_icons.ps1
```
