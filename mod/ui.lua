local ASCENDANT_TIERS_TECH_ID<const> = "tech_ascendant_tiers_start"
local watcher_added = false

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

local PauseMenuWatcher = {}
UI.Register("AscendantTiersPauseMenuWatcher", "<Canvas/>", PauseMenuWatcher)

function PauseMenuWatcher:update()
	local menu = UI.FindWidget("InGameMenu")
	if menu then
		inject_pause_unlock_button(menu)
	end
end

function UIMsg.OnSetup()
	if watcher_added then
		return
	end
	watcher_added = true
	UI.AddLayout("AscendantTiersPauseMenuWatcher")
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
