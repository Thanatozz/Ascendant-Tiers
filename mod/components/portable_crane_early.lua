local EARLY_CRANE_ID = "c_portablecrane_early"
local BASE_CRANE_ID = "c_portablecrane"
local PROTOTYPE_CRANE_NAME<const> = "Portable Transporter Prototype"
local GENERIC_VISUAL_ID<const> = "v_generic_i"
local PROTOTYPE_VISUAL_ID<const> = "v_portable_transporter_prototype_i"
local PROTOTYPE_VISUAL_SCALE<const> = { 1, 1, 1.5 }

local function clone_table(value)
	if type(value) ~= "table" then return value end
	local copy = {}
	for k, v in pairs(value) do
		copy[k] = clone_table(v)
	end
	return copy
end

local function base_recipe_producers(base_component)
	local recipe = base_component and base_component.production_recipe
	if type(recipe) == "table" and type(recipe.producers) == "table" then
		return clone_table(recipe.producers), recipe.amount or 1
	end

	return { c_assembler = 30 }, 1
end

local function ensure_prototype_visual()
	if not data or type(data.visuals) ~= "table" then
		return GENERIC_VISUAL_ID
	end

	local base_visual = data.visuals[GENERIC_VISUAL_ID]
	if type(base_visual) ~= "table" then
		return GENERIC_VISUAL_ID
	end

	local visual = clone_table(base_visual)
	visual.scale = clone_table(PROTOTYPE_VISUAL_SCALE)
	data.visuals[PROTOTYPE_VISUAL_ID] = visual
	return PROTOTYPE_VISUAL_ID
end

local function early_crane_definition(base_component)
	local producers, amount = base_recipe_producers(base_component)
	local prototype_visual = ensure_prototype_visual()

	return {
		index = 9190,
		name = PROTOTYPE_CRANE_NAME,
		desc = "Experimental compact transporter prototype.",
		texture = "AscendantTiers/textures/icons/components/c_portablecrane_early_a.png",
		visual = prototype_visual,
		attachment_size = "Small",
		production_recipe = CreateProductionRecipe({
			circuit_board = 1,
			crystal = 5,
		}, producers, amount),
	}
end

local base_component = data.components[BASE_CRANE_ID]
if base_component and type(base_component.RegisterComponent) == "function" then
	local definition = early_crane_definition(base_component)

	if data.components[EARLY_CRANE_ID] then
		local existing = data.components[EARLY_CRANE_ID]
		for field, field_value in pairs(definition) do
			existing[field] = clone_table(field_value)
		end
	else
		base_component:RegisterComponent(EARLY_CRANE_ID, definition)
	end
end
