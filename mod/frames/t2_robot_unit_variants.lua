local function clone_table(value)
	if type(value) ~= "table" then return value end
	local copy = {}
	for k, v in pairs(value) do
		copy[k] = clone_table(v)
	end
	return copy
end

local function scale_count(base_count, factor)
	local scaled = math.ceil(base_count * factor)
	if scaled < (base_count + 1) then
		scaled = base_count + 1
	end
	return scaled
end

local function socket_scale_factor(socket_type)
	if socket_type == "Internal" then
		return 1.5
	end
	if socket_type == "Small" or socket_type == "Medium" or socket_type == "Large" then
		return 2.0
	end
	return 1.0
end

local function scale_robot_sockets(sockets)
	if type(sockets) ~= "table" then return nil end

	local grouped_names = {}
	local type_order = {}
	for _, socket in ipairs(sockets) do
		local socket_name = socket[1] or ""
		local socket_type = socket[2] or "Internal"
		if not grouped_names[socket_type] then
			grouped_names[socket_type] = {}
			table.insert(type_order, socket_type)
		end
		table.insert(grouped_names[socket_type], socket_name)
	end

	local scaled_sockets = {}
	for _, socket_type in ipairs(type_order) do
		local names = grouped_names[socket_type]
		local factor = socket_scale_factor(socket_type)
		local target_count = scale_count(#names, factor)
		for i = 1, target_count do
			local name = names[((i - 1) % #names) + 1]
			table.insert(scaled_sockets, { name, socket_type })
		end
	end

	return scaled_sockets
end

local function has_sml_sockets(sockets)
	if type(sockets) ~= "table" then return false end
	for _, socket in ipairs(sockets) do
		local socket_type = socket[2]
		if socket_type == "Small" or socket_type == "Medium" or socket_type == "Large" then
			return true
		end
	end
	return false
end

local function scale_inventory_slots(slots, factor)
	if type(slots) ~= "table" then return end
	for slot_type, count in pairs(slots) do
		if type(count) == "number" and count > 0 then
			slots[slot_type] = math.max(1, math.ceil(count * factor))
		end
	end
end

local function scale_movement_speed(frame_def, factor)
	local speed = frame_def and frame_def.movement_speed
	if type(speed) == "number" and speed > 0 then
		frame_def.movement_speed = speed * factor
	end
end

local function add_amount(target, item_id, amount)
	target[item_id] = (target[item_id] or 0) + amount
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

local function map_to_t2_if_available(item_id)
	local mapped = t2_material_map[item_id]
	if mapped then
		return mapped
	end

	return item_id
end

local function build_t2_production_recipe(base_frame)
	local base_recipe = base_frame and base_frame.production_recipe
	if type(base_recipe) ~= "table" or type(base_recipe.ingredients) ~= "table" then
		return nil
	end

	local ingredients = {}
	for item_id, amount in pairs(base_recipe.ingredients) do
		add_amount(ingredients, map_to_t2_if_available(item_id), amount)
	end

	local producers = {}
	if type(base_recipe.producers) == "table" then
		for item_id, amount in pairs(base_recipe.producers) do
			add_amount(producers, map_to_t2_if_available(item_id), amount)
		end
	end

	return CreateProductionRecipe(ingredients, producers, base_recipe.amount or 1)
end

local function resolve_t2_desc_override(frame_id, frame_def, fallback_desc)
	local function ensure_t2_prefix(text)
		if type(text) ~= "string" then
			return "<hl>[T2]</> Ascendant Tiers robot-unit upgrade."
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

	local override = overrides[frame_id]
	if type(override) == "string" and override ~= "" then
		return ensure_t2_prefix(override)
	end

	if type(override) == "function" then
		local ok, result = pcall(override, frame_def)
		if ok and type(result) == "string" and result ~= "" then
			return ensure_t2_prefix(result)
		end
	end

	return ensure_t2_prefix(fallback_desc)
end

local unit_plan = {
	{ id = "f_carrier_bot", stage = 1 },
	{ id = "f_bot_1s_a", stage = 1 },
	{ id = "f_bot_1s_b", stage = 1 },
	{ id = "f_bot_2s", stage = 1 },
	{ id = "f_bot_1m_a", stage = 1 },

	{ id = "f_transport_bot", stage = 2 },
	{ id = "f_bot_1m1s", stage = 2 },
	{ id = "f_bot_1m_b", stage = 2 },
	{ id = "f_bot_1l_a", stage = 2 },

	{ id = "f_bot_1m_c", stage = 3 },
	{ id = "f_bot_1s_as", stage = 3 },
	{ id = "f_bot_1s_adw", stage = 3 },
	{ id = "f_bot_2m_as", stage = 3 },
}

local stage_unlocks = { [1] = {}, [2] = {}, [3] = {} }
local next_index = 9400

for _, entry in ipairs(unit_plan) do
	local base_frame = data.frames[entry.id]
	if base_frame then
		local t2_id = entry.id .. "_t2"
		if not data.frames[t2_id] then
			local frame_def = clone_table(base_frame)
			frame_def.index = next_index
			frame_def.name = string.format("%s [T2]", base_frame.name or entry.id)
			local fallback_desc = (base_frame.desc or "Ascendant Tiers robot unit variant.") ..
				" Ascendant Tiers T2 variant with expanded socket capacity."
			frame_def.desc = resolve_t2_desc_override(t2_id, frame_def, fallback_desc)
			frame_def.texture = string.format("AscendantTiers/textures/icons/frame/%s_t2.png", entry.id)
			frame_def.production_recipe = build_t2_production_recipe(base_frame) or base_frame.production_recipe
			frame_def.slots = clone_table(base_frame.slots)

			if type(base_frame.health_points) == "number" and base_frame.health_points > 0 then
				frame_def.health_points = math.ceil(base_frame.health_points * 1.25)
			end

			local base_visual = data.visuals[base_frame.visual]
			local unit_has_sml_sockets = has_sml_sockets(base_visual and base_visual.sockets)
			if base_visual and type(base_visual.sockets) == "table" and #base_visual.sockets > 0 then
				local visual_id = base_frame.visual .. "_" .. t2_id
				if not data.visuals[visual_id] then
					local visual_copy = clone_table(base_visual)
					visual_copy.sockets = scale_robot_sockets(base_visual.sockets)
					data.visuals[visual_id] = visual_copy
				end
				frame_def.visual = visual_id
			end

			-- Units without S/M/L sockets get 2x inventory as requested.
			if not unit_has_sml_sockets then
				scale_inventory_slots(frame_def.slots, 2.0)
				scale_movement_speed(frame_def, 1.5)
				frame_def.desc = resolve_t2_desc_override(t2_id, frame_def, frame_def.desc)
			end

			Frame:RegisterFrame(t2_id, frame_def)
			next_index = next_index + 1
		end

		table.insert(stage_unlocks[entry.stage], t2_id)
	end
end

data.ascendant_tiers_t2_robot_units = clone_table(stage_unlocks)
