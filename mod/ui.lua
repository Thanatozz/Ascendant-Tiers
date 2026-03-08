local ASCENDANT_TIERS_TECH_ID<const> = "tech_ascendant_tiers_start"
local watcher_added = false
local menu_retry_hooked = setmetatable({}, { __mode = "k" })

local function get_local_faction()
	if not Game.GetLocalPlayerFaction then
		return nil
	end
	return Game.GetLocalPlayerFaction()
end

local function refresh_pause_unlock_state(menu)
	if not menu or not menu.at_unlock_btn or not menu.at_unlock_hint then
		return
	end

	local faction = get_local_faction()
	local unlocked = faction and faction:IsUnlocked(ASCENDANT_TIERS_TECH_ID)

	menu.at_unlock_btn.disabled = unlocked
	menu.at_unlock_btn.text = unlocked
		and "Ascendant Tiers already unlocked"
		or "Unlock Ascendant Tiers tech"
	menu.at_unlock_hint.text = unlocked
		and "This faction already has Ascendant Tiers unlocked."
		or "Use once for advanced saves created before installing this mod."
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

	-- Retry on menu UI updates so we don't depend on simulation ticks when game is paused.
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

	-- In case setup happens with menu already open.
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

		local options = UI.FindWidget("AscendantTiersOptions")
		if options and options.refresh_state then
			options:refresh_state()
		end

		Notification.Info("Ascendant Tiers tech unlocked for this faction.")
	end)
end
