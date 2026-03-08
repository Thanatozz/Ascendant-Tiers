# Ascendant Tiers

Tier 2 expansion mod focused on modular progression for buildings, components, and robot frames.

It adds complete T2 upgrade paths with new materials, staged tech unlocks, updated recipes, and T2 stat scaling for key systems (energy, storage, mining, repair, shield, and combat).

## Workshop Description (Copy/Paste)

Ascendant Tiers extends the vanilla progression with full Tier 2 content:

- T2 modular building frames (small, medium, large, epic)
- T2 components across productivity, energy, and weaponry
- T2 robot unit frames
- New T2 crafting materials and tech progression
- Updated T2 descriptions with stat-aware values and T2 tags

Includes a save-friendly unlock helper in the pause menu for older saves.

## Features

### 1. T2 Materials

- `ascendant_tiers_metal_plate`
- `ascendant_tiers_reinforced_plate`
- `ascendant_tiers_energized_plate`
- `ascendant_tiers_high_density_frame`
- `ascendant_tiers_circuit_board`
- `ascendant_tiers_ic_chip`

### 2. T2 Building Progression

Four staged tech branches:

1. `tech_small_buildings_t2`
2. `tech_medium_buildings_t2`
3. `tech_large_buildings_t2`
4. `tech_epic_buildings_t2`

### 3. T2 Components

Three staged branches:

- Productivity (`tech_productivity_components_t2_1/2/3`)
- Energy (`tech_energy_components_t2_1/2/3`)
- Weaponry (`tech_weaponry_components_t2_1/2/3`)

### 4. T2 Robot Units

Three staged branches:

- `tech_robot_units_t2_1`
- `tech_robot_units_t2_2`
- `tech_robot_units_t2_3`

### 5. Description and UI Improvements

- Centralized override file for T2 descriptions:
  - `mod/descriptions/t2_description_overrides.lua`
- T2 description prefix enforcement (`[T2]`)
- Stat-aware description text for major energy/storage components

## Installation

1. Subscribe/install the mod.
2. Enable it in your mod list.
3. Load a save.

If the save started before the mod was installed:

1. Open pause menu.
2. Use the `Unlock Ascendant Tiers tech` button.

## Balance Notes

- T2 upgrades are role-focused, not universal "double everything".
- Recipes are remapped to T2 materials where appropriate.
- Example special recipe override:
  - `c_portable_relay_t2` uses `5 ascendant_tiers_metal_plate` (instead of `10 metalbar`).

## Compatibility

- Designed as an additive progression mod.
- Safe with most content mods that do not hard-overwrite the same T2 ids.
- If another mod edits the same ids (`c_*_t2`, `f_*_t2`, `tech_*_t2`), load order may matter.

## Project Structure

```text
mod/
  data.lua
  def.json
  options.lua
  ui.lua
  items/
    mod_material_progression.lua
  components/
    t2_component_variants.lua
  frames/
    modular_building_upgrades.lua
    t2_robot_unit_variants.lua
  descriptions/
    t2_description_overrides.lua
  tech/
    create.lua
    modular_building_t2_techs.lua
    t2_components_and_units_tech.lua
```

## Troubleshooting

### T2 tech does not appear

- Use the pause-menu unlock button.
- Verify the mod is enabled in the current profile/save.

### Description numbers look wrong

- Check `mod/descriptions/t2_description_overrides.lua`.
- Confirm your energy multiplier setup if your gameplay uses custom assembly/reassembly multipliers.

## Versioning

Current package version in `def.json`:

- `version_name`: `0.1.0`
- `version_code`: `1`

