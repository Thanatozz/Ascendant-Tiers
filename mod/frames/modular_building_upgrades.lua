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
local building_balance = t2_balance.buildings or {}
local t2_material_map = ((t2_balance.materials or {}).map) or default_t2_material_map

local function socket_scale_factor(socket_type)
	local socket_scale = building_balance.socket_scale
	if type(socket_scale) == "table" then
		local scaled_by_type = socket_scale[socket_type]
		if type(scaled_by_type) == "number" then
			return scaled_by_type
		end
		if type(socket_scale.default) == "number" then
			return socket_scale.default
		end
	end

	return 1.0
end

local function scale_sockets_with_mixed_rules(sockets)
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

local function add_amount(target, item_id, amount)
	target[item_id] = (target[item_id] or 0) + amount
end

local function round_up_to_10(value)
	if type(value) ~= "number" then return value end
	return math.max(10, math.ceil(value / 10) * 10)
end

local texture_overrides = {
	f_building1x1_4s_t2 = "AscendantTiers/textures/icons/frame/building_1x1_4s_t2.png",
	f_building1x1_2s_t2 = "AscendantTiers/textures/icons/frame/building_1x1_2s_t2.png",
	f_building1x1_2m_t2 = "AscendantTiers/textures/icons/frame/building_1x1_2m_t2.png",
	f_building1x1_2m_defense_t2 = "AscendantTiers/textures/icons/frame/building_1x1_2m_defense_t2.png",
	f_building1x1_2l_t2 = "AscendantTiers/textures/icons/frame/building_1x1_2l_t2.png",
	f_storage16_t2 = "AscendantTiers/textures/icons/frame/storage_16_t2.png",
	f_building2x1_4m_t2 = "AscendantTiers/textures/icons/frame/building_2x1_4m_t2.png",
	f_building2x1_4m_basic_t2 = "AscendantTiers/textures/icons/frame/building_2x1_4m_basic_t2.png",
	f_building2x1_4s2m_t2 = "AscendantTiers/textures/icons/frame/building_2x1_4s2m_t2.png",
	f_building2x1_2m2s_t2 = "AscendantTiers/textures/icons/frame/building_2x1_2m2s_t2.png",
	f_building2x1_2m_compact_t2 = "AscendantTiers/textures/icons/frame/building_2x1_2m_compact_t2.png",
	f_building2x1_2m_storage_t2 = "AscendantTiers/textures/icons/frame/building_2x1_2m_storage_t2.png",
	f_building2x1_2m2l_t2 = "AscendantTiers/textures/icons/frame/building_2x1_2m2l_t2.png",
	f_building2x2_2m6s_t2 = "AscendantTiers/textures/icons/frame/building_2x2_2m6s_t2.png",
	f_building2x2_4m_t2 = "AscendantTiers/textures/icons/frame/building_2x2_4m_t2.png",
	f_building2x2_4m2l_t2 = "AscendantTiers/textures/icons/frame/building_2x2_4m2l_t2.png",
	f_building2x2_6m_t2 = "AscendantTiers/textures/icons/frame/building_2x2_6m_t2.png",
	f_building2x2_4m2l_a_t2 = "AscendantTiers/textures/icons/frame/building_2x2_4m2l_a_t2.png",
	f_building2x2_4m2l_b_t2 = "AscendantTiers/textures/icons/frame/building_2x2_4m2l_b_t2.png",
	f_building3x2_2l6m_t2 = "AscendantTiers/textures/icons/frame/building_3x2_2l6m_t2.png",
	f_building3x2_4m4s_t2 = "AscendantTiers/textures/icons/frame/building_3x2_4m4s_t2.png",
	f_storage32_t2 = "AscendantTiers/textures/icons/frame/storage_32_t2.png",
	f_storage48_t2 = "AscendantTiers/textures/icons/frame/storage_48_t2.png",
}

