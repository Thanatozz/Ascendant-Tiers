local function clone_table(value)
	if type(value) ~= "table" then return value end
	local copy = {}
	for k, v in pairs(value) do
		copy[k] = clone_table(v)
	end
	return copy
end

local function tr(key, ...)
	if type(L) == "function" then
		return L(key, ...)
	end
	if select("#", ...) > 0 then
		return string.format(key, ...)
	end
	return key
end

local default_t2_material_map = {
	metalplate = "ascendant_tiers_metal_plate",
	reinforced_plate = "ascendant_tiers_reinforced_plate",
	energized_plate = "ascendant_tiers_energized_plate",
	hdframe = "ascendant_tiers_high_density_frame",
	high_density_frame = "ascendant_tiers_high_density_frame",
	circuit_board = "ascendant_tiers_circuit_board",
	icchip = "ascendant_tiers_ic_chip",
	ic_chip = "ascendant_tiers_ic_chip",
}

local t2_balance = data.ascendant_tiers_t2_balance or {}
local t2_material_map = ((t2_balance.materials or {}).map) or default_t2_material_map
local component_balance = t2_balance.components or {}
local component_recipe_balance = component_balance.recipe or {}
local component_mining_balance = component_balance.mining or {}
local component_stat_balance = component_balance.stats or {}

local function map_to_t2_material_if_available(item_id)
	return t2_material_map[item_id] or item_id
end

local function add_amount(target, item_id, amount)
	target[item_id] = (target[item_id] or 0) + amount
end

local function normalize_recipe_ingredients(ingredients)
	if type(ingredients) ~= "table" then
		return ingredients
	end

	for item_id, amount in pairs(ingredients) do
		if type(amount) == "number" then
			if amount > 0 then
				ingredients[item_id] = math.max(1, math.ceil(amount))
			else
				ingredients[item_id] = nil
			end
		end
	end

	return ingredients
end

local function is_component_id(item_id)
	return type(item_id) == "string" and item_id:sub(1, 2) == "c_"
end

local function to_t2_component_id(component_id)
	return component_id .. "_t2"
end

local function as_set(list)
	local result = {}
	for _, id in ipairs(list) do
		result[id] = true
	end
	return result
end

local healer_components = as_set({
	"c_repairer",
	"c_repairkit",
	"c_repairer_small_aoe",
	"c_repairer_aoe",
})

local shield_components = as_set({
	"c_shield_generator",
	"c_shield_generator2",
	"c_shield_generator3",
})

local damage_components = as_set({
	"c_portable_turret",
	"c_melee_pulse",
	"c_pulselasers",
	"c_adv_portable_turret",
	"c_pulse_disrupter",
	"c_turret",
	"c_photon_cannon",
	"c_photon_beam",
	"c_viral_pulse",
	"c_laser_turret",
	"c_plasma_cannon",
})

local energy_generation_components = as_set({
	"c_crystal_power",
	"c_solar_cell",
	"c_solar_panel",
	"c_wind_turbine",
	"c_wind_turbine_l",
	"c_power_cell",
	"c_power_core",
})

local battery_components = as_set({
	"c_small_battery",
	"c_capacitor",
	"c_medium_capacitor",
	"c_battery",
	"c_power_cell",
	"c_power_core",
})

local storage_components = as_set({
	"c_small_storage",
	"c_medium_storage",
	"c_large_storage",
})

local power_field_components = as_set({
	"c_portable_relay",
	"c_small_relay",
	"c_power_relay",
	"c_power_transmitter",
	"c_large_power_transmitter",
})

local miner_components = as_set({
	"c_miner",
	"c_adv_miner",
})

