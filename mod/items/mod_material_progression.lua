data.items.ascendant_tiers_metal_plate = {
	tag = "simple_material", race = "robot", index = 9101, name = "Metal Plate [T2]",
	desc = "Reinforced machine-graded plates built for Ascendant Tiers structures.",
	slot_type = "storage",
	stack_size = 20,
	texture = "AscendantTiers/textures/icons/items/ascendant_tiers_metal_plate.png",
	visual = "v_metalplate",
	production_recipe = CreateProductionRecipe({ metalplate = 2, crystal = 2 }, {
		c_fabricator = 50,
		c_human_refinery = 90,
	}),
}

data.items.ascendant_tiers_circuit_board = {
	tag = "advanced_material", race = "robot", index = 9105, name = "Circuit Board [T2]",
	desc = "Upgraded circuit board built on Ascendant Tiers metal plate stock.",
	slot_type = "storage",
	stack_size = 20,
	texture = "AscendantTiers/textures/icons/items/ascendant_tiers_circuit_board.png",
	visual = "v_circuit_board",
	production_recipe = CreateProductionRecipe({ ascendant_tiers_metal_plate = 3, crystal = 5 }, {
		c_assembler = 60,
		c_human_factory = 40,
	}),
}

data.items.ascendant_tiers_ic_chip = {
	tag = "hitech_material", race = "robot", index = 9106, name = "IC Chip [T2]",
	desc = "Upgraded integrated chip produced from Ascendant Tiers circuit boards.",
	slot_type = "storage",
	stack_size = 20,
	texture = "AscendantTiers/textures/icons/items/ascendant_tiers_ic_chip.png",
	visual = "v_icchip",
	production_recipe = CreateProductionRecipe({ silicon = 3, ascendant_tiers_circuit_board = 5, cable = 3 }, {
		c_robotics_factory = 300,
		c_human_factory = 200,
	}),
}

data.items.ascendant_tiers_reinforced_plate = {
	tag = "advanced_material", race = "robot", index = 9102, name = "Reinforced Plate [T2]",
	desc = "Modded reinforced plate tuned for modular T2 frame assemblies.",
	slot_type = "storage",
	stack_size = 20,
	texture = "AscendantTiers/textures/icons/items/ascendant_tiers_reinforced_plate.png",
	visual = "v_reinforced_plate",
	production_recipe = CreateProductionRecipe({ metalbar = 2, ascendant_tiers_metal_plate = 1 }, {
		c_assembler = 55,
		c_human_factory = 55,
	}),
}

data.items.ascendant_tiers_energized_plate = {
	tag = "advanced_material", race = "robot", index = 9103, name = "Energized Plate [T2]",
	desc = "High-throughput energized plate for next-tier modular hardware.",
	slot_type = "storage",
	stack_size = 20,
	texture = "AscendantTiers/textures/icons/items/ascendant_tiers_energized_plate.png",
	visual = "v_energized_plate",
	production_recipe = CreateProductionRecipe({ ascendant_tiers_reinforced_plate = 2, crystal = 2 }, {
		c_robotics_factory = 120,
		c_human_factory = 220,
	}),
}

data.items.ascendant_tiers_high_density_frame = {
	tag = "hitech_material", race = "robot", index = 9104, name = "High-Density Frame [T2]",
	desc = "High-density structural frame built from energized T2 plate stock.",
	slot_type = "storage",
	stack_size = 20,
	texture = "AscendantTiers/textures/icons/items/ascendant_tiers_high_density_frame.png",
	visual = "v_high_density_frame",
	production_recipe = CreateProductionRecipe({ ascendant_tiers_energized_plate = 3, wire = 3 }, {
		c_robotics_factory = 180,
	}),
}
