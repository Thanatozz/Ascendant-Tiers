local function clone_table(value)
	if type(value) ~= "table" then return value end
	local copy = {}
	for k, v in pairs(value) do
		copy[k] = clone_table(v)
	end
	return copy
end

local t2_material_map = {
	metalplate = "ascendant_tiers_metal_plate",
	reinforced_plate = "ascendant_tiers_reinforced_plate",
	energized_plate = "ascendant_tiers_energized_plate",
	hdframe = "ascendant_tiers_high_density_frame",
	high_density_frame = "ascendant_tiers_high_density_frame",
	circuit_board = "ascendant_tiers_circuit_board",
	icchip = "ascendant_tiers_ic_chip",
	ic_chip = "ascendant_tiers_ic_chip",
}

local function map_to_t2_material_if_available(item_id)
	return t2_material_map[item_id] or item_id
end

local function add_amount(target, item_id, amount)
	target[item_id] = (target[item_id] or 0) + amount
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

	local ingredients = {}
	for item_id, amount in pairs(base_recipe.ingredients) do
		if is_component_id(item_id) then
			add_amount(ingredients, to_t2_component_id(item_id), amount)
		else
			add_amount(ingredients, map_to_t2_material_if_available(item_id), amount * 2)
		end
	end

	local producers = {}
	if type(base_recipe.producers) == "table" then
		for item_id, amount in pairs(base_recipe.producers) do
			add_amount(producers, map_to_t2_material_if_available(item_id), amount)
		end
	end

	return CreateProductionRecipe(ingredients, producers, base_recipe.amount or 1)
end