local function build_t2_production_recipe(base_component)
	local base_recipe = base_component and base_component.production_recipe
	if type(base_recipe) ~= "table" or type(base_recipe.ingredients) ~= "table" then
		return base_recipe
	end

	local base_ingredient_multiplier = tonumber(component_recipe_balance.base_ingredient_multiplier) or 2.0

	local ingredients = {}
	for item_id, amount in pairs(base_recipe.ingredients) do
		if is_component_id(item_id) then
			add_amount(ingredients, to_t2_component_id(item_id), amount)
		else
			add_amount(ingredients, map_to_t2_material_if_available(item_id), amount * base_ingredient_multiplier)
		end
	end

	local producers = {}
	if type(base_recipe.producers) == "table" then
		for item_id, amount in pairs(base_recipe.producers) do
			add_amount(producers, map_to_t2_material_if_available(item_id), amount)
		end
	end

	normalize_recipe_ingredients(ingredients)
	return CreateProductionRecipe(ingredients, producers, base_recipe.amount or 1)
end

local function apply_recipe_overrides(component_id, recipe)
	if type(recipe) ~= "table" or type(recipe.ingredients) ~= "table" then
		return recipe
	end

	local recipe_overrides = component_recipe_balance.overrides
	local override = type(recipe_overrides) == "table" and recipe_overrides[component_id]
	if type(override) ~= "table" then
		return recipe
	end

	if type(override.remove_ingredients) == "table" then
		for _, ingredient_id in ipairs(override.remove_ingredients) do
			recipe.ingredients[ingredient_id] = nil
		end
	end

	local convert = override.convert_ingredient
	if type(convert) == "table" and type(convert.from) == "string" and type(convert.to) == "string" then
		local from_amount = recipe.ingredients[convert.from]
		if type(from_amount) == "number" and from_amount > 0 then
			recipe.ingredients[convert.from] = nil

			local converted = from_amount
			if type(convert.divisor) == "number" and convert.divisor > 0 then
				converted = converted / convert.divisor
			end
			if type(convert.multiplier) == "number" then
				converted = converted * convert.multiplier
			end
			if type(convert.minimum) == "number" then
				converted = math.max(convert.minimum, converted)
			end

			local round_mode = convert.round or "ceil"
			if round_mode == "ceil" then
				converted = math.ceil(converted)
			elseif round_mode == "floor" then
				converted = math.floor(converted)
			elseif round_mode == "round" then
				converted = math.floor(converted + 0.5)
			end

			if convert.mode == "set" then
				recipe.ingredients[convert.to] = converted
			else
				recipe.ingredients[convert.to] = (recipe.ingredients[convert.to] or 0) + converted
			end
		end
	end

	local set_ingredient = override.set_ingredient
	if type(set_ingredient) == "table" and type(set_ingredient.item) == "string" and type(set_ingredient.amount) == "number" then
		recipe.ingredients[set_ingredient.item] = set_ingredient.amount
	end

	normalize_recipe_ingredients(recipe.ingredients)
	return recipe
end

local function component_stat_multiplier(field, fallback)
	local multiplier = component_stat_balance[field]
	if type(multiplier) == "number" then
		return multiplier
	end
	return fallback
end

local function scaled_number(base_component, field, factor, positive_only)
	local value = base_component[field]
	if type(value) ~= "number" then
		return nil
	end
	if positive_only and value <= 0 then
		return nil
	end
	return value * factor
end