local building_plan = {
	-- Stage 1 (Starter)
	{ stage = 1, base_id = "f_building1x1c", t2_id = "f_building1x1_4s_t2", name = "Building 1x1 (4S) [T2]" },
	{ stage = 1, base_id = "f_building1x1d", t2_id = "f_building1x1_2s_t2", name = "Building 1x1 (2S) [T2]" },
	{ stage = 1, base_id = "f_building1x1f", t2_id = "f_storage16_t2", name = "Storage Block (16) [T2]" },
	{ stage = 2, base_id = "f_building1x1g", t2_id = "f_storage32_t2", name = "Storage Block (32) [T2]" },
	{ stage = 1, base_id = "f_building1x1h", t2_id = "f_building1x1_2m_defense_t2", name = "Defense Block (2M) [T2]" },
	{ stage = 1, base_id = "f_building2x1f", t2_id = "f_building2x1_2m2s_t2", name = "Building 2x1 (2M2S) [T2]" },
	{ stage = 1, base_id = "f_building2x1g", t2_id = "f_building2x1_2m_compact_t2", name = "Building 2x1 (2M) (Compact) [T2]" },

	-- Stage 2 (Medium)
	{ stage = 2, base_id = "f_building1x1a", t2_id = "f_building1x1_2m_t2", name = "Building 1x1 (2M) [T2]" },
	{ stage = 3, base_id = "f_building1x1e", t2_id = "f_storage48_t2", name = "Storage Block (48) [T2]" },
	{ stage = 2, base_id = "f_building2x1a", t2_id = "f_building2x1_4m_basic_t2", name = "Building 2x1 (4M) (Basic) [T2]" },
	{ stage = 2, base_id = "f_building2x1c", t2_id = "f_building2x1_4m_t2", name = "Building 2x1 (4M) [T2]" },
	{ stage = 2, base_id = "f_building2x1e", t2_id = "f_building2x1_4s2m_t2", name = "Building 2x1 (4S2M) [T2]" },
	{ stage = 2, base_id = "f_building2x1d", t2_id = "f_building2x1_2m_storage_t2", name = "Building 2x1 (2M) (Storage) [T2]" },
	{ stage = 2, base_id = "f_building2x2f", t2_id = "f_building2x2_4m_t2", name = "Building 2x2 (4M) [T2]" },
	{ stage = 2, base_id = "f_building2x2b", t2_id = "f_building2x2_6m_t2", name = "Building 2x2 (6M) [T2]" },
	{ stage = 2, base_id = "f_building2x2e", t2_id = "f_building2x2_2m6s_t2", name = "Building 2x2 (2M6S) [T2]" },
	{ stage = 2, base_id = "f_building3x2b", t2_id = "f_building3x2_4m4s_t2", name = "Building 3x2 (4M4S) [T2]" },

	-- Stage 3 (Large)
	{ stage = 3, base_id = "f_building1x1b", t2_id = "f_building1x1_2l_t2", name = "Building 1x1 (2L) [T2]" },
	{ stage = 3, base_id = "f_building2x1b", t2_id = "f_building2x1_2m2l_t2", name = "Building 2x1 (2M2L) [T2]" },
	{ stage = 3, base_id = "f_building2x2a", t2_id = "f_building2x2_4m2l_t2", name = "Building 2x2 (4M2L) [T2]" },

	-- Stage 4 (Epic)
	{ stage = 4, base_id = "f_building2x2c", t2_id = "f_building2x2_4m2l_a_t2", name = "Building 2x2 (4M2L) (Epic A) [T2]" },
	{ stage = 4, base_id = "f_building2x2d", t2_id = "f_building2x2_4m2l_b_t2", name = "Building 2x2 (4M2L) (Epic B) [T2]" },
	{ stage = 4, base_id = "f_building3x2a", t2_id = "f_building3x2_2l6m_t2", name = "Building 3x2 (2L6M) [T2]" },
}

local function map_to_t2_if_available(item_id)
	local mapped = t2_material_map[item_id]
	if mapped then
		return mapped
	end
	return item_id
end

local function build_t2_construction_recipe(base_frame)
	local base_recipe = base_frame and base_frame.construction_recipe
	if type(base_recipe) ~= "table" or type(base_recipe.ingredients) ~= "table" then
		return nil
	end

	local ingredients = {}
	for item_id, amount in pairs(base_recipe.ingredients) do
		add_amount(ingredients, map_to_t2_if_available(item_id), amount)
	end

	local ticks = base_recipe.ticks or 1
	return CreateConstructionRecipe(ingredients, ticks)
end

local function apply_construction_recipe_overrides(t2_id, recipe)
	if type(recipe) ~= "table" or type(recipe.ingredients) ~= "table" then
		return recipe
	end

	local overrides = building_balance.construction_overrides
	local override = type(overrides) == "table" and overrides[t2_id]
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

			local round_mode = convert.round or "floor"
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

	return recipe
end

local function ensure_scaled_visual(base_visual_id, t2_visual_id)
	if type(base_visual_id) ~= "string" then return base_visual_id end
	local base_visual = data.visuals[base_visual_id]
	if not base_visual then return base_visual_id end

	if not data.visuals[t2_visual_id] then
		data.visuals[t2_visual_id] = clone_table(base_visual)
	end

	local t2_visual = data.visuals[t2_visual_id]
	t2_visual.sockets = scale_sockets_with_mixed_rules(base_visual.sockets)
	return t2_visual_id
end