local function apply_recipe_overrides(component_id, recipe)
	if type(recipe) ~= "table" or type(recipe.ingredients) ~= "table" then
		return recipe
	end

	if component_id == "c_miner_t2" then
		local metalbar_count = recipe.ingredients.metalbar
		if type(metalbar_count) == "number" and metalbar_count > 0 then
			recipe.ingredients.metalbar = nil
			recipe.ingredients.ascendant_tiers_metal_plate =
				(recipe.ingredients.ascendant_tiers_metal_plate or 0) + metalbar_count
		end
	elseif component_id == "c_portable_relay_t2" then
		recipe.ingredients.metalbar = nil
		recipe.ingredients.ascendant_tiers_metal_plate = 5
	end

	return recipe
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
	shield_max = { "shield", "shields" },
	damage = { "damage", "damages" },
	dotdps = { "dps", "dot", "burn" },
	power = { "power", "energy" },
	drain_rate = { "drain", "consumes", "consumption", "upkeep" },
	max_power = { "power", "energy" },
	solar_power_generated = { "solar", "sunlight" },
	solar_power_summer = { "solar", "summer" },
	power_storage = { "storage", "capacity", "battery", "energy" },
	power_capacity = { "storage", "capacity", "battery", "energy" },
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
		local scaled_repair = scaled_number(base_component, "repair", 2)
		if scaled_repair then
			component_def.repair = scaled_repair
			collect_stat_change(base_component, "repair", scaled_repair, stat_changes)
		end
	end

	if shield_components[base_component_id] then
		local scaled_shield = scaled_number(base_component, "shield_max", 2)
		if scaled_shield then
			component_def.shield_max = scaled_shield
			collect_stat_change(base_component, "shield_max", scaled_shield, stat_changes)
		end
	end

	if damage_components[base_component_id] then
		local scaled_damage = scaled_number(base_component, "damage", 2)
		if scaled_damage then
			component_def.damage = scaled_damage
			collect_stat_change(base_component, "damage", scaled_damage, stat_changes)
		end

		local scaled_dot = scaled_number(base_component, "dotdps", 2)
		if scaled_dot then
			component_def.dotdps = scaled_dot
			collect_stat_change(base_component, "dotdps", scaled_dot, stat_changes)
		end
	end

	if energy_generation_components[base_component_id] then
		local scaled_power = scaled_number(base_component, "power", 2, true)
		if scaled_power then
			component_def.power = scaled_power
			collect_stat_change(base_component, "power", scaled_power, stat_changes)
		end

		local scaled_wind = scaled_number(base_component, "max_power", 2, true)
		if scaled_wind then
			component_def.max_power = scaled_wind
			collect_stat_change(base_component, "max_power", scaled_wind, stat_changes)
		end

		local scaled_solar_day = scaled_number(base_component, "solar_power_generated", 2, true)
		if scaled_solar_day then
			component_def.solar_power_generated = scaled_solar_day
			collect_stat_change(base_component, "solar_power_generated", scaled_solar_day, stat_changes)
		end

		local scaled_solar_summer = scaled_number(base_component, "solar_power_summer", 2, true)
		if scaled_solar_summer then
			component_def.solar_power_summer = scaled_solar_summer
			collect_stat_change(base_component, "solar_power_summer", scaled_solar_summer, stat_changes)
		end
	end

	if battery_components[base_component_id] then
		local scaled_storage = scaled_number(base_component, "power_storage", 2, true)
		if scaled_storage then
			component_def.power_storage = scaled_storage
			collect_stat_change(base_component, "power_storage", scaled_storage, stat_changes)
		end

		local scaled_capacity = scaled_number(base_component, "power_capacity", 2, true)
		if scaled_capacity then
			component_def.power_capacity = scaled_capacity
			collect_stat_change(base_component, "power_capacity", scaled_capacity, stat_changes)
		end
	end

	if base_component_id == "c_crystal_power" then
		local scaled_drain = scaled_number(base_component, "drain_rate", 2, true)
		if scaled_drain then
			component_def.drain_rate = scaled_drain
			collect_stat_change(base_component, "drain_rate", scaled_drain, stat_changes)
		end

		local scaled_storage = scaled_number(base_component, "power_storage", 2, true)
		if scaled_storage then
			component_def.power_storage = scaled_storage
			collect_stat_change(base_component, "power_storage", scaled_storage, stat_changes)
		end

		local scaled_capacity = scaled_number(base_component, "power_capacity", 2, true)
		if scaled_capacity then
			component_def.power_capacity = scaled_capacity
			collect_stat_change(base_component, "power_capacity", scaled_capacity, stat_changes)
		end

		local base_power = base_component.power
		if type(base_power) == "number" and base_power < 0 then
			local scaled_negative_power = base_power * 2
			component_def.power = scaled_negative_power
			collect_stat_change(base_component, "power", scaled_negative_power, stat_changes)
		end
	end

	if power_field_components[base_component_id] then
		local range_fields = { "transfer_radius", "range", "power_range", "relay_range", "field_radius", "radius" }
		for _, field in ipairs(range_fields) do
			local scaled_range = scaled_number(base_component, field, 2, true)
			if scaled_range then
				component_def[field] = scaled_range
				collect_stat_change(base_component, field, scaled_range, stat_changes)
			end
		end
	end

	return stat_changes
end

local function apply_mining_speed_overrides(base_component_id, t2_component_id)
	if not miner_components[base_component_id] then
		return
	end

	for _, item_def in pairs(data.items) do
		local mining_recipe = item_def and item_def.mining_recipe
		local base_ticks = type(mining_recipe) == "table" and mining_recipe[base_component_id]
		if type(base_ticks) == "number" and base_ticks > 0 then
			mining_recipe[t2_component_id] = math.max(1, math.floor(base_ticks / 2))
		end
	end
end

local function upgraded_desc(base_component, base_name, stat_changes)
	local original_desc = type(base_component.desc) == "string" and base_component.desc or ""
	local desc_body = replace_stat_values_in_desc(original_desc, stat_changes or {})
	if desc_body == "" then
		desc_body = string.format(
			"%s variant with 2x efficiency in its primary function (role-focused, not 2x every stat).",
			base_name
		)
	end
	if desc_body:find("%[T2%]") then
		return desc_body
	end
	return "<hl>[T2]</> " .. desc_body
end

local function resolve_t2_desc_override(item_id, item_def, fallback_desc)
	local function ensure_t2_prefix(text)
		if type(text) ~= "string" then
			return "<hl>[T2]</> Ascendant Tiers component upgrade."
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
