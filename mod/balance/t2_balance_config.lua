local function clone_table(value)
	if type(value) ~= "table" then return value end
	local copy = {}
	for key, item in pairs(value) do
		copy[key] = clone_table(item)
	end
	return copy
end

local default_balance = {
	materials = {
		map = {
			metalplate = "ascendant_tiers_metal_plate",
			reinforced_plate = "ascendant_tiers_reinforced_plate",
			energized_plate = "ascendant_tiers_energized_plate",
			hdframe = "ascendant_tiers_high_density_frame",
			high_density_frame = "ascendant_tiers_high_density_frame",
			circuit_board = "ascendant_tiers_circuit_board",
			icchip = "ascendant_tiers_ic_chip",
			ic_chip = "ascendant_tiers_ic_chip",
		},
	},
	cost = {
		building_recipe_multiplier = 1.0,
		unit_recipe_multiplier = 1.0,
		tech_recipe_multiplier = 1.0,
		material_recipe_multiplier = 1.0,
		material_craft_time_multiplier = 1.0,
	},
	components = {
		recipe = {
			base_ingredient_multiplier = 2.0,
			overrides = {
				c_miner_t2 = {
					convert_ingredient = {
						from = "metalbar",
						to = "ascendant_tiers_metal_plate",
						multiplier = 1.0,
						mode = "add",
					},
				},
				c_portable_relay_t2 = {
					set_ingredient = {
						item = "ascendant_tiers_metal_plate",
						amount = 5,
					},
					remove_ingredients = {
						"metalbar",
					},
				},
			},
		},
		mining = {
			ticks_divisor = 2.0,
			efficiency_divisor = 1.0,
			min_ticks = 1,
		},
		stats = {
			repair = 2.0,
			trigger_radius = 2.0,
			shield_max = 2.0,
			damage = 2.0,
			dotdps = 2.0,
			storage_slots = 2.0,
			power = 2.0,
			drain_rate = 2.0,
			bandwidth = 2.0,
			max_power = 2.0,
			solar_power_generated = 2.0,
			solar_power_summer = 2.0,
			speed = 1.0,
			power_storage = 2.0,
			power_capacity = 2.0,
			transfer_radius = 2.0,
			range = 2.0,
			power_range = 2.0,
			relay_range = 2.0,
			field_radius = 2.0,
			radius = 2.0,
		},
	},
	buildings = {
		socket_scale = {
			default = 1.0,
			Internal = 1.5,
			Small = 2.0,
			Medium = 2.0,
			Large = 2.0,
		},
		health_multiplier_default = 1.35,
		storage_multiplier_default = 2.0,
		storage_multiplier_overrides = {
			f_storage16_t2 = 2.0,
			f_storage32_t2 = 2.0,
			f_storage48_t2 = 2.0,
		},
		storage_slot_bonus_overrides = {
			f_building1x1_4s_t2 = 1,
		},
		construction_overrides = {
			f_building1x1_2s_t2 = {
				convert_ingredient = {
					from = "metalbar",
					to = "ascendant_tiers_metal_plate",
					divisor = 2.0,
					minimum = 1,
					mode = "add",
				},
			},
			f_storage16_t2 = {
				convert_ingredient = {
					from = "metalbar",
					to = "ascendant_tiers_metal_plate",
					divisor = 2.0,
					minimum = 1,
					mode = "add",
				},
			},
		},
	},
	units = {
		socket_scale = {
			default = 1.0,
			Internal = 1.5,
			Small = 2.0,
			Medium = 2.0,
			Large = 2.0,
		},
		health_multiplier = 1.25,
		no_sml_inventory_multiplier = 2.0,
		no_sml_speed_multiplier = 1.5,
	},
}

local COMPONENT_STAT_MODE_GLOBAL<const> = 1
local COMPONENT_STAT_MODE_PER_STAT<const> = 2

