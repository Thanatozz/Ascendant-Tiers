local ASCENDANT_TIERS_TECH_ID<const> = "tech_ascendant_tiers_start"
local ASCENDANT_TIERS_SETTINGS_KEY<const> = "ascendant_tiers"
local EARLY_PORTABLE_CRANE_OPTION_ID<const> = "enable_early_portable_crane"
local ASCENDANT_TIERS_OPTION_DEFS<const> = {
	enable_early_portable_crane = { kind = "boolean", default = true },
	t2_tech_cost_pct = { kind = "percent", min = 10, max = 1000, default = 100 },
	t2_building_recipe_cost_pct = { kind = "percent", min = 10, max = 1000, default = 100 },
	t2_component_recipe_pct = { kind = "percent", min = 10, max = 1000, default = 200 },
	t2_component_stats_pct = { kind = "percent", min = 10, max = 1000, default = 200 },
	t2_mining_speed_pct = { kind = "percent", min = 10, max = 1000, default = 200 },
	t2_building_health_pct = { kind = "percent", min = 10, max = 1000, default = 135 },
	t2_building_storage_pct = { kind = "percent", min = 10, max = 1000, default = 200 },
	t2_building_slots_pct = { kind = "percent", min = 10, max = 1000, default = 100 },
	t2_unit_recipe_cost_pct = { kind = "percent", min = 10, max = 1000, default = 100 },
	t2_unit_health_pct = { kind = "percent", min = 10, max = 1000, default = 125 },
	t2_unit_inventory_pct = { kind = "percent", min = 10, max = 1000, default = 200 },
	t2_unit_slots_pct = { kind = "percent", min = 10, max = 1000, default = 100 },
	t2_unit_speed_pct = { kind = "percent", min = 10, max = 1000, default = 150 },
	t2_material_recipe_cost_pct = { kind = "percent", min = 10, max = 1000, default = 100 },
	t2_material_craft_time_pct = { kind = "percent", min = 10, max = 1000, default = 100 },
	t2_material_craft_speed_pct = { kind = "percent", min = 10, max = 1000, default = 100 },
}
local watcher_added = false
local menu_retry_hooked = setmetatable({}, { __mode = "k" })

local function get_local_faction()
	if not Game.GetLocalPlayerFaction then
		return nil
	end
	return Game.GetLocalPlayerFaction()
end

local function get_ascendant_settings()
	if not Map or type(Map.GetSettings) ~= "function" then
		return {}
	end
	local settings = Map.GetSettings()
	return (settings and settings[ASCENDANT_TIERS_SETTINGS_KEY]) or {}
end

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

local function clamp_number(value, min_value, max_value)
	if value < min_value then
		return min_value
	end
	if value > max_value then
		return max_value
	end
	return value
end

local function normalize_option_value(option_def, raw_value)
	if type(option_def) ~= "table" then
		return raw_value
	end

	if option_def.kind == "boolean" then
		if raw_value == nil then
			return option_def.default and true or false
		end
		if type(raw_value) == "boolean" then
			return raw_value
		end
		if type(raw_value) == "number" then
			return raw_value ~= 0
		end
		if type(raw_value) == "string" then
			local lowered = string.lower(raw_value)
			return lowered == "true" or lowered == "1" or lowered == "yes" or lowered == "on"
		end
		return raw_value and true or false
	end

	if option_def.kind == "percent" then
		local numeric_value = tonumber(raw_value)
		if not numeric_value then
			numeric_value = option_def.default or 100
		end
		local rounded_value = math.floor(numeric_value + 0.5)
		return clamp_number(rounded_value, option_def.min, option_def.max)
	end

	return raw_value
end

local function refresh_options_widget()
	local options = UI.FindWidget("AscendantTiersOptions")
	if options and options.refresh_state then
		options:refresh_state()
	end
end

local function refresh_pause_unlock_state(menu)
	if not menu or not menu.at_unlock_btn or not menu.at_unlock_hint then
		return
	end

	local faction = get_local_faction()
	local unlocked = faction and faction:IsUnlocked(ASCENDANT_TIERS_TECH_ID)

	menu.at_unlock_btn.disabled = unlocked
	menu.at_unlock_btn.text = unlocked
		and "ascendant.option.unlock.already"
		or "ascendant.option.unlock.action"
	menu.at_unlock_hint.text = unlocked
		and "ascendant.option.pause_hint.already_unlocked"
		or "ascendant.option.pause_hint.legacy_unlock"
