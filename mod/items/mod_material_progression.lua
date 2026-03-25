local MATERIAL_RECIPE_COST_OPTION_ID<const> = "t2_material_recipe_cost_pct"
local MATERIAL_CRAFT_TIME_OPTION_ID<const> = "t2_material_craft_time_pct"
local LEGACY_MATERIAL_CRAFT_SPEED_OPTION_ID<const> = "t2_material_craft_speed_pct"

local function clamp_number(value, min_value, max_value)
	if value < min_value then
		return min_value
	end
	if value > max_value then
		return max_value
	end
	return value
end

local function read_multiplier_option(option_id, default_percent, min_percent, max_percent)
	local raw_value = default_percent
	if type(AscendantTiersGetSetting) == "function" then
		raw_value = AscendantTiersGetSetting(option_id, default_percent)
	end

	local numeric = tonumber(raw_value) or default_percent
	local rounded = math.floor(numeric + 0.5)
	local percent = clamp_number(rounded, min_percent, max_percent)
	return percent / 100.0
end

local function read_multiplier_option_with_fallback(primary_option_id, fallback_option_id, default_percent, min_percent, max_percent)
	local raw_value = nil
	if type(AscendantTiersGetSetting) == "function" then
		raw_value = AscendantTiersGetSetting(primary_option_id, nil)
		if raw_value == nil and fallback_option_id then
			raw_value = AscendantTiersGetSetting(fallback_option_id, nil)
		end
	end

	local numeric = tonumber(raw_value)
	if not numeric then
		numeric = default_percent
	end

	local rounded = math.floor(numeric + 0.5)
	local percent = clamp_number(rounded, min_percent, max_percent)
	return percent / 100.0
end

local function apply_material_recipe_scaling(recipe, cost_multiplier, time_multiplier)
	if type(recipe) ~= "table" then
		return
	end

	local ingredients = recipe.ingredients
	if type(ingredients) == "table" then
		for item_id, amount in pairs(ingredients) do
			if type(amount) == "number" and amount > 0 then
				local scaled = math.ceil(amount * cost_multiplier)
				ingredients[item_id] = math.max(1, scaled)
			end
		end
	end

	local producers = recipe.producers
	if type(producers) == "table" then
		for producer_id, ticks in pairs(producers) do
			if type(ticks) == "number" and ticks > 0 then
				-- Craft time: lower % is faster, higher % is slower.
				local scaled_ticks = math.ceil(ticks * time_multiplier)
				producers[producer_id] = math.max(1, scaled_ticks)
			end
		end
	end
end

data.items.ascendant_tiers_metal_plate = {
	tag = "simple_material", race = "robot", index = 9101, name = "ascendant.item.metal_plate_t2.name",
	desc = "ascendant.item.metal_plate_t2.desc",
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
	tag = "advanced_material", race = "robot", index = 9105, name = "ascendant.item.circuit_board_t2.name",
	desc = "ascendant.item.circuit_board_t2.desc",
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
	tag = "hitech_material", race = "robot", index = 9106, name = "ascendant.item.ic_chip_t2.name",
	desc = "ascendant.item.ic_chip_t2.desc",
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
	tag = "advanced_material", race = "robot", index = 9102, name = "ascendant.item.reinforced_plate_t2.name",
	desc = "ascendant.item.reinforced_plate_t2.desc",
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
	tag = "advanced_material", race = "robot", index = 9103, name = "ascendant.item.energized_plate_t2.name",
	desc = "ascendant.item.energized_plate_t2.desc",
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
	tag = "hitech_material", race = "robot", index = 9104, name = "ascendant.item.high_density_frame_t2.name",
	desc = "ascendant.item.high_density_frame_t2.desc",
	slot_type = "storage",
	stack_size = 20,
	texture = "AscendantTiers/textures/icons/items/ascendant_tiers_high_density_frame.png",
	visual = "v_high_density_frame",
	production_recipe = CreateProductionRecipe({ ascendant_tiers_energized_plate = 3, wire = 3 }, {
		c_robotics_factory = 180,
	}),
}

local material_recipe_cost_multiplier = read_multiplier_option(MATERIAL_RECIPE_COST_OPTION_ID, 100, 10, 1000)
local material_craft_time_multiplier = read_multiplier_option_with_fallback(
	MATERIAL_CRAFT_TIME_OPTION_ID,
	LEGACY_MATERIAL_CRAFT_SPEED_OPTION_ID,
	100,
	10,
	1000
)

local material_item_ids = {
	"ascendant_tiers_metal_plate",
	"ascendant_tiers_circuit_board",
	"ascendant_tiers_ic_chip",
	"ascendant_tiers_reinforced_plate",
	"ascendant_tiers_energized_plate",
	"ascendant_tiers_high_density_frame",
}

for _, item_id in ipairs(material_item_ids) do
	local item_def = data.items[item_id]
	if item_def and type(item_def.production_recipe) == "table" then
		apply_material_recipe_scaling(
			item_def.production_recipe,
			material_recipe_cost_multiplier,
			material_craft_time_multiplier
		)
	end
end
