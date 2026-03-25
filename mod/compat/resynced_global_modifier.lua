if type(GetOptionValue) ~= "function" then
	return
end

local has_resynced_global_modifier = pcall(GetOptionValue, "global_modifier", "production_speed")
if not has_resynced_global_modifier then
	return
end

local function to_number_or_default(value, default_value)
	local numeric = tonumber(value)
	if type(numeric) == "number" then
		return numeric
	end
	return default_value
end

local function to_bool_or_default(value, default_value)
	if type(value) == "boolean" then
		return value
	end
	if type(value) == "number" then
		return value ~= 0
	end
	if type(value) == "string" then
		local lowered = string.lower(value)
		return lowered == "true" or lowered == "1" or lowered == "yes" or lowered == "on"
	end
	return default_value
end

local function get_modifier_option(option_id, default_value)
	local ok, value = pcall(GetOptionValue, "global_modifier", option_id)
	if not ok then
		return default_value
	end
	if type(default_value) == "boolean" then
		return to_bool_or_default(value, default_value)
	end
	return to_number_or_default(value, default_value)
end

local function collect_ids_recursive(source, output_set)
	if type(source) ~= "table" then
		return
	end

	for _, value in pairs(source) do
		if type(value) == "table" then
			collect_ids_recursive(value, output_set)
		elseif type(value) == "string" then
			output_set[value] = true
		end
	end
end

local function apply_production_speed(recipe, speed_multiplier)
	if type(recipe) ~= "table" or type(recipe.producers) ~= "table" then
		return
	end

	for producer_id, ticks in pairs(recipe.producers) do
		if type(ticks) == "number" and ticks > 0 then
			recipe.producers[producer_id] = math.max(1, math.ceil(ticks / speed_multiplier))
		end
	end
end

local function base_component_id(component_id)
	if type(component_id) ~= "string" then
		return component_id
	end
	return component_id:gsub("_t2$", "")
end

local function is_bot_frame(frame_def)
	if type(frame_def) ~= "table" then
		return false
	end
	if frame_def.trigger_channels ~= "bot" then
		return false
	end

	local race = frame_def.race
	return race == "robot" or race == "human" or race == "synced"
end

local ascendant_item_ids = {}
for item_id, _ in pairs(data.items or {}) do
	if type(item_id) == "string" and item_id:find("^ascendant_tiers_") then
		ascendant_item_ids[item_id] = true
	end
end

local ascendant_component_ids = {}
collect_ids_recursive(data.ascendant_tiers_t2_components, ascendant_component_ids)
if data.components and data.components.c_portablecrane_early then
	ascendant_component_ids.c_portablecrane_early = true
end

local ascendant_frame_ids = {}
collect_ids_recursive(data.ascendant_tiers_t2_buildings, ascendant_frame_ids)
collect_ids_recursive(data.ascendant_tiers_t2_robot_units, ascendant_frame_ids)

local ascendant_tech_ids = {}
for tech_id, tech_def in pairs(data.techs or {}) do
	if type(tech_id) == "string"
		and type(tech_def) == "table"
		and (tech_def.category == "Ascendant Tiers" or tech_def.category == "ascendant.tech.category.name")
	then
		ascendant_tech_ids[tech_id] = true
	end
end

local ore_ids = {
	metalore = true,
	crystal = true,
	laterite = true,
	silica = true,
	obsidian = true,
	blight_crystal = true,
}

local tool_component_ids = {
	c_miner = true,
	c_adv_miner = true,
	c_extractor = true,
}

local transfer_component_ids = {
	c_crane = true,
	c_portablecrane = true,
	c_internal_crane1 = true,
	c_internal_crane2 = true,
	c_internal_transporter = true,
	c_portablecrane_early = true,
}

local production_speed = math.max(1, get_modifier_option("production_speed", 1))
local production_multiplier = math.max(1, get_modifier_option("production_multiplier", 1))
local research_speed = math.max(1, get_modifier_option("research_speed", 1))
local bot_speed = get_modifier_option("bot_speed", 1)
local stack_size = math.max(1, get_modifier_option("stack_size", 1))
local ore_stack_size = math.max(1, get_modifier_option("ore_stack_size", 1))
local mining_range = get_modifier_option("mining_range", 1)
local mining_efficiency = math.max(1, get_modifier_option("mining_efficiency", 1))
local blight_extraction_efficiency = math.max(1, get_modifier_option("blight_extraction_efficiency", 1))
local energy_production = math.max(1, get_modifier_option("energy_production", 1))
local energy_range = math.max(1, get_modifier_option("energy_range", 1))
local repair_rate = get_modifier_option("repair_rate", 0)
local transfer_range = get_modifier_option("transfer_range", 0)
local stack_override = get_modifier_option("stack_override", false)