local function recipe_uses_t2_ic_chip(recipe)
	local ingredients = recipe and recipe.ingredients
	local chip_count = type(ingredients) == "table" and ingredients.ascendant_tiers_ic_chip
	return type(chip_count) == "number" and chip_count > 0
end

local function resolve_t2_desc_override(frame_id, frame_def, fallback_desc)
	local function ensure_t2_prefix(text)
		if type(text) ~= "string" then
			return "<hl>[T2]</> Ascendant Tiers frame upgrade."
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

local function resolve_unlock_stage(entry, frame_def)
	if entry.stage < 3 and recipe_uses_t2_ic_chip(frame_def and frame_def.construction_recipe) then
		return 3
	end
	return entry.stage
end

local function resolve_health_multiplier(entry)
	if type(entry.health_mult) == "number" then
		return entry.health_mult
	end

	local overrides = building_balance.health_multiplier_overrides
	if type(overrides) == "table" and type(overrides[entry.t2_id]) == "number" then
		return overrides[entry.t2_id]
	end

	if type(building_balance.health_multiplier_default) == "number" then
		return building_balance.health_multiplier_default
	end

	return 1.35
end

local function resolve_storage_multiplier(entry)
	if type(entry.storage_mult) == "number" then
		return entry.storage_mult
	end

	local overrides = building_balance.storage_multiplier_overrides
	if type(overrides) == "table" and type(overrides[entry.t2_id]) == "number" then
		return overrides[entry.t2_id]
	end

	return nil
end

local function resolve_storage_slot_bonus(entry)
	if type(entry.storage_slot_bonus) == "number" then
		return entry.storage_slot_bonus
	end

	local overrides = building_balance.storage_slot_bonus_overrides
	if type(overrides) == "table" and type(overrides[entry.t2_id]) == "number" then
		return overrides[entry.t2_id]
	end

	return 0
end

local stage_unlocks = { [1] = {}, [2] = {}, [3] = {}, [4] = {} }
local next_index = 9300

for _, entry in ipairs(building_plan) do
	local base_frame = data.frames[entry.base_id]
	if base_frame and not data.frames[entry.t2_id] then
		local frame_def = clone_table(base_frame)
		frame_def.index = next_index
		frame_def.name = entry.name or string.format("%s [T2]", base_frame.name or entry.base_id)
		local fallback_desc = (base_frame.desc or "Ascendant Tiers frame variant.") ..
			" Ascendant Tiers T2 upgrade with expanded socket capacity."
		frame_def.desc = resolve_t2_desc_override(entry.t2_id, frame_def, fallback_desc)
		frame_def.texture = texture_overrides[entry.t2_id] or base_frame.texture
		frame_def.construction_recipe =
			apply_construction_recipe_overrides(entry.t2_id, build_t2_construction_recipe(base_frame) or base_frame.construction_recipe)

		if type(base_frame.health_points) == "number" and base_frame.health_points > 0 then
			frame_def.health_points = math.ceil(base_frame.health_points * resolve_health_multiplier(entry))
		end

		if type(base_frame.component_boost) == "number" and base_frame.component_boost > 0 then
			frame_def.component_boost = round_up_to_10(entry.component_boost or base_frame.component_boost)
		end

		local storage_multiplier = resolve_storage_multiplier(entry)
		if type(frame_def.slots) == "table" and type(frame_def.slots.storage) == "number" and type(storage_multiplier) == "number" then
			frame_def.slots.storage = math.max(1, math.ceil(frame_def.slots.storage * storage_multiplier))
			frame_def.desc = resolve_t2_desc_override(entry.t2_id, frame_def, frame_def.desc)
		end

		local storage_slot_bonus = resolve_storage_slot_bonus(entry)
		if type(frame_def.slots) == "table" and type(frame_def.slots.storage) == "number" and storage_slot_bonus ~= 0 then
			frame_def.slots.storage = math.max(1, frame_def.slots.storage + math.floor(storage_slot_bonus + 0.5))
			frame_def.desc = resolve_t2_desc_override(entry.t2_id, frame_def, frame_def.desc)
		end

		local visual_id = entry.visual_id or (base_frame.visual .. "_" .. entry.t2_id)
		frame_def.visual = ensure_scaled_visual(base_frame.visual, visual_id)

		Frame:RegisterFrame(entry.t2_id, frame_def)
		next_index = next_index + 1
	end

	local unlocked_frame = data.frames[entry.t2_id]
	if unlocked_frame then
		local unlock_stage = resolve_unlock_stage(entry, unlocked_frame)
		table.insert(stage_unlocks[unlock_stage], entry.t2_id)
	end
end

data.ascendant_tiers_t2_buildings = clone_table(stage_unlocks)
