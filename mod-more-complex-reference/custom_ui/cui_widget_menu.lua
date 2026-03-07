if not GetOptionValue( "resynced", "custom_ui" ) then return end

local ResyncedTopBarMenu = {}
UI.Register( "ResyncedTopBarMenu", [[
	<Box bg=no_background padding=4 >
		<HorizontalList child_padding=4 dock=right >
			<Button width=32 height=32 icon=icon_pause id=bt_speed_0 />
			<Button width=32 height=32 icon=icon_play id=bt_speed_1 />
			<Button width=32 height=32 icon=icon_play_fast id=bt_speed_2 />
			<Button width=32 height=32 icon=icon_play_very_fast id=bt_speed_3 />
			<Image width=2 height=32 color=ui_dark/>
			<Button width=32 height=32 icon=icon_key id=bt_unlock />
			<Button width=32 height=32 icon=icon_scan id=bt_wave />
			<Image width=2 height=32 color=ui_dark/>
			<Button width=32 height=32 icon=icon_menu id=bt_menu />
		</HorizontalList>
	</Box>
]], ResyncedTopBarMenu )

local GameSpeed
function ResyncedTopBarMenu:construct()
	
	GameSpeed = Map.GetGameSpeed()
	
	-- All buttons functionnality
	self.bt_speed_0.on_click = function( button )
		GameSpeed = tonumber( string.sub( button.id, -1 ))
		Action.SendForLocalFaction( "ResyncedTopBarMenu", { action = "speed", speed = tonumber( string.sub( button.id, -1 )), isHost = Game.IsHostPlayer() })
	end
	self.bt_speed_1.on_click = self.bt_speed_0.on_click
	self.bt_speed_2.on_click = self.bt_speed_0.on_click
	self.bt_speed_3.on_click = self.bt_speed_0.on_click
	
	self.bt_unlock.on_click = function( button ) Action.SendForLocalFaction( "ResyncedTopBarMenu", { action = "unlock" }) end
	self.bt_wave.on_click = function( button ) Action.SendForLocalFaction( "ResyncedTopBarMenu", { action = "wave" }) end
	self.bt_menu.on_click = function( button ) OpenMainWindow( "InGameMenu" ) end
	
	-- Creating buttons tooltips with shortcut
	self:Refresh()
end

function ResyncedTopBarMenu:update()
	for _, v in pairs({ "bt_speed_0", "bt_speed_1", "bt_speed_2", "bt_speed_3" }) do
		self[ v ].active = tonumber( string.sub( v, -1 )) == Map.GetGameSpeed()
	end
end

function ResyncedTopBarMenu:Refresh()
	for _, v in pairs({ "bt_speed_0", "bt_speed_1", "bt_speed_2", "bt_speed_3", "bt_unlock", "bt_wave", "bt_menu" }) do TooltipsButtonHandler( self[ v ] ) end
end

function FactionAction.ResyncedTopBarMenu( faction, arg )
	if arg.action == "speed" then
		-- if GameSpeed == 0 and speed > GameSpeed then GameSpeed = speed end
		Map.SetGameSpeed( arg.speed )
	end
	
	if arg.action == "unlock" then
		for _, v in pairs( Map.GetFactions() ) do
			v:Unlock( "syncedt_discovery" )
			v:Unlock( "syncedt_init" )
			v:Unlock( "syncedt1" )
		end
	end
	
	if arg.action == "wave" then BugWaveStart( faction ) end
	
	-- if arg.action == "speed" then
		-- if ( not arg.isHost and GetOptionValue( "resynced", "game_speed" ) == 2 ) or arg.isHost then
			-- Map.SetGameSpeed( arg.speed )
		-- elseif not arg.isHost and GetOptionValue( "resynced", "game_speed" ) == 3 then
			-- Action.SendForLocalFaction( "SetOptionValue", { addon_id = "resynced", option_id = "vote_speed" .. arg.speed, value = true })
		-- end
	-- end
	-- if arg.action == "wave" then BugWaveStart( faction ) end
	-- if arg.action == "UnlockHackingPuzzle" then faction:Unlock( "synced_c_puzzle_hacker" ) end
	-- if arg.action == "unlock_debug" then faction:Unlock( "syncedt_discovery" ) end
	-- if arg.action == "unlock" then
		-- for _, v in pairs( Map.GetFactions() ) do
			-- v:Unlock( "syncedt_discovery" )
			-- v:Unlock( "syncedt_init" )
			-- v:Unlock( "syncedt1" )
		-- end
	-- end
	-- if arg.action == "default_bug_wave" then
		-- local default_bug_wave = { bug_wave = { difficulty = 1, last_tick_wave = Map.GetTick(), next_tick_wave = Map.GetTick(), initial_wave = true }}
		-- faction.extra_data.resynced = default_bug_wave
	-- end
end

-- PlayerAction:UnbindAll( "PauseGame" )
-- function PlayerAction.PauseGame( player_id, faction, arg )
	-- if not Game.IsHostPlayer( player_id ) then return end
	-- Map.SetGameSpeed( not arg.pause and GameSpeed or 0 )
-- end

function UIMsg.OnLanguageChanged()
	ResyncedTopBarMenu:Refresh()
end