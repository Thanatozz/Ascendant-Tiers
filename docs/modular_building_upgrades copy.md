local function add_unlock(tech_id, frame_id)
	local tech = data.techs[tech_id]
	if tech and tech.unlocks then
		table.insert(tech.unlocks, frame_id)
	end
end

-- 1x1 (2S) -> 1x1 (4S) [T2]
add_unlock("t_structures2", "f_building1x1_4s_t2")
Frame:RegisterFrame("f_building1x1_4s_t2", {
	size = "Small", race = "robot", name = "Building 1x1 (4S) [T2]",
	desc = "Extended 1x1 modular frame with four small sockets.",
	minimap_color = { 0.8, 0.8, 0.8 },
	visibility_range = 15,
	slots = { storage = 2 },
	health_points = 140,
	texture = "AscendantTiers/textures/icons/frame/building_1x1_4s_t2.png",
	construction_recipe = CreateConstructionRecipe({ reinforced_plate = 10, circuit_board = 6, energized_plate = 4 }, 90),
	trigger_channels = "building",
	visual = "v_base1x1_4s_t2",
})

data.visuals.v_base1x1_4s_t2 = {
	mesh = "StaticMesh'/Game/Meshes/RobotBuildings/Building_1x1_C.Building_1x1_C'",
	placement = "Max",
	tile_size = { 1, 1 },
	sockets = {
		{ "small1", "Small" },
		{ "small2", "Small" },
		{ "small1", "Small" },
		{ "small2", "Small" },
		{ "", "Internal" },
		{ "", "Internal" },
	},
	destroy_effect = "fx_digital",
	place_effect = "fx_digital_in",
}

-- Storage (16) -> Storage (32) [T2]
add_unlock("t_storage3", "f_storage32_t2")
Frame:RegisterFrame("f_storage32_t2", {
	size = "Small", race = "robot", name = "Storage Block (32) [T2]",
	desc = "Extended storage block with doubled 16-slot capacity.",
	minimap_color = { 0.8, 0.8, 0.8 },
	visibility_range = 10,
	slots = { storage = 32 },
	health_points = 180,
	texture = "AscendantTiers/textures/icons/frame/storage_32_t2.png",
	construction_recipe = CreateConstructionRecipe({ reinforced_plate = 10, circuit_board = 2, hdframe = 2 }, 110),
	trigger_channels = "building",
	visual = "v_base1x1g",
})

-- Storage (24) -> Storage (48) [T2]
add_unlock("t_storage3", "f_storage48_t2")
Frame:RegisterFrame("f_storage48_t2", {
	size = "Small", race = "robot", name = "Storage Block (48) [T2]",
	desc = "Extended storage block with doubled 24-slot capacity.",
	minimap_color = { 0.8, 0.8, 0.8 },
	visibility_range = 15,
	slots = { storage = 48 },
	health_points = 500,
	texture = "AscendantTiers/textures/icons/frame/storage_48_t2.png",
	construction_recipe = CreateConstructionRecipe({ hdframe = 10, icchip = 2, fused_electrodes = 4 }, 140),
	trigger_channels = "building",
	visual = "v_base1x1e",
})

-- 1x1 (1L) -> 1x1 (2L) [T2]
add_unlock("t_structures5", "f_building1x1_2l_t2")
Frame:RegisterFrame("f_building1x1_2l_t2", {
	size = "Large", race = "robot", name = "Building 1x1 (2L) [T2]",
	desc = "Extended 1x1 modular frame with two large sockets.",
	minimap_color = { 0.8, 0.8, 0.8 },
	visibility_range = 15,
	slots = { storage = 1 },
	health_points = 180,
	texture = "AscendantTiers/textures/icons/frame/building_1x1_2l_t2.png",
	construction_recipe = CreateConstructionRecipe({ hdframe = 12, icchip = 2, fused_electrodes = 4 }, 120),
	trigger_channels = "building",
	visual = "v_base1x1_2l_t2",
})

data.visuals.v_base1x1_2l_t2 = {
	mesh = "StaticMesh'/Game/Meshes/RobotBuildings/Building_1x1_B.Building_1x1_B'",
	placement = "Max",
	tile_size = { 1, 1 },
	sockets = {
		{ "Large1", "Large" },
		{ "Large1", "Large" },
		{ "", "Internal" },
		{ "", "Internal" },
	},
	destroy_effect = "fx_digital",
	place_effect = "fx_digital_in",
}

-- 2x1 (1M1L) -> 2x1 (2M2L) [T2]
add_unlock("t_structures5", "f_building2x1_2m2l_t2")
Frame:RegisterFrame("f_building2x1_2m2l_t2", {
	size = "Large", race = "robot", name = "Building 2x1 (2M2L) [T2]",
	desc = "Extended 2x1 modular frame with doubled medium and large sockets.",
	minimap_color = { 0.8, 0.8, 0.8 },
	visibility_range = 15,
	slots = { storage = 4 },
	health_points = 700,
	texture = "AscendantTiers/textures/icons/frame/building_2x1_2m2l_t2.png",
	construction_recipe = CreateConstructionRecipe({ hdframe = 12, icchip = 3, energized_plate = 10, fused_electrodes = 6 }, 160),
	trigger_channels = "building",
	visual = "v_base2x1_2m2l_t2",
})

data.visuals.v_base2x1_2m2l_t2 = {
	mesh = "StaticMesh'/Game/Meshes/RobotBuildings/Building_2x1_B.Building_2x1_B'",
	placement = "Max",
	tile_size = { 1, 2 },
	sockets = {
		{ "Medium1", "Medium" },
		{ "Medium1", "Medium" },
		{ "Large1", "Large" },
		{ "Large1", "Large" },
		{ "", "Internal" },
		{ "", "Internal" },
	},
	destroy_effect = "fx_digital",
	place_effect = "fx_digital_in",
}

-- 2x2 (2M) -> 2x2 (4M) [T2]
add_unlock("t_structures5", "f_building2x2_4m_t2")
Frame:RegisterFrame("f_building2x2_4m_t2", {
	size = "Medium", race = "robot", name = "Building 2x2 (4M) [T2]",
	desc = "Extended 2x2 modular frame with four medium sockets.",
	minimap_color = { 0.8, 0.8, 0.8 },
	visibility_range = 20,
	slots = { storage = 8 },
	health_points = 900,
	texture = "AscendantTiers/textures/icons/frame/building_2x2_4m_t2.png",
	construction_recipe = CreateConstructionRecipe({ energized_plate = 16, icchip = 2, hdframe = 6 }, 170),
	trigger_channels = "building",
	visual = "v_base2x2_4m_t2",
})

data.visuals.v_base2x2_4m_t2 = {
	mesh = "StaticMesh'/Game/Meshes/RobotBuildings/Building_2x2_F.Building_2x2_F'",
	placement = "Max",
	tile_size = { 2, 2 },
	sockets = {
		{ "Medium1", "Medium" },
		{ "Medium2", "Medium" },
		{ "Medium1", "Medium" },
		{ "Medium2", "Medium" },
		{ "", "Internal" },
		{ "", "Internal" },
	},
	destroy_effect = "fx_digital",
	place_effect = "fx_digital_in",
}

-- 3x2 (1L3M) -> 3x2 (2L6M) [T2]
add_unlock("t_robotics3", "f_building3x2_2l6m_t2")
Frame:RegisterFrame("f_building3x2_2l6m_t2", {
	size = "Large", race = "robot", name = "Building 3x2 (2L6M) [T2]",
	desc = "Extended 3x2 modular frame with doubled large and medium sockets.",
	minimap_color = { 0.8, 0.8, 0.8 },
	visibility_range = 35,
	health_points = 1600,
	slots = { storage = 12 },
	component_boost = 100,
	components = { { "c_integrated_power_cell", "hidden" } },
	construction_recipe = CreateConstructionRecipe({ uframe = 30, optic_cable = 40, fused_electrodes = 40, icchip = 20 }, 350),
	texture = "AscendantTiers/textures/icons/frame/building_3x2_2l6m_t2.png",
	trigger_channels = "building",
	visual = "v_base3x2_2l6m_t2",
})

data.visuals.v_base3x2_2l6m_t2 = {
	mesh = "StaticMesh'/Game/Meshes/RobotBuildings/Building_3x2_A.Building_3x2_A'",
	placement = "Max",
	tile_size = { 3, 2 },
	sockets = {
		{ "medium1", "Medium" },
		{ "medium2", "Medium" },
		{ "medium3", "Medium" },
		{ "medium1", "Medium" },
		{ "medium2", "Medium" },
		{ "medium3", "Medium" },
		{ "large1", "Large" },
		{ "large1", "Large" },
		{ "", "Internal" },
		{ "", "Internal" },
		{ "", "Internal" },
		{ "", "Internal" },
	},
	destroy_effect = "fx_digital",
	place_effect = "fx_digital_in",
}