local field_desc_keywords = {
	repair = { "repair", "repairs", "heal", "heals" },
	trigger_radius = { "range", "radius", "repair" },
	shield_max = { "shield", "shields" },
	shield_charge = { "shield", "recharge", "charge" },
	damage = { "damage", "damages" },
	damage_air_bonus = { "air", "flying", "damage" },
	dotdps = { "dps", "dot", "burn" },
	dothits = { "dot", "hits", "burn" },
	storage_slots = { "storage", "slot", "slots", "capacity" },
	bandwidth = { "bandwidth", "transmit", "power", "transfer" },
	power = { "power", "energy" },
	drain_rate = { "drain", "consumes", "consumption", "upkeep" },
	charge_rate = { "charge", "recharge", "battery" },
	max_power = { "power", "energy" },
	solar_power_generated = { "solar", "sunlight" },
	solar_power_summer = { "solar", "summer" },
	speed = { "speed", "rotation", "spin" },
	power_storage = { "storage", "capacity", "battery", "energy" },
	power_capacity = { "storage", "capacity", "battery", "energy" },
	attack_radius = { "range", "radius", "attack" },
	duration = { "duration", "time", "seconds" },
	shoot_speed = { "speed", "rate", "fire" },
	beam_range = { "beam", "range" },
	blast = { "blast", "radius", "area" },
	pulse = { "pulse", "size", "radius" },
	disruptor = { "disrupt", "disruptor" },
	minimum_range = { "minimum", "min", "range" },
	miner_range = { "range", "mining" },
	transfer_radius = { "range", "radius", "field", "relay", "transmit" },
	range = { "range", "radius", "field", "relay", "transmit" },
	power_range = { "range", "radius", "field", "relay", "transmit" },
	relay_range = { "range", "radius", "field", "relay", "transmit" },
	field_radius = { "range", "radius", "field", "relay", "transmit" },
	radius = { "range", "radius", "field", "relay", "transmit" },
}

local function format_number(value)
	if type(value) ~= "number" then
		return tostring(value)
	end

	if value == math.floor(value) then
		return tostring(math.floor(value))
	end

	local text = string.format("%.3f", value)
	text = text:gsub("0+$", "")
	text = text:gsub("%.$", "")
	return text
end

local function find_numeric_token_equal(text, from_index, to_index, target_number)
	local cursor = from_index
	while cursor <= to_index do
		local start_pos, end_pos, token = text:find("([-+]?%d+%.?%d*)", cursor)
		if not start_pos or start_pos > to_index then
			return nil, nil
		end

		if end_pos <= to_index then
			local token_number = tonumber(token)
			if token_number and math.abs(token_number - target_number) < 0.0001 then
				return start_pos, end_pos
			end
		end

		cursor = end_pos + 1
	end

	return nil, nil
end