end

local function inject_pause_unlock_button(menu)
	if not menu or menu.at_unlock_injected or not menu.list then
		return
	end

	menu.at_unlock_injected = true
	menu.list:Add("<Image height=2 color=ui_dark margin_top=6 margin_bottom=6/>")
	menu.at_unlock_hint = menu.list:Add("<Text wrap=true textalign=center size=10/>")
	menu.at_unlock_btn = menu.list:Add("<Button id=at_unlock_btn/>")

	menu.at_unlock_btn.on_click = function()
		Action.SendForLocalFaction("UnlockAscendantTiersTech")
		local current_menu = UI.FindWidget("InGameMenu")
		if current_menu then
			refresh_pause_unlock_state(current_menu)
		end
	end

	refresh_pause_unlock_state(menu)
end

local function ensure_pause_menu_hook(menu)
	if not menu or menu_retry_hooked[menu] then
		return
	end
	menu_retry_hooked[menu] = true

	local previous_update = menu.update
	menu.update = function(self, ...)
		if previous_update then
			previous_update(self, ...)
		end

		if not self.at_unlock_injected then
			inject_pause_unlock_button(self)
		end
	end
end

local PauseMenuWatcher = {}
UI.Register("AscendantTiersPauseMenuWatcher", "<Canvas/>", PauseMenuWatcher)

function PauseMenuWatcher:update()
	local menu = UI.FindWidget("InGameMenu")
	if menu then
		ensure_pause_menu_hook(menu)
		inject_pause_unlock_button(menu)
	end
end

function UIMsg.OnSetup()
	if watcher_added then
		return
	end
	watcher_added = true
	UI.AddLayout("AscendantTiersPauseMenuWatcher")

	local menu = UI.FindWidget("InGameMenu")
	if menu then
		ensure_pause_menu_hook(menu)
		inject_pause_unlock_button(menu)
	end
end

function FactionAction.UnlockAscendantTiersTech(faction)
	if faction:IsUnlocked(ASCENDANT_TIERS_TECH_ID) then
		return
	end

	faction:Unlock(ASCENDANT_TIERS_TECH_ID)
	faction:RunUI(function()
		local menu = UI.FindWidget("InGameMenu")
		if menu then
			refresh_pause_unlock_state(menu)
		end

		refresh_options_widget()

		Notification.Info("ascendant.notify.tech_unlocked")
	end)
end

function FactionAction.SetAscendantTiersOption(faction, arg)
	if type(arg) ~= "table" then
		return
	end

	local option_id = arg.option_id
	local option_def = option_id and ASCENDANT_TIERS_OPTION_DEFS[option_id]
	if not option_def then
		return
	end

	local stored_value = normalize_option_value(option_def, arg.value)

	if not Map or type(Map.ModifySettings) ~= "function" then
		return
	end

	local settings = clone_shallow_table(get_ascendant_settings())
	settings[option_id] = stored_value
	Map.ModifySettings(ASCENDANT_TIERS_SETTINGS_KEY, settings)

	if option_id == EARLY_PORTABLE_CRANE_OPTION_ID and type(AscendantTiersApplyPortableCraneSetting) == "function" then
		AscendantTiersApplyPortableCraneSetting(faction)
	end

	faction:RunUI(function()
		refresh_options_widget()
		if option_id == EARLY_PORTABLE_CRANE_OPTION_ID then
			Notification.Info(stored_value and "ascendant.notify.prototype_enabled" or "ascendant.notify.prototype_disabled")
		end
	end)
end

function FactionAction.ResetAscendantTiersSettings(faction)
	if not Map or type(Map.ModifySettings) ~= "function" then
		return
	end

	-- Clear all saved map-side values for this mod so defaults are used again.
	Map.ModifySettings(ASCENDANT_TIERS_SETTINGS_KEY, {})

	if type(AscendantTiersApplyPortableCraneSetting) == "function" then
		AscendantTiersApplyPortableCraneSetting(faction)
	end

	faction:RunUI(function()
		refresh_options_widget()
		Notification.Info("ascendant.notify.settings_reset")
	end)
end

