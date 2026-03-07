if not GetOptionValue( "resynced", "custom_ui" ) then return end

-- "Unregister" unwanted UI
for _, v in pairs({
	"ResourceBar", -- Main/ui/ResourceBar.lua
	"SideBar", -- Main/ui/SideBar.lua
	-- "ShortcutBar", -- Main/ui/ShortcutBar.lua
	"ResyncedUI", -- Resynced/ui.lua
	}) do
	UI.Register( v, [[ <HorizontalList width=0 height=0 hidden=true /> ]], {}, true )
end

-- Rewrite Input Mapping for Custom UI usage ( Main/ui/ui.lua line 382 )
for _, v in pairs({
	{ id = "Build", action = "Released", ui = "BuildView", resynced = true },
	{ id = "Progress", action = "Released", ui = "ProgressView", resynced = true },
	{ id = "Codex", action = "Released", ui = "Codex", resynced = true },
	{ id = "Library", action = "Released", ui = "Library", resynced = true },
	{ id = "FactionView", action = "Released", ui = "Faction", resynced = true },
	{ id = "Tech", action = "Released", ui = "Tech", resynced = false },
	}) do
	Input.RemoveActionMapping( v.id )
	Input.RemoveActionBinding( v.id )
	Input.BindAction( v.id, v.action, function()
		if v.resynced then ResyncedOpenMainWindow( v.ui ) else OpenMainWindow( v.ui ) end
	end )
end

function UIMsg.OnSetup()
	UI.AddLayout( "CUIMinimap" )
	UI.AddLayout( "ResyncedResourceBar" )
	UI.AddLayout( "ResyncedActionBar" )
end

local ObjectFunction = { bt_menu = "InGameMenu", bt_speed_0 = "PauseGame" }
function TooltipsButtonHandler( objects )
	if ObjectFunction[ objects.id ] ~= nil then objects.tooltip = L( '<hl>%s</>\n<bl>[Shortcut :</> <Key action="%S" style="gl"/><bl>]</>', "synced.ui." .. objects.id, ObjectFunction[ objects.id ])
	else objects.tooltip = L( '<hl>%s</>', "synced.ui." .. objects.id ) end
end

function MakeNumString(num)
	if num <= 9999 then return tostring(num) end
	if num <= 99999 then return string.format("%d.%dK", (num // 1000), (num // 100) % 10) end
	if num <= 999999 then return string.format("%dK", (num // 1000)) end
	if num <= 9999999 then return string.format("%d.%02dM", (num // 1000000), (num // 10000) % 100) end
	if num <= 99999999 then return string.format("%d.%dM", (num // 1000000), (num // 100000) % 10) end
	if num <= 999999999 then return string.format("%dM", (num // 1000000)) end
	if num <= 9999999999 then return string.format("%d.%02dG", (num // 1000000000), (num // 10000000) % 100) end
	if num <= 99999999999 then return string.format("%d.%dG", (num // 1000000000), (num // 100000000) % 10) end
	if num <= 999999999999 then return string.format("%dG", (num // 1000000000)) end
	return string.format("%dG", (num // 1000000000))
end

function WidgetChildExist( object, id )
	for k, v in pairs( object.children ) do
		if v.id and v.id == id then return
			true
		end
	end
end