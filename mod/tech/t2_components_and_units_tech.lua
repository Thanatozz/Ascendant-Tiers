local component_unlocks = data.ascendant_tiers_t2_components or {
	productivity = { [1] = {}, [2] = {}, [3] = {} },
	energy = { [1] = {}, [2] = {}, [3] = {} },
	weaponry = { [1] = {}, [2] = {}, [3] = {} },
}

local unit_unlocks = data.ascendant_tiers_t2_robot_units or { [1] = {}, [2] = {}, [3] = {} }

local function stage_recipe(stage)
	if stage == 1 then
		return AscendantTiersCreateUplinkRecipe({ ascendant_tiers_metal_plate = 35 }, 140)
	elseif stage == 2 then
		return AscendantTiersCreateUplinkRecipe({ ascendant_tiers_reinforced_plate = 30 }, 190)
	end
	return AscendantTiersCreateUplinkRecipe({ ascendant_tiers_energized_plate = 25, ascendant_tiers_high_density_frame = 8 }, 260)
end

local function stage_progress(stage)
	if stage == 1 then return 10 end
	if stage == 2 then return 15 end
	return 20
end

local function unlock_icon_path(unlocks)
	local first = unlocks and unlocks[1]
	if not first then
		return "AscendantTiers/textures/icons/tech/ascendant_tiers_ii.png"
	end

	if first:sub(1, 2) == "c_" then
		return string.format("AscendantTiers/textures/icons/components/%s.png", first)
	end
	if first:sub(1, 2) == "f_" then
		return string.format("AscendantTiers/textures/icons/frame/%s.png", first)
	end
	return "AscendantTiers/textures/icons/tech/ascendant_tiers_ii.png"
end

local function tech_def(order, name, desc, requires, unlocks, stage)
	return {
		order = order,
		name = name,
		desc = desc,
		texture = unlock_icon_path(unlocks),
		uplink_recipe = stage_recipe(stage),
		progress_count = stage_progress(stage),
		require_tech = requires,
		category = "ascendant.tech.category.name",
		unlocks = unlocks,
	}
end

data.techs.tech_productivity_components_t2_1 = tech_def(
	1010,
	"ascendant.tech.productivity_components_t2_1.name",
	"ascendant.tech.productivity_components_t2_1.desc",
	{ "tech_ascendant_tiers_start" },
	component_unlocks.productivity[1],
	1
)

data.techs.tech_productivity_components_t2_2 = tech_def(
	1011,
	"ascendant.tech.productivity_components_t2_2.name",
	"ascendant.tech.productivity_components_t2_2.desc",
	{ "tech_productivity_components_t2_1", "tech_medium_buildings_t2" },
	component_unlocks.productivity[2],
	2
)

data.techs.tech_productivity_components_t2_3 = tech_def(
	1012,
	"ascendant.tech.productivity_components_t2_3.name",
	"ascendant.tech.productivity_components_t2_3.desc",
	{ "tech_productivity_components_t2_2", "tech_large_buildings_t2" },
	component_unlocks.productivity[3],
	3
)

data.techs.tech_energy_components_t2_1 = tech_def(
	1013,
	"ascendant.tech.energy_components_t2_1.name",
	"ascendant.tech.energy_components_t2_1.desc",
	{ "tech_ascendant_tiers_start" },
	component_unlocks.energy[1],
	1
)

data.techs.tech_energy_components_t2_2 = tech_def(
	1014,
	"ascendant.tech.energy_components_t2_2.name",
	"ascendant.tech.energy_components_t2_2.desc",
	{ "tech_energy_components_t2_1", "tech_medium_buildings_t2" },
	component_unlocks.energy[2],
	2
)

data.techs.tech_energy_components_t2_3 = tech_def(
	1015,
	"ascendant.tech.energy_components_t2_3.name",
	"ascendant.tech.energy_components_t2_3.desc",
	{ "tech_energy_components_t2_2", "tech_large_buildings_t2" },
	component_unlocks.energy[3],
	3
)

data.techs.tech_weaponry_components_t2_1 = tech_def(
	1016,
	"ascendant.tech.weaponry_components_t2_1.name",
	"ascendant.tech.weaponry_components_t2_1.desc",
	{ "tech_ascendant_tiers_start" },
	component_unlocks.weaponry[1],
	1
)

data.techs.tech_weaponry_components_t2_2 = tech_def(
	1017,
	"ascendant.tech.weaponry_components_t2_2.name",
	"ascendant.tech.weaponry_components_t2_2.desc",
	{ "tech_weaponry_components_t2_1", "tech_medium_buildings_t2" },
	component_unlocks.weaponry[2],
	2
)

data.techs.tech_weaponry_components_t2_3 = tech_def(
	1018,
	"ascendant.tech.weaponry_components_t2_3.name",
	"ascendant.tech.weaponry_components_t2_3.desc",
	{ "tech_weaponry_components_t2_2", "tech_large_buildings_t2" },
	component_unlocks.weaponry[3],
	3
)

data.techs.tech_robot_units_t2_1 = tech_def(
	1019,
	"ascendant.tech.robot_units_t2_1.name",
	"ascendant.tech.robot_units_t2_1.desc",
	{ "tech_ascendant_tiers_start" },
	unit_unlocks[1],
	1
)

data.techs.tech_robot_units_t2_2 = tech_def(
	1020,
	"ascendant.tech.robot_units_t2_2.name",
	"ascendant.tech.robot_units_t2_2.desc",
	{ "tech_robot_units_t2_1", "tech_medium_buildings_t2" },
	unit_unlocks[2],
	2
)

data.techs.tech_robot_units_t2_3 = tech_def(
	1021,
	"ascendant.tech.robot_units_t2_3.name",
	"ascendant.tech.robot_units_t2_3.desc",
	{ "tech_robot_units_t2_2", "tech_large_buildings_t2" },
	unit_unlocks[3],
	3
)
