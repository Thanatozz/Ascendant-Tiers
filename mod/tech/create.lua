local category_name = "Ascendant Tiers"
local discovery_tech_id = "tech_ascendant_tiers_start"
local initial_tech_id = "tech_small_buildings_t2"
local category_texture = "AscendantTiers/textures/icons/tech/ascendant_tiers_ii.png"

local function ensure_ascendant_tiers_category()
	local categories = data.tech_categories
	if type(categories) ~= "table" then return end

	for _, category in ipairs(categories) do
		if category.name == category_name then
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
	name = "Ascendant Tiers",
	desc = "Auto-unlocked gateway tech for the Ascendant Tiers branch.",
	texture = category_texture,
	require_tech = { "t_assembly" },
	unlocks = {},
}
