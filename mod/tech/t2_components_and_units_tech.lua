local component_unlocks = data.ascendant_tiers_t2_components or {
	productivity = { [1] = {}, [2] = {}, [3] = {} },
	energy = { [1] = {}, [2] = {}, [3] = {} },
	weaponry = { [1] = {}, [2] = {}, [3] = {} },
}

local unit_unlocks = data.ascendant_tiers_t2_robot_units or { [1] = {}, [2] = {}, [3] = {} }

local function stage_recipe(stage)
	if stage == 1 then
		return CreateUplinkRecipe({ ascendant_tiers_metal_plate = 35 }, 140)
	elseif stage == 2 then
		return CreateUplinkRecipe({ ascendant_tiers_reinforced_plate = 30 }, 190)
	end
	return CreateUplinkRecipe({ ascendant_tiers_energized_plate = 25, ascendant_tiers_high_density_frame = 8 }, 260)
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
		category = "Ascendant Tiers",
		unlocks = unlocks,
	}
end

data.techs.tech_productivity_components_t2_1 = tech_def(
	1010,
	"Productivity Components T2 I",
	"Ascendant Tiers Stage I upgrades for mining, storage, repair, and shield utility components.",
	{ "tech_ascendant_tiers_start" },
	component_unlocks.productivity[1],
	1
)

data.techs.tech_productivity_components_t2_2 = tech_def(
	1011,
	"Productivity Components T2 II",
	"Ascendant Tiers Stage II upgrades for expanded productivity component sets.",
	{ "tech_productivity_components_t2_1", "tech_medium_buildings_t2" },
	component_unlocks.productivity[2],
	2
)

data.techs.tech_productivity_components_t2_3 = tech_def(
	1012,
	"Productivity Components T2 III",
	"Ascendant Tiers Stage III upgrades for high-end productivity component systems.",
	{ "tech_productivity_components_t2_2", "tech_large_buildings_t2" },
	component_unlocks.productivity[3],
	3
)

data.techs.tech_energy_components_t2_1 = tech_def(
	1013,
	"Energy Components T2 I",
	"Ascendant Tiers Stage I energy component upgrades for baseline production, lighting, and relay systems.",
	{ "tech_ascendant_tiers_start" },
	component_unlocks.energy[1],
	1
)

data.techs.tech_energy_components_t2_2 = tech_def(
	1014,
	"Energy Components T2 II",
	"Ascendant Tiers Stage II energy upgrades for improved transmission and mid-tier power systems.",
	{ "tech_energy_components_t2_1", "tech_medium_buildings_t2" },
	component_unlocks.energy[2],
	2
)

data.techs.tech_energy_components_t2_3 = tech_def(
	1015,
	"Energy Components T2 III",
	"Ascendant Tiers Stage III energy upgrades for dense storage and high-output power cores.",
	{ "tech_energy_components_t2_2", "tech_large_buildings_t2" },
	component_unlocks.energy[3],
	3
)

data.techs.tech_weaponry_components_t2_1 = tech_def(
	1016,
	"Weaponry Components T2 I",
	"Ascendant Tiers Stage I weapon upgrades for portable and close-range bot armaments.",
	{ "tech_ascendant_tiers_start" },
	component_unlocks.weaponry[1],
	1
)

data.techs.tech_weaponry_components_t2_2 = tech_def(
	1017,
	"Weaponry Components T2 II",
	"Ascendant Tiers Stage II weapon upgrades for medium-range and turret-grade combat systems.",
	{ "tech_weaponry_components_t2_1", "tech_medium_buildings_t2" },
	component_unlocks.weaponry[2],
	2
)

data.techs.tech_weaponry_components_t2_3 = tech_def(
	1018,
	"Weaponry Components T2 III",
	"Ascendant Tiers Stage III weapon upgrades for advanced beam, viral, and plasma systems.",
	{ "tech_weaponry_components_t2_2", "tech_large_buildings_t2" },
	component_unlocks.weaponry[3],
	3
)

data.techs.tech_robot_units_t2_1 = tech_def(
	1019,
	"Robot Units T2 I",
	"Ascendant Tiers Stage I robot-unit upgrades for foundational worker and cargo platforms.",
	{ "tech_ascendant_tiers_start" },
	unit_unlocks[1],
	1
)

data.techs.tech_robot_units_t2_2 = tech_def(
	1020,
	"Robot Units T2 II",
	"Ascendant Tiers Stage II robot-unit upgrades for expanded mid-tier logistics and operations bots.",
	{ "tech_robot_units_t2_1", "tech_medium_buildings_t2" },
	unit_unlocks[2],
	2
)

data.techs.tech_robot_units_t2_3 = tech_def(
	1021,
	"Robot Units T2 III",
	"Ascendant Tiers Stage III robot-unit upgrades for elite command and specialist bot chassis.",
	{ "tech_robot_units_t2_2", "tech_large_buildings_t2" },
	unit_unlocks[3],
	3
)
