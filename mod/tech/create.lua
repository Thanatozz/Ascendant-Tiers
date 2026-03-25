local category_name = "ascendant.tech.category.name"
local legacy_category_name = "Ascendant Tiers"
local discovery_tech_id = "tech_ascendant_tiers_start"
local initial_tech_id = "tech_small_buildings_t2"
local category_texture = "AscendantTiers/textures/icons/tech/ascendant_tiers_ii.png"
local early_portable_crane_id = "c_portablecrane_early"
local EARLY_PORTABLE_CRANE_OPTION_ID<const> = "enable_early_portable_crane"
local TECH_COST_OPTION_ID<const> = "t2_tech_cost_pct"

local function early_portable_crane_enabled()
	if type(AscendantTiersGetSetting) ~= "function" then
		return true
	end

	local value = AscendantTiersGetSetting(EARLY_PORTABLE_CRANE_OPTION_ID, true)
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
	return true
end

local function discovery_unlocks()
	if not early_portable_crane_enabled() then
		return {}
	end
	return { early_portable_crane_id }
end

local function clone_table(value)
	if type(value) ~= "table" then return value end
	local copy = {}
	for key, item in pairs(value) do
		copy[key] = clone_table(item)
	end
	return copy
end

local function get_t2_tech_cost_multiplier()
	local t2_balance = data.ascendant_tiers_t2_balance or {}
	local cost_balance = t2_balance.cost or {}
	local multiplier = tonumber(cost_balance.tech_recipe_multiplier)
	if type(multiplier) == "number" then
		return multiplier
	end

	if type(AscendantTiersGetSetting) == "function" then
		local percent = tonumber(AscendantTiersGetSetting(TECH_COST_OPTION_ID, 100))
		if type(percent) == "number" then
			return percent / 100.0
		end
	end

	return 1.0
end

local function scale_recipe_ingredients(ingredients, multiplier)
	if type(ingredients) ~= "table" then
		return ingredients
	end

	local effective_multiplier = 1.0
	if type(multiplier) == "number" and multiplier > 0 then
		effective_multiplier = multiplier
	end

	local scaled = {}
	for item_id, amount in pairs(ingredients) do
		if type(amount) == "number" and amount > 0 then
			local rounded = math.ceil(amount * effective_multiplier)
			if rounded < 1 then
				rounded = 1
			end
			scaled[item_id] = rounded
		else
			scaled[item_id] = amount
		end
	end

	return scaled
end

function AscendantTiersCreateUplinkRecipe(ingredients, progress_count)
	local multiplier = get_t2_tech_cost_multiplier()
	local scaled_ingredients = scale_recipe_ingredients(ingredients, multiplier)
	return CreateUplinkRecipe(scaled_ingredients, progress_count)
end

local function ensure_ascendant_tiers_category()
	local categories = data.tech_categories
	if type(categories) ~= "table" then return end

	for _, category in ipairs(categories) do
		if category.name == category_name or category.name == legacy_category_name then
			category.name = category_name
			category.discovery_tech = discovery_tech_id
			category.initial_tech = initial_tech_id
			category.sub_categories = { category_name }
			category.texture = category_texture
			return
		end
	end

	table.insert(categories, {
		name = category_name,
		discovery_tech = discovery_tech_id,
		initial_tech = initial_tech_id,
		sub_categories = { category_name },
		texture = category_texture,
	})
end

ensure_ascendant_tiers_category()

data.techs[discovery_tech_id] = {
	order = 1000,
	name = "ascendant.tech.discovery.name",
	desc = "ascendant.tech.discovery.desc",
	texture = category_texture,
	require_tech = { "t_assembly" },
	unlocks = discovery_unlocks(),
}
