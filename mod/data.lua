local package = ...
local ASCENDANT_TIERS_SETTINGS_KEY<const> = "ascendant_tiers"
local EARLY_PORTABLE_CRANE_OPTION_ID<const> = "enable_early_portable_crane"
local EARLY_PORTABLE_CRANE_ID<const> = "c_portablecrane_early"
local ASCENDANT_TIERS_SYNCABLE_OPTIONS<const> = {
	EARLY_PORTABLE_CRANE_OPTION_ID,
	"t2_tech_cost_pct",
	"t2_building_recipe_cost_pct",
	"t2_building_health_pct",
	"t2_building_storage_pct",
	"t2_building_slots_pct",
	"t2_unit_recipe_cost_pct",
	"t2_unit_health_pct",
	"t2_unit_inventory_pct",
	"t2_unit_slots_pct",
	"t2_unit_speed_pct",
	"t2_component_recipe_pct",
	"t2_component_stats_pct",
	"t2_component_stat_mode",
	"t2_component_stat_repair_pct",
	"t2_component_stat_trigger_radius_pct",
	"t2_component_stat_shield_max_pct",
	"t2_component_stat_shield_charge_pct",
	"t2_component_stat_damage_pct",
	"t2_component_stat_dotdps_pct",
	"t2_component_stat_storage_slots_pct",
	"t2_component_stat_power_pct",
	"t2_component_stat_max_power_pct",
	"t2_component_stat_solar_power_generated_pct",
	"t2_component_stat_solar_power_summer_pct",
	"t2_component_stat_speed_pct",
	"t2_component_stat_power_storage_pct",
	"t2_component_stat_power_capacity_pct",
	"t2_component_stat_charge_rate_pct",
	"t2_component_stat_drain_rate_pct",
	"t2_component_stat_transfer_radius_pct",
	"t2_component_stat_range_pct",
	"t2_component_stat_power_range_pct",
	"t2_component_stat_relay_range_pct",
	"t2_component_stat_field_radius_pct",
	"t2_component_stat_radius_pct",
	"t2_component_stat_bandwidth_pct",
	"t2_component_stat_attack_radius_pct",
	"t2_component_stat_duration_pct",
	"t2_component_stat_shoot_speed_pct",
	"t2_component_stat_beam_range_pct",
	"t2_component_stat_blast_pct",
	"t2_component_stat_damage_air_bonus_pct",
	"t2_component_stat_dothits_pct",
	"t2_component_stat_pulse_pct",
	"t2_component_stat_disruptor_pct",
	"t2_component_stat_minimum_range_pct",
	"t2_component_stat_miner_range_pct",
	"t2_component_stat_mining_speed_pct",
	"t2_component_stat_mining_efficiency_pct",
	"t2_mining_speed_pct",
	"t2_material_recipe_cost_pct",
	"t2_material_craft_time_pct",
	"t2_material_craft_speed_pct",
}
local ascendant_settings_synced = false

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

local function clone_shallow_table(source)
	if type(source) ~= "table" then
		return {}
	end

	local copy = {}
	for key, value in pairs(source) do
		copy[key] = value
	end
	return copy
end

local function sync_map_settings_from_profile_once()
	if ascendant_settings_synced then
		return
	end

	if not Map or type(Map.GetSettings) ~= "function" or type(Map.ModifySettings) ~= "function" then
		return
	end
	if not Game or type(Game.GetProfile) ~= "function" then
		return
	end

	local profile = Game.GetProfile(nil)
	local options = profile and profile.options
	local profile_mod_settings = options and options[ASCENDANT_TIERS_SETTINGS_KEY]
	if type(profile_mod_settings) ~= "table" then
		ascendant_settings_synced = true
		return
	end

	local settings = Map.GetSettings()
	local map_mod_settings = clone_shallow_table(settings and settings[ASCENDANT_TIERS_SETTINGS_KEY])
	local changed = false

	for _, option_id in ipairs(ASCENDANT_TIERS_SYNCABLE_OPTIONS) do
		local profile_value = profile_mod_settings[option_id]
		if profile_value == nil then
			if map_mod_settings[option_id] ~= nil then
				map_mod_settings[option_id] = nil
				changed = true
			end
		elseif map_mod_settings[option_id] ~= profile_value then
			map_mod_settings[option_id] = profile_value
			changed = true
		end
	end

	if changed then
		Map.ModifySettings(ASCENDANT_TIERS_SETTINGS_KEY, map_mod_settings)
	end

	ascendant_settings_synced = true
end

function AscendantTiersGetSetting(option_id, default_value)
	sync_map_settings_from_profile_once()

	if Map and type(Map.GetSettings) == "function" then
		local settings = Map.GetSettings()
		local mod_settings = settings and settings[ASCENDANT_TIERS_SETTINGS_KEY]
		local value = mod_settings and mod_settings[option_id]
		if value ~= nil then
			return value
		end
	end

	if Game and type(Game.GetProfile) == "function" then
		local profile = Game.GetProfile(nil)
		local options = profile and profile.options
		local profile_mod_settings = options and options[ASCENDANT_TIERS_SETTINGS_KEY]
		local profile_value = profile_mod_settings and profile_mod_settings[option_id]
		if profile_value ~= nil then
			return profile_value
		end
	end

	return default_value
end

function AscendantTiersIsEarlyPortableCraneEnabled()
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

	local crane_enabled = AscendantTiersIsEarlyPortableCraneEnabled()
	if type(AscendantTiersSetEarlyPortableCraneDefinitionEnabled) == "function" then
		AscendantTiersSetEarlyPortableCraneDefinitionEnabled(crane_enabled)
	end

	if faction:IsUnlocked("t_assembly") and not faction:IsUnlocked("tech_ascendant_tiers_start") then
		faction:Unlock("tech_ascendant_tiers_start")
	end

	if faction:IsUnlocked("t_assembly")
		and crane_enabled
		and not faction:IsUnlocked(EARLY_PORTABLE_CRANE_ID)
	then
		faction:Unlock(EARLY_PORTABLE_CRANE_ID)
	end

	if not crane_enabled then
		remove_early_portable_crane_unlock(faction)
		remove_early_portable_crane_components(faction)
	end
end

function AscendantTiersApplyPortableCraneSetting(faction)
	if not faction then
		return
	end

	local crane_enabled = AscendantTiersIsEarlyPortableCraneEnabled()
	if type(AscendantTiersSetEarlyPortableCraneDefinitionEnabled) == "function" then
		AscendantTiersSetEarlyPortableCraneDefinitionEnabled(crane_enabled)
	end

	if crane_enabled then
		if faction:IsUnlocked("t_assembly") and not faction:IsUnlocked(EARLY_PORTABLE_CRANE_ID) then
			faction:Unlock(EARLY_PORTABLE_CRANE_ID)
		end
	else
		remove_early_portable_crane_unlock(faction)
		remove_early_portable_crane_components(faction)
	end
end

function package:init()
	sync_map_settings_from_profile_once()
end

function package:on_player_faction_spawn(faction, is_respawn, player_faction_num)
	sync_map_settings_from_profile_once()
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