for item_id, _ in pairs(ascendant_item_ids) do
	local item_def = data.items[item_id]
	if type(item_def) == "table" then
		if type(item_def.production_recipe) == "table" then
			apply_production_speed(item_def.production_recipe, production_speed)

			if not item_def.convert_to then
				local amount = to_number_or_default(item_def.production_recipe.amount, 1)
				item_def.production_recipe.amount = math.max(1, math.ceil(amount * production_multiplier))
			end
		end

		if type(item_def.stack_size) == "number" and item_def.stack_size > 1 then
			if ore_ids[item_id] then
				item_def.stack_size = math.max(1, math.ceil(item_def.stack_size * ore_stack_size))
				if type(item_def.mining_recipe) == "table" then
					for miner_id, ticks in pairs(item_def.mining_recipe) do
						if type(ticks) == "number" and ticks > 0 then
							item_def.mining_recipe[miner_id] = math.max(1, math.ceil(ticks / mining_efficiency))
						end
					end
				end
			else
				if item_def.stack_size == 1 and stack_override then
					item_def.stack_size = 1
				else
					item_def.stack_size = math.max(1, math.ceil(item_def.stack_size * stack_size))
				end
			end
		end
	end
end

for component_id, _ in pairs(ascendant_component_ids) do
	local component_def = data.components and data.components[component_id]
	if type(component_def) == "table" then
		local root_id = base_component_id(component_id)

		if type(component_def.production_recipe) == "table" then
			apply_production_speed(component_def.production_recipe, production_speed)
		end

		if tool_component_ids[root_id] and type(component_def.miner_range) == "number" then
			component_def.miner_range = math.ceil(component_def.miner_range + mining_range)
		end

		if root_id == "c_blight_extractor" and type(component_def.extraction_time) == "number" and component_def.extraction_time > 0 then
			component_def.extraction_time = math.max(1, math.ceil(component_def.extraction_time / blight_extraction_efficiency))
		end

		if type(component_def.power) == "number" and component_def.power > 0 then
			component_def.power = math.ceil(component_def.power * energy_production)
		end
		if type(component_def.max_power) == "number" and component_def.max_power > 0 then
			component_def.max_power = math.ceil(component_def.max_power * energy_production)
		end
		if type(component_def.solar_power_generated) == "number" and component_def.solar_power_generated > 0 then
			component_def.solar_power_generated = math.ceil(component_def.solar_power_generated * energy_production)
		end
		if type(component_def.solar_power_summer) == "number" and component_def.solar_power_summer > 0 then
			component_def.solar_power_summer = math.ceil(component_def.solar_power_summer * energy_production)
		end

		if type(component_def.transfer_radius) == "number" then
			component_def.transfer_radius = math.ceil(component_def.transfer_radius * energy_range)
		end

		if type(component_def.repair) == "number" then
			component_def.repair = math.ceil(component_def.repair + repair_rate)
		end

		if transfer_component_ids[root_id] and type(component_def.range) == "number" then
			component_def.range = math.min(255, math.ceil(component_def.range + transfer_range))
		end
	end
end

for frame_id, _ in pairs(ascendant_frame_ids) do
	local frame_def = data.frames and data.frames[frame_id]
	if type(frame_def) == "table" then
		if type(frame_def.production_recipe) == "table" then
			apply_production_speed(frame_def.production_recipe, production_speed)
		end

		if is_bot_frame(frame_def) and type(frame_def.movement_speed) == "number" then
			frame_def.movement_speed = math.max(1, math.ceil(frame_def.movement_speed + bot_speed))
		end
	end
end

for tech_id, _ in pairs(ascendant_tech_ids) do
	local tech_def = data.techs and data.techs[tech_id]
	if type(tech_def) == "table" and type(tech_def.uplink_recipe) == "table" then
		local ticks = to_number_or_default(tech_def.uplink_recipe.ticks, nil)
		if type(ticks) == "number" and ticks > 0 then
			tech_def.uplink_recipe.ticks = math.max(1, math.ceil(ticks / research_speed))
		end
	end
end