local COMPONENT_PER_STAT_OPTION_MAP<const> = {
	{ field = "repair", option_id = "t2_component_stat_repair_pct" },
	{ field = "trigger_radius", option_id = "t2_component_stat_trigger_radius_pct" },
	{ field = "storage_slots", option_id = "t2_component_stat_storage_slots_pct" },

	{ field = "shield_max", option_id = "t2_component_stat_shield_max_pct" },
	{ field = "shield_charge", option_id = "t2_component_stat_shield_max_pct" },

	{ field = "damage", option_id = "t2_component_stat_damage_pct" },
	{ field = "dotdps", option_id = "t2_component_stat_damage_pct" },

	{ field = "power", option_id = "t2_component_stat_power_pct" },
	{ field = "max_power", option_id = "t2_component_stat_power_pct" },
	{ field = "solar_power_generated", option_id = "t2_component_stat_power_pct" },
	{ field = "solar_power_summer", option_id = "t2_component_stat_power_pct" },
	{ field = "power_storage", option_id = "t2_component_stat_power_pct" },
	{ field = "power_capacity", option_id = "t2_component_stat_power_pct" },
	{ field = "charge_rate", option_id = "t2_component_stat_power_pct" },
	{ field = "drain_rate", option_id = "t2_component_stat_power_pct" },

	{ field = "transfer_radius", option_id = "t2_component_stat_transfer_radius_pct" },
	{ field = "range", option_id = "t2_component_stat_transfer_radius_pct" },
	{ field = "power_range", option_id = "t2_component_stat_transfer_radius_pct" },
	{ field = "relay_range", option_id = "t2_component_stat_transfer_radius_pct" },
	{ field = "field_radius", option_id = "t2_component_stat_transfer_radius_pct" },
	{ field = "radius", option_id = "t2_component_stat_transfer_radius_pct" },
	{ field = "miner_range", option_id = "t2_component_stat_transfer_radius_pct" },
	{ field = "bandwidth", option_id = "t2_component_stat_bandwidth_pct" },

	{ field = "attack_radius", option_id = "t2_component_stat_attack_radius_pct", default_percent = 100 },
	{ field = "beam_range", option_id = "t2_component_stat_attack_radius_pct", default_percent = 100 },
	{ field = "blast", option_id = "t2_component_stat_attack_radius_pct", default_percent = 100 },
	{ field = "minimum_range", option_id = "t2_component_stat_attack_radius_pct", default_percent = 100 },
	{ field = "duration", option_id = "t2_component_stat_duration_pct", default_percent = 100 },
	{ field = "shoot_speed", option_id = "t2_component_stat_shoot_speed_pct", default_percent = 100 },
	{ field = "damage_air_bonus", option_id = "t2_component_stat_damage_air_bonus_pct", default_percent = 100 },
	{ field = "dothits", option_id = "t2_component_stat_dothits_pct", default_percent = 100 },
	{ field = "pulse", option_id = "t2_component_stat_pulse_pct", default_percent = 100 },
	{ field = "disruptor", option_id = "t2_component_stat_disruptor_pct", default_percent = 100 },
}

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
	local percent = math.floor(numeric + 0.5)
	percent = clamp_number(percent, min_percent, max_percent)
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

	local percent = math.floor(numeric + 0.5)
	percent = clamp_number(percent, min_percent, max_percent)
	return percent / 100.0
end

local function read_integer_option(option_id, default_value, min_value, max_value)
	local raw_value = default_value
	if type(AscendantTiersGetSetting) == "function" then
		raw_value = AscendantTiersGetSetting(option_id, default_value)
	end

	local numeric = tonumber(raw_value) or default_value
	local rounded = math.floor(numeric + 0.5)
	return clamp_number(rounded, min_value, max_value)
end

local function scale_numeric_entries(target_table, factor)
	if type(target_table) ~= "table" then
		return
	end

	for key, value in pairs(target_table) do
		if type(value) == "number" then
			target_table[key] = value * factor
		end
	end
end

local function scale_socket_scale_entries(socket_scale, factor)
	if type(socket_scale) ~= "table" then
		return
	end
	if type(factor) ~= "number" or math.abs(factor - 1.0) < 0.0001 then
		return
	end

	for key, value in pairs(socket_scale) do
		if type(value) == "number" then
			socket_scale[key] = value * factor
		end
	end
end

local t2_balance = clone_table(default_balance)

