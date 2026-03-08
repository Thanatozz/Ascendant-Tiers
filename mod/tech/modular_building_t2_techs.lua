local building_unlocks = data.ascendant_tiers_t2_buildings or {
	[1] = {},
	[2] = {},
	[3] = {},
	[4] = {},
}

local function merge_unlocks(stage_ids, extra_ids)
	local unlocks = {}

	if type(stage_ids) == "table" then
		for _, id in ipairs(stage_ids) do
			table.insert(unlocks, id)
		end
	end

	if type(extra_ids) == "table" then
		for _, id in ipairs(extra_ids) do
			table.insert(unlocks, id)
		end
	end

	return unlocks
end

data.techs.tech_small_buildings_t2 = {
	order = 1001,
	name = "Early Tier 2",
	desc = "Tier 2 early building upgrades with complete 1x1 and compact 2x1 progression.",
	texture = "AscendantTiers/textures/icons/frame/building_1x1_4s_t2.png",
	uplink_recipe = CreateUplinkRecipe({ metalplate = 60 }, 140),
	progress_count = 10,
	require_tech = { "tech_ascendant_tiers_start" },
	category = "Ascendant Tiers",
	unlocks = merge_unlocks(building_unlocks[1], {
		"ascendant_tiers_metal_plate",
		"ascendant_tiers_circuit_board",
		"ascendant_tiers_reinforced_plate",
	}),
}

data.techs.tech_medium_buildings_t2 = {
	order = 1002,
	name = "Medium Buildings T2",
	desc = "Tier 2 midline building upgrades for expanded 2x1/2x2 and utility frame coverage.",
	texture = "AscendantTiers/textures/icons/frame/building_2x2_6m_t2.png",
	uplink_recipe = CreateUplinkRecipe({ ascendant_tiers_reinforced_plate = 50 }, 170),
	progress_count = 10,
	require_tech = { "tech_small_buildings_t2" },
	category = "Ascendant Tiers",
	unlocks = merge_unlocks(building_unlocks[2], {
		"ascendant_tiers_energized_plate",
	}),
}

data.techs.tech_large_buildings_t2 = {
	order = 1003,
	name = "Large Buildings T2",
	desc = "Tier 2 large-frame upgrades for high-capacity layouts and advanced structural variants.",
	texture = "AscendantTiers/textures/icons/frame/building_2x1_2m2l_t2.png",
	uplink_recipe = CreateUplinkRecipe({ ascendant_tiers_energized_plate = 45 }, 200),
	progress_count = 10,
	require_tech = { "tech_medium_buildings_t2" },
	category = "Ascendant Tiers",
	unlocks = merge_unlocks(building_unlocks[3], {
		"ascendant_tiers_ic_chip",
		"ascendant_tiers_high_density_frame",
	}),
}

data.techs.tech_epic_buildings_t2 = {
	order = 1004,
	name = "Epic Buildings T2",
	desc = "Tier 2 endgame building upgrades for elite modular frame configurations.",
	texture = "AscendantTiers/textures/icons/frame/building_3x2_2l6m_t2.png",
	uplink_recipe = CreateUplinkRecipe({ ascendant_tiers_energized_plate = 80, ascendant_tiers_high_density_frame = 16 }, 240),
	progress_count = 10,
	require_tech = { "tech_large_buildings_t2" },
	category = "Ascendant Tiers",
	unlocks = merge_unlocks(building_unlocks[4]),
}