local function replace_number_near_keyword(text, keyword, old_number, new_value)
	if type(text) ~= "string" or text == "" then
		return text, false
	end

	local lower = text:lower()
	local search_from = 1
	while true do
		local keyword_start, keyword_end = lower:find(keyword, search_from, true)
		if not keyword_start then
			return text, false
		end

		local window_start = math.max(1, keyword_start - 120)
		local window_end = math.min(#text, keyword_end + 120)
		local number_start, number_end = find_numeric_token_equal(text, window_start, window_end, old_number)
		if number_start and number_end then
			local replaced = text:sub(1, number_start - 1) .. new_value .. text:sub(number_end + 1)
			return replaced, true
		end

		search_from = keyword_end + 1
	end
end

local function replace_number_anywhere(text, old_number, new_value)
	if type(text) ~= "string" or text == "" then
		return text, false
	end

	local number_start, number_end = find_numeric_token_equal(text, 1, #text, old_number)
	if not number_start or not number_end then
		return text, false
	end

	local replaced = text:sub(1, number_start - 1) .. new_value .. text:sub(number_end + 1)
	return replaced, true
end

local function replace_stat_values_in_desc(base_desc, stat_changes)
	if type(base_desc) ~= "string" or base_desc == "" then
		return base_desc
	end

	local updated_desc = base_desc
	for _, change in ipairs(stat_changes) do
		local old_number = tonumber(change.old_value)
		local new_value = format_number(change.new_value)
		if old_number and format_number(old_number) ~= new_value then
			local replaced = false
			for _, keyword in ipairs(change.keywords or {}) do
				updated_desc, replaced = replace_number_near_keyword(updated_desc, keyword, old_number, new_value)
				if replaced then
					break
				end
			end

			if not replaced then
				updated_desc, replaced = replace_number_anywhere(updated_desc, old_number, new_value)
			end
		end
	end

	return updated_desc
end

local function collect_stat_change(base_component, field, new_value, changes)
	local old_value = base_component[field]
	if type(old_value) == "number" and type(new_value) == "number" and old_value ~= new_value then
		table.insert(changes, {
			field = field,
			old_value = old_value,
			new_value = new_value,
			keywords = field_desc_keywords[field] or {},
		})
	end
end

local function apply_primary_role_scaling(base_component_id, base_component, component_def)
	local stat_changes = {}

	if healer_components[base_component_id] then
		local scaled_repair = scaled_number(base_component, "repair", component_stat_multiplier("repair", 2))
		if scaled_repair then
			component_def.repair = scaled_repair
			collect_stat_change(base_component, "repair", scaled_repair, stat_changes)
		end

		local scaled_trigger_radius = scaled_number(
			base_component,
			"trigger_radius",
			component_stat_multiplier("trigger_radius", 2),
			true
		)
		if scaled_trigger_radius then
			component_def.trigger_radius = scaled_trigger_radius
			collect_stat_change(base_component, "trigger_radius", scaled_trigger_radius, stat_changes)
		end
	end

	if shield_components[base_component_id] then
		local scaled_shield = scaled_number(base_component, "shield_max", component_stat_multiplier("shield_max", 2))
		if scaled_shield then
			component_def.shield_max = scaled_shield
			collect_stat_change(base_component, "shield_max", scaled_shield, stat_changes)
		end

		local scaled_shield_charge = scaled_number(
			base_component,
			"shield_charge",
			component_stat_multiplier("shield_charge", 1),
			true
		)
		if scaled_shield_charge then
			component_def.shield_charge = scaled_shield_charge
			collect_stat_change(base_component, "shield_charge", scaled_shield_charge, stat_changes)
		end
	end

	if damage_components[base_component_id] then
		local scaled_damage = scaled_number(base_component, "damage", component_stat_multiplier("damage", 2))
		if scaled_damage then
			component_def.damage = scaled_damage
			collect_stat_change(base_component, "damage", scaled_damage, stat_changes)
		end

		local scaled_dot = scaled_number(base_component, "dotdps", component_stat_multiplier("dotdps", 2))
		if scaled_dot then
			component_def.dotdps = scaled_dot
			collect_stat_change(base_component, "dotdps", scaled_dot, stat_changes)
		end

		for _, field in ipairs({
			"attack_radius",
			"duration",
			"shoot_speed",
			"beam_range",
			"blast",
			"damage_air_bonus",
			"dothits",
			"pulse",
			"disruptor",
			"minimum_range",
		}) do
			local scaled_value = scaled_number(base_component, field, component_stat_multiplier(field, 1), true)
			if scaled_value then
				component_def[field] = scaled_value
				collect_stat_change(base_component, field, scaled_value, stat_changes)
			end
		end
	end

	if energy_generation_components[base_component_id] then
		local scaled_power = scaled_number(base_component, "power", component_stat_multiplier("power", 2), true)
		if scaled_power then
			component_def.power = scaled_power
			collect_stat_change(base_component, "power", scaled_power, stat_changes)
		end

		local scaled_wind = scaled_number(base_component, "max_power", component_stat_multiplier("max_power", 2), true)
		if scaled_wind then
			component_def.max_power = scaled_wind
			collect_stat_change(base_component, "max_power", scaled_wind, stat_changes)
		end

		local scaled_solar_day = scaled_number(
			base_component,
			"solar_power_generated",
			component_stat_multiplier("solar_power_generated", 2),
			true
		)
		if scaled_solar_day then
			component_def.solar_power_generated = scaled_solar_day
			collect_stat_change(base_component, "solar_power_generated", scaled_solar_day, stat_changes)
		end

		local scaled_solar_summer = scaled_number(
			base_component,
			"solar_power_summer",
			component_stat_multiplier("solar_power_summer", 2),
			true
		)
		if scaled_solar_summer then
			component_def.solar_power_summer = scaled_solar_summer
			collect_stat_change(base_component, "solar_power_summer", scaled_solar_summer, stat_changes)
		end

		local scaled_speed = scaled_number(base_component, "speed", component_stat_multiplier("speed", 1), true)
		if scaled_speed then
			component_def.speed = scaled_speed
			collect_stat_change(base_component, "speed", scaled_speed, stat_changes)
		end
	end

	if battery_components[base_component_id] then
		local scaled_charge_rate = scaled_number(
			base_component,
			"charge_rate",
			component_stat_multiplier("charge_rate", 1),
			true
		)
		if scaled_charge_rate then
			component_def.charge_rate = scaled_charge_rate
			collect_stat_change(base_component, "charge_rate", scaled_charge_rate, stat_changes)
		end

		local scaled_storage = scaled_number(
			base_component,
			"power_storage",
			component_stat_multiplier("power_storage", 2),
			true
		)
		if scaled_storage then
			component_def.power_storage = scaled_storage
			collect_stat_change(base_component, "power_storage", scaled_storage, stat_changes)
		end

		local scaled_capacity = scaled_number(
			base_component,
			"power_capacity",
			component_stat_multiplier("power_capacity", 2),
			true
		)
		if scaled_capacity then
			component_def.power_capacity = scaled_capacity
			collect_stat_change(base_component, "power_capacity", scaled_capacity, stat_changes)
		end
	end

	if storage_components[base_component_id] then
		local slots = base_component.slots
		local base_storage_slots = type(slots) == "table" and slots.storage
		if type(base_storage_slots) == "number" and base_storage_slots > 0 then
			local scaled_storage_slots = base_storage_slots * component_stat_multiplier("storage_slots", 2)
			component_def.slots = clone_table(slots)
			component_def.slots.storage = scaled_storage_slots
			table.insert(stat_changes, {
				field = "storage_slots",
				old_value = base_storage_slots,
				new_value = scaled_storage_slots,
				keywords = field_desc_keywords.storage_slots or {},
			})
		end
	end

	if base_component_id == "c_crystal_power" then
		local scaled_drain = scaled_number(
			base_component,
			"drain_rate",
			component_stat_multiplier("drain_rate", 2),
			true
		)
		if scaled_drain then
			component_def.drain_rate = scaled_drain
			collect_stat_change(base_component, "drain_rate", scaled_drain, stat_changes)
		end

		local scaled_storage = scaled_number(
			base_component,
			"power_storage",
			component_stat_multiplier("power_storage", 2),
			true
		)
		if scaled_storage then
			component_def.power_storage = scaled_storage
			collect_stat_change(base_component, "power_storage", scaled_storage, stat_changes)
		end

		local scaled_capacity = scaled_number(
			base_component,
			"power_capacity",
			component_stat_multiplier("power_capacity", 2),
			true
		)
		if scaled_capacity then
			component_def.power_capacity = scaled_capacity
			collect_stat_change(base_component, "power_capacity", scaled_capacity, stat_changes)
		end

		local base_power = base_component.power
		if type(base_power) == "number" and base_power < 0 then
			local scaled_negative_power = base_power * component_stat_multiplier("power", 2)
			component_def.power = scaled_negative_power
			collect_stat_change(base_component, "power", scaled_negative_power, stat_changes)
		end
	end

	if power_field_components[base_component_id] then
		local range_fields = { "transfer_radius", "range", "power_range", "relay_range", "field_radius", "radius" }
		for _, field in ipairs(range_fields) do
			local scaled_range = scaled_number(base_component, field, component_stat_multiplier(field, 2), true)
			if scaled_range then
				component_def[field] = scaled_range
				collect_stat_change(base_component, field, scaled_range, stat_changes)
			end
		end

		local scaled_bandwidth = scaled_number(base_component, "bandwidth", component_stat_multiplier("bandwidth", 2), true)
		if scaled_bandwidth then
			component_def.bandwidth = scaled_bandwidth
			collect_stat_change(base_component, "bandwidth", scaled_bandwidth, stat_changes)
		end
	end

	if miner_components[base_component_id] then
		local scaled_miner_range = scaled_number(
			base_component,
			"miner_range",
			component_stat_multiplier("miner_range", 1),
			true
		)
		if scaled_miner_range then
			component_def.miner_range = scaled_miner_range
			collect_stat_change(base_component, "miner_range", scaled_miner_range, stat_changes)
		end
	end

	return stat_changes
end

local function apply_mining_speed_overrides(base_component_id, t2_component_id)
	if not miner_components[base_component_id] then
		return
	end

	local ticks_divisor = tonumber(component_mining_balance.ticks_divisor) or 2.0
	local efficiency_divisor = tonumber(component_mining_balance.efficiency_divisor) or 1.0
	local min_ticks = tonumber(component_mining_balance.min_ticks) or 1

	for _, item_def in pairs(data.items) do
		local mining_recipe = item_def and item_def.mining_recipe
		local base_ticks = type(mining_recipe) == "table" and mining_recipe[base_component_id]
		if type(base_ticks) == "number" and base_ticks > 0 then
			local scaled_ticks = base_ticks
			local effective_divisor = ticks_divisor
			if base_component_id == "c_adv_miner" and efficiency_divisor > 0 then
				effective_divisor = effective_divisor * efficiency_divisor
			end
			if effective_divisor > 0 then
				scaled_ticks = scaled_ticks / effective_divisor
			end
			mining_recipe[t2_component_id] = math.max(min_ticks, math.floor(scaled_ticks))
		end
	end
end

local function upgraded_desc(base_component, base_name, stat_changes)
	local original_desc = type(base_component.desc) == "string" and base_component.desc or ""
	local desc_body = replace_stat_values_in_desc(original_desc, stat_changes or {})
	if desc_body == "" then
		desc_body = tr("ascendant.desc.fallback.component_role_variant", base_name)
	end
	if desc_body:find("%[T2%]") then
		return desc_body
	end
	return "<hl>[T2]</> " .. desc_body
end

local function resolve_t2_desc_override(item_id, item_def, fallback_desc)
	local function ensure_t2_prefix(text)
		if type(text) ~= "string" then
			return tr("ascendant.desc.fallback.component_upgrade")
		end
		if text:find("%[T2%]") then
			return text
		end
		return "<hl>[T2]</> " .. text
	end

	local overrides = data.ascendant_tiers_t2_description_overrides
	if type(overrides) ~= "table" then
		return ensure_t2_prefix(fallback_desc)
	end

	local override = overrides[item_id]
	if type(override) == "string" and override ~= "" then
		return ensure_t2_prefix(override)
	end

	if type(override) == "function" then
		local ok, result = pcall(override, item_def)
		if ok and type(result) == "string" and result ~= "" then
			return ensure_t2_prefix(result)
		end
	end

	return ensure_t2_prefix(fallback_desc)
end

local component_plan = {
	-- Productivity Stage I
	{ id = "c_miner", stage = 1, branch = "productivity" },
	{ id = "c_small_storage", stage = 1, branch = "productivity" },
	{ id = "c_repairer", stage = 1, branch = "productivity" },
	{ id = "c_repairkit", stage = 1, branch = "productivity" },
	{ id = "c_shield_generator", stage = 1, branch = "productivity" },

	-- Productivity Stage II
	{ id = "c_medium_storage", stage = 2, branch = "productivity" },
	{ id = "c_repairer_small_aoe", stage = 2, branch = "productivity" },
	{ id = "c_shield_generator2", stage = 2, branch = "productivity" },

	-- Productivity Stage III
	{ id = "c_adv_miner", stage = 3, branch = "productivity" },
	{ id = "c_large_storage", stage = 3, branch = "productivity" },
	{ id = "c_repairer_aoe", stage = 3, branch = "productivity" },
	{ id = "c_shield_generator3", stage = 3, branch = "productivity" },

	-- Energy Stage I
	{ id = "c_crystal_power", stage = 1, branch = "energy" },
	{ id = "c_portable_relay", stage = 1, branch = "energy" },
	{ id = "c_small_relay", stage = 1, branch = "energy" },
	{ id = "c_solar_cell", stage = 1, branch = "energy" },
	{ id = "c_small_battery", stage = 1, branch = "energy" },
	{ id = "c_capacitor", stage = 1, branch = "energy" },

	-- Energy Stage II
	{ id = "c_wind_turbine", stage = 2, branch = "energy" },
	{ id = "c_medium_capacitor", stage = 2, branch = "energy" },
	{ id = "c_power_relay", stage = 2, branch = "energy" },
	{ id = "c_wind_turbine_l", stage = 2, branch = "energy" },
	{ id = "c_power_transmitter", stage = 2, branch = "energy" },

	-- Energy Stage III
	{ id = "c_battery", stage = 3, branch = "energy" },
	{ id = "c_solar_panel", stage = 3, branch = "energy" },
	{ id = "c_power_core", stage = 3, branch = "energy" },
	{ id = "c_power_cell", stage = 3, branch = "energy" },
	{ id = "c_large_power_transmitter", stage = 3, branch = "energy" },

	-- Weaponry Stage I
	{ id = "c_portable_turret", stage = 1, branch = "weaponry" },
	{ id = "c_melee_pulse", stage = 1, branch = "weaponry" },
	{ id = "c_pulselasers", stage = 1, branch = "weaponry" },
	{ id = "c_adv_portable_turret", stage = 1, branch = "weaponry" },

	-- Weaponry Stage II
	{ id = "c_pulse_disrupter", stage = 2, branch = "weaponry" },
	{ id = "c_turret", stage = 2, branch = "weaponry" },
	{ id = "c_photon_cannon", stage = 2, branch = "weaponry" },
	{ id = "c_photon_beam", stage = 2, branch = "weaponry" },

	-- Weaponry Stage III
	{ id = "c_viral_pulse", stage = 3, branch = "weaponry" },
	{ id = "c_laser_turret", stage = 3, branch = "weaponry" },
	{ id = "c_plasma_cannon", stage = 3, branch = "weaponry" },
}

local unlocks = {
	productivity = { [1] = {}, [2] = {}, [3] = {} },
	energy = { [1] = {}, [2] = {}, [3] = {} },
	weaponry = { [1] = {}, [2] = {}, [3] = {} },
}

local next_index = 9200
for _, entry in ipairs(component_plan) do
	local base_component = data.components[entry.id]
	if base_component and type(base_component.RegisterComponent) == "function" then
		local t2_id = entry.id .. "_t2"
		if not data.components[t2_id] then
			local base_name = base_component.name or entry.id
			local component_def = {
				index = next_index,
				name = string.format("%s [T2]", base_name),
				texture = string.format("AscendantTiers/textures/icons/components/%s_t2.png", entry.id),
				production_recipe = apply_recipe_overrides(t2_id, build_t2_production_recipe(base_component)),
			}
			local stat_changes = apply_primary_role_scaling(entry.id, base_component, component_def)
			local fallback_desc = upgraded_desc(base_component, base_name, stat_changes)
			component_def.desc = resolve_t2_desc_override(t2_id, component_def, fallback_desc)

			base_component:RegisterComponent(t2_id, component_def)
			apply_mining_speed_overrides(entry.id, t2_id)
			next_index = next_index + 1
		else
			local base_name = base_component.name or entry.id
			local existing_component = data.components[t2_id]
			existing_component.name = string.format("%s [T2]", base_name)
			existing_component.texture = string.format("AscendantTiers/textures/icons/components/%s_t2.png", entry.id)
			existing_component.production_recipe = apply_recipe_overrides(t2_id, build_t2_production_recipe(base_component))
			local stat_changes = apply_primary_role_scaling(entry.id, base_component, existing_component)
			local fallback_desc = upgraded_desc(base_component, base_name, stat_changes)
			existing_component.desc = resolve_t2_desc_override(t2_id, existing_component, fallback_desc)
			apply_mining_speed_overrides(entry.id, t2_id)
		end

		table.insert(unlocks[entry.branch][entry.stage], t2_id)
	end
end

data.ascendant_tiers_t2_components = clone_table(unlocks)