local component_recipe_multiplier = read_multiplier_option("t2_component_recipe_pct", 200, 10, 1000)
local component_stats_multiplier = read_multiplier_option("t2_component_stats_pct", 200, 10, 1000)
local component_stat_mode = read_integer_option("t2_component_stat_mode", COMPONENT_STAT_MODE_GLOBAL, 1, 2)
local mining_speed_multiplier = read_multiplier_option("t2_mining_speed_pct", 200, 10, 1000)
local building_health_multiplier = read_multiplier_option("t2_building_health_pct", 135, 10, 1000)
local building_storage_multiplier = read_multiplier_option("t2_building_storage_pct", 200, 10, 1000)
local unit_health_multiplier = read_multiplier_option("t2_unit_health_pct", 125, 10, 1000)
local unit_inventory_multiplier = read_multiplier_option("t2_unit_inventory_pct", 200, 10, 1000)
local unit_speed_multiplier = read_multiplier_option("t2_unit_speed_pct", 150, 10, 1000)
local building_slots_multiplier = read_multiplier_option("t2_building_slots_pct", 100, 10, 1000)
local unit_slots_multiplier = read_multiplier_option("t2_unit_slots_pct", 100, 10, 1000)
local t2_building_recipe_cost_multiplier = read_multiplier_option("t2_building_recipe_cost_pct", 100, 10, 1000)
local t2_unit_recipe_cost_multiplier = read_multiplier_option("t2_unit_recipe_cost_pct", 100, 10, 1000)
local t2_tech_cost_multiplier = read_multiplier_option("t2_tech_cost_pct", 100, 10, 1000)
local t2_material_recipe_cost_multiplier = read_multiplier_option("t2_material_recipe_cost_pct", 100, 10, 1000)
local t2_material_craft_time_multiplier = read_multiplier_option_with_fallback(
	"t2_material_craft_time_pct",
	"t2_material_craft_speed_pct",
	100,
	10,
	1000
)

local component_stats_percent = clamp_number(math.floor(component_stats_multiplier * 100 + 0.5), 10, 1000)
local mining_speed_percent = clamp_number(math.floor(mining_speed_multiplier * 100 + 0.5), 10, 1000)

t2_balance.components.recipe.base_ingredient_multiplier = component_recipe_multiplier
t2_balance.cost.building_recipe_multiplier = t2_building_recipe_cost_multiplier
t2_balance.cost.unit_recipe_multiplier = t2_unit_recipe_cost_multiplier
t2_balance.cost.tech_recipe_multiplier = t2_tech_cost_multiplier
t2_balance.cost.material_recipe_multiplier = t2_material_recipe_cost_multiplier
t2_balance.cost.material_craft_time_multiplier = t2_material_craft_time_multiplier
scale_socket_scale_entries(t2_balance.buildings.socket_scale, building_slots_multiplier)
scale_socket_scale_entries(t2_balance.units.socket_scale, unit_slots_multiplier)

local component_stats_baseline = 2.0
if component_stat_mode == COMPONENT_STAT_MODE_PER_STAT then
	for _, entry in ipairs(COMPONENT_PER_STAT_OPTION_MAP) do
		local default_percent = entry.default_percent or component_stats_percent
		t2_balance.components.stats[entry.field] = read_multiplier_option(entry.option_id, default_percent, 10, 1000)
	end

	t2_balance.components.mining.ticks_divisor = read_multiplier_option(
		"t2_component_stat_mining_speed_pct",
		mining_speed_percent,
		10,
		1000
	)
	t2_balance.components.mining.efficiency_divisor = read_multiplier_option(
		"t2_component_stat_mining_efficiency_pct",
		100,
		10,
		1000
	)
else
	t2_balance.components.mining.ticks_divisor = mining_speed_multiplier
	t2_balance.components.mining.efficiency_divisor = 1.0
	scale_numeric_entries(t2_balance.components.stats, component_stats_multiplier / component_stats_baseline)
end

local building_health_baseline = default_balance.buildings.health_multiplier_default
if building_health_baseline > 0 then
	scale_numeric_entries(
		t2_balance.buildings.health_multiplier_overrides,
		building_health_multiplier / building_health_baseline
	)
end
t2_balance.buildings.health_multiplier_default = building_health_multiplier

local building_storage_baseline = default_balance.buildings.storage_multiplier_default
if building_storage_baseline > 0 then
	scale_numeric_entries(
		t2_balance.buildings.storage_multiplier_overrides,
		building_storage_multiplier / building_storage_baseline
	)
end
t2_balance.buildings.storage_multiplier_default = building_storage_multiplier

t2_balance.units.health_multiplier = unit_health_multiplier
t2_balance.units.no_sml_inventory_multiplier = unit_inventory_multiplier
t2_balance.units.no_sml_speed_multiplier = unit_speed_multiplier

data.ascendant_tiers_t2_balance = t2_balance

