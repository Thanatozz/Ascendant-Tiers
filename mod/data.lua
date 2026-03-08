local package = ...

package.includes = {
	"items/mod_material_progression.lua",
	"descriptions/t2_description_overrides.lua",
	"frames/modular_building_upgrades.lua",
	"components/t2_component_variants.lua",
	"frames/t2_robot_unit_variants.lua",
	"tech/create.lua",
	"tech/modular_building_t2_techs.lua",
	"tech/t2_components_and_units_tech.lua",
	"ui.lua",
}

function package:init()
end

function package:on_player_faction_spawn(faction, is_respawn, player_faction_num)
	if faction:IsUnlocked("t_assembly") and not faction:IsUnlocked("tech_ascendant_tiers_start") then
		faction:Unlock("tech_ascendant_tiers_start")
	end
end

function MapMsg.OnTechResearch(faction, tech_id)
	if tech_id == "t_assembly" and not faction:IsUnlocked("tech_ascendant_tiers_start") then
		faction:Unlock("tech_ascendant_tiers_start")
	end
end
