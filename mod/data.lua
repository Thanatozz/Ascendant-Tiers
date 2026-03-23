local package = ...
local ASCENDANT_TIERS_SETTINGS_KEY<const> = "ascendant_tiers"
local EARLY_PORTABLE_CRANE_OPTION_ID<const> = "enable_early_portable_crane"
local EARLY_PORTABLE_CRANE_ID<const> = "c_portablecrane_early"

package.includes = {
	"items/mod_material_progression.lua",
	"descriptions/t2_description_overrides.lua",
	"balance/t2_balance_config.lua",
	"frames/modular_building_upgrades.lua",
	"components/portable_crane_early.lua",
	"components/t2_component_variants.lua",
	"frames/t2_robot_unit_variants.lua",
	"tech/create.lua",
	"tech/modular_building_t2_techs.lua",
	"tech/t2_components_and_units_tech.lua",
	"ui.lua",
}

function AscendantTiersGetSetting(option_id, default_value)
	if not Map or type(Map.GetSettings) ~= "function" then
		return default_value
	end

	local settings = Map.GetSettings()
	local mod_settings = settings and settings[ASCENDANT_TIERS_SETTINGS_KEY]
	local value = mod_settings and mod_settings[option_id]
	if value == nil then
		return default_value
	end
	return value
end

function AscendantTiersIsEarlyPortableCraneEnabled()
	-- Option temporarily disabled: keep prototype always enabled.
	return true
	-- return AscendantTiersGetSetting(EARLY_PORTABLE_CRANE_OPTION_ID, true)
end

local function remove_unlock_from_list(unlocked_list, id)
	if type(unlocked_list) ~= "table" then
		return false
	end

	local removed = false
	if unlocked_list[id] ~= nil then
		unlocked_list[id] = nil
		removed = true
	end

	for i = #unlocked_list, 1, -1 do
		if unlocked_list[i] == id then
			table.remove(unlocked_list, i)
			removed = true
		end
	end

	return removed
end

local function remove_early_portable_crane_unlock(faction)
	if not faction then
		return false
	end

	local removed = false
	removed = remove_unlock_from_list(faction.unlocked_items, EARLY_PORTABLE_CRANE_ID) or removed

	-- Defensive cleanup if any custom arrays were used by older versions/mods.
	if type(faction.extra_data) == "table" then
		removed = remove_unlock_from_list(faction.extra_data.unlocked_items, EARLY_PORTABLE_CRANE_ID) or removed
	end

	return removed
end

local function remove_early_portable_crane_components(faction)
	if not faction or type(faction.entities) ~= "table" then
		return 0
	end

	local removed_count = 0
	for _, entity in ipairs(faction.entities) do
		if entity and entity.exists and entity.FindComponent then
			for i = 1, 999 do
				local comp = entity:FindComponent(EARLY_PORTABLE_CRANE_ID, true, i)
				if not comp then
					break
				end
				if comp.exists then
					comp:Destroy()
					removed_count = removed_count + 1
				end
			end
		end
	end

	return removed_count
end

local function unlock_ascendant_content(faction)
	if not faction then
		return
	end

	if faction:IsUnlocked("t_assembly") and not faction:IsUnlocked("tech_ascendant_tiers_start") then
		faction:Unlock("tech_ascendant_tiers_start")
	end

	if faction:IsUnlocked("t_assembly")
		and AscendantTiersIsEarlyPortableCraneEnabled()
		and not faction:IsUnlocked(EARLY_PORTABLE_CRANE_ID)
	then
		faction:Unlock(EARLY_PORTABLE_CRANE_ID)
	end

	-- Option temporarily disabled.
	-- if not AscendantTiersIsEarlyPortableCraneEnabled() then
	-- 	remove_early_portable_crane_unlock(faction)
	-- 	remove_early_portable_crane_components(faction)
	-- end
end

function package:init()
end

function package:on_player_faction_spawn(faction, is_respawn, player_faction_num)
	unlock_ascendant_content(faction)
end

function MapMsg.OnTechResearch(faction, tech_id)
	if tech_id == "t_assembly" then
		unlock_ascendant_content(faction)
	end
end

function MapMsg.OnFactionRespawn(faction)
	unlock_ascendant_content(faction)
end
