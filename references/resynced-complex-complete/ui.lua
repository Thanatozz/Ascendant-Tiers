-- Custom styles and icons
data.styles.rc = { outline_size = 1, color = "#EBBE33" }
data.styles.td = { size = 10 }
data.styles.speed_vote = { color = "#5AD36E", icon_color = "#67F87F" }
data.colors.ui_green = "#67F87F"
data.brushes.icon_play_fast = "Resynced/textures/synced_fast.png"
data.brushes.icon_play_very_fast = "Resynced/textures/synced_very_fast.png"
data.brushes.icon_show = "Resynced/textures/show.png"
data.brushes.icon_hide = "Resynced/textures/hide.png"
data.brushes.icon_scan = "Main/skin/Icons/Special/Commands/Scan.png"
data.brushes.icon_minimize = "Resynced/textures/minimize.png"
data.brushes.icon_expand = "Resynced/textures/expand.png"
data.brushes.icon_arrow_right = "Resynced/textures/arrow_right.png"
data.brushes.icon_arrow_left = "Resynced/textures/arrow_left.png"
data.brushes.icon_pointer = "Resynced/textures/pointer.png"
data.brushes.no_background = "Resynced/textures/no_background.png"

-- Apply Resynced item / frame background
local OrgGetComponentRaceBG = GetComponentRaceBG
function GetComponentRaceBG( race )
	return race == "synced" and { "Resynced/textures/synced_bg.png", slice = 0.3 } or OrgGetComponentRaceBG( race )
end

-- In game UI
local ResyncedLayout = [[
	<VerticalList dock=bottom-right x=-65 y=-4 child_padding=4 >
		<Box padding=4 child_padding=4 blur=true id=tab_anger >
			<VerticalList>
				<HorizontalList>
					<Text id=tx_anger_bar text=synced.ui.threat_level margin_right=10 />
					<Text id=tx_anger_timer text=synced.ui.next_wave halign=right fill=true />
				</HorizontalList>
				<Progress id=pg_anger_bar height=12 progress=0.5 color=ui_light fill=true tooltip=synced.ui.pg_anger_bar.tooltip />
			</VerticalList>
		</Box>
		<Box padding=4 blur=true id=tab_speed >
			<HorizontalList child_padding=4 >
				<Button width=32 height=32 icon=icon_play on_click={on_click_event} tooltip=synced.ui.bt_speed_1 id=bt_speed_1 speed=1 />
				<Button width=32 height=32 icon=icon_play_fast on_click={on_click_event} tooltip=synced.ui.bt_speed_2 id=bt_speed_2 speed=2 />
				<Button width=32 height=32 icon=icon_play_very_fast on_click={on_click_event} tooltip=synced.ui.bt_speed_3 id=bt_speed_3 speed=3 />
				<Button width=32 height=32 icon=icon_key on_click={on_click_event} id=bt_unlock tooltip=synced.ui.bt_unlock />
				<Button width=32 height=32 icon=icon_scan on_click={on_click_event} id=bt_wave tooltip=synced.ui.bt_wave />
			</HorizontalList>
		</Box>
	</VerticalList>
]]

local ResyncedUI = {}
UI.Register( "ResyncedUI", ResyncedLayout, ResyncedUI )

function ResyncedUI:construct()
	
	-- Hide disabled / unwanted widget
	self.tab_anger.hidden = not GetOptionValue( "bug_wave", "allow_wave" ) or not GetOptionValue( "bug_wave" )
	self.bt_wave.hidden = not GetOptionValue( "bug_wave" )
	self.tab_speed.hidden = ( not Game.IsHostPlayer() and GetOptionValue( "resynced", "game_speed" ) == 1 )
	self.hidden = ( self.tab_anger.hidden and self.tab_speed.hidden )
	
	local faction = Game.GetLocalPlayerFaction()
	
	-- Add faction bug_wave stats for save started without resynced
	if faction.extra_data.resynced == nil then
		Action.SendForLocalFaction( "SyncedAction", { action = "default_bug_wave" })
	end
	
	-- Unlock resynced tech for save started without resynced
	if faction:GetItemAmount( "alien_artifact" ) > 0 then
		Action.SendForLocalFaction( "SyncedAction", { action = "unlock_debug" })
	end
	
	-- Unlock the puzzle solver for save started without resynced
	if not Game.GetLocalPlayerFaction():IsUnlocked( "synced_c_puzzle_hacker" ) and GetOptionValue( "resynced", "puzzle_hacker" ) then
		Action.SendForLocalFaction( "SyncedAction", { action = "UnlockHackingPuzzle" })
	end
	
	for _, v in pairs({ "bt_speed_1", "bt_speed_2", "bt_speed_3", "bt_unlock", "bt_wave" }) do self[ v ].tooltip = L( '<hl>%s</>', "synced.ui." .. self[ v ].id ) end
end

function ResyncedUI:update()
	self.bt_speed_1.active = ( Map.GetGameSpeed() == self.bt_speed_1.speed )
	self.bt_speed_2.active = ( Map.GetGameSpeed() == self.bt_speed_2.speed )
	self.bt_speed_3.active = ( Map.GetGameSpeed() == self.bt_speed_3.speed )
	
	local faction = Game.GetLocalPlayerFaction()
	
	if GetOptionValue( "bug_wave" ) and GetOptionValue( "bug_wave", "allow_wave" ) then
		
		local faction_anger = GetAngerLevelFrom( faction )
		local bug_wave_event = faction.extra_data.resynced.bug_wave
		local ticks = Map.GetTick()
		local anger_rate = (( ticks - bug_wave_event.last_tick_wave ) * 100 / ( bug_wave_event.next_tick_wave - bug_wave_event.last_tick_wave )) / 100
		
		if anger_rate >= 0.75 then self.pg_anger_bar.color = data.colors.red
		elseif anger_rate >= 0.5 then self.pg_anger_bar.color = data.colors.yellow
		elseif anger_rate >= 0.25 then self.pg_anger_bar.color = data.colors.green
		else self.pg_anger_bar.color = data.colors.ui_light end
		
		self.pg_anger_bar.progress = anger_rate
		self.tx_anger_bar.text = L( 'synced.ui.lvl', faction_anger )
		
		local tick_left = (( bug_wave_event.next_tick_wave - Map.GetTick() ) / 5 )
		local timer_sec = L( 'synced.ui.timer_sec', math.ceil( tick_left ))
		local timer_min = L( 'synced.ui.timer_min', math.ceil( tick_left / 60 ))
		self.tx_anger_timer.text = ( tick_left < 60 ) and timer_sec or timer_min
		
		if ticks >= bug_wave_event.next_tick_wave then
			Action.SendForLocalFaction( "SyncedAction", { action = "wave" })
		end
		
		if IsFirstOnlinePlayerFaction() then
			Action.SendForLocalFaction( "SyncedBugWave" )
		end
	end
end

function ResyncedUI:on_click_event( button )
	if button.id == "bt_unlock" then Action.SendForLocalFaction( "SyncedAction", { action = "unlock" }) end
	if button.id == "bt_wave" then Action.SendForLocalFaction( "SyncedAction", { action = "wave" }) end
	if string.find( button.id, "speed" ) then Action.SendForLocalFaction( "SyncedAction", { action = "speed", speed = button.speed, isHost = Game.IsHostPlayer() }) end
end

function FactionAction.SyncedAction( faction, arg )
	if arg.action == "speed" then
		if ( not arg.isHost and GetOptionValue( "resynced", "game_speed" ) == 2 ) or arg.isHost then
			Map.SetGameSpeed( arg.speed )
		elseif not arg.isHost and GetOptionValue( "resynced", "game_speed" ) == 3 then
			Action.SendForLocalFaction( "SetOptionValue", { addon_id = "resynced", option_id = "vote_speed" .. arg.speed, value = true })
		end
	end
	if arg.action == "wave" then BugWaveStart( faction ) end
	if arg.action == "UnlockHackingPuzzle" then faction:Unlock( "synced_c_puzzle_hacker" ) end
	if arg.action == "unlock_debug" then faction:Unlock( "syncedt_discovery" ) end
	if arg.action == "unlock" then
		for _, v in pairs( Map.GetFactions() ) do
			v:Unlock( "syncedt_discovery" )
			v:Unlock( "syncedt_init" )
			v:Unlock( "syncedt1" )
			v:Unlock( "alien_artifact" ) -- temporary
		end
	end
	if arg.action == "default_bug_wave" then
		local default_bug_wave = { bug_wave = { difficulty = 1, last_tick_wave = Map.GetTick(), next_tick_wave = Map.GetTick(), initial_wave = true }}
		faction.extra_data.resynced = default_bug_wave
	end
end

function UIMsg.OnSetup()
	UI.AddLayout( "ResyncedUI" )
end

-- Options UI
local ResyncedSettings_Layout<const> = [[
	<VerticalList orientation=vertical child_padding=8 fill=true >
		<ResyncedTitleBox text_title=synced.option.title iconv=icon_small_durability />
		<HorizontalList>
			<Button fill=true height=32 on_click={resynced_click} id=apply text=synced.ui.apply tooltip=synced.ui.applyt />
			<Button width=32 height=32 on_click={resynced_click} id=infos icon=icon_question tooltip=synced.ui.helpt margin_left=4 />
			<Button width=32 height=32 on_click={resynced_click} id=unhide icon=icon_show tooltip=synced.ui.show_tooltip margin_left=4 />
		</HorizontalList>
		<Box padding=4 blur=true >
			<ScrollList id=list_modules max_height=300 />
		</Box>
		<Box padding=4 blur=true >
			<ScrollList id=list_settings child_padding=4 height=0 />
		</Box>
	</VerticalList>
]]

local ResyncedSettings_Options = {}
UI.Register( "ResyncedSettings", ResyncedSettings_Layout, ResyncedSettings_Options )

function ResyncedSettings_Options:construct()
	-- self.header.text = L( 'synced.option.title', Game.GetModPackage( "Resynced/Main" ).mod_version_name )
	
	for k, v in pairs( ResyncedAddonOrder ) do
		local widget = self.list_modules:Add([[
				<Box padding=4 bg=popup_additional_bg fill=true margin_bottom=2 >
					<HorizontalList>
						<Text valign=center text={op_name} fill=true />
						<Button width=120 height=32 text=synced.ui.setting_button modules={op_param} margin_right=4 />
						<Button width=32 height=32 icon=icon_hide />
					</HorizontalList>
				</Box>
			]], {
			tooltip = ResyncedAddons[ v ].tooltip,
			op_name = ResyncedAddons[ v ].name,
			op_param = ResyncedAddons[ v ].id,
			hidden = GetOptionValue( ResyncedAddons[ v ].id, "hidden" )
		})
		
		local setting_bt = widget.children[ 1 ].children[ 2 ]
		setting_bt.on_click = function( button ) self:build_settings( ResyncedAddons[ button.modules ] ) end
		
		local showhide_bt = widget.children[ 1 ].children[ 3 ]
		showhide_bt.on_click = function( button )
			widget.hidden = not GetOptionValue( setting_bt.modules, "hidden" )
			button.icon = widget.hidden and "icon_show" or "icon_hide"
			Game.OfflinePause( false )
			Action.SendForLocalFaction( "SetOptionValue", { addon_id = ResyncedAddons[ v ].id, option_id = "hidden", value = widget.hidden })
			self:RefreshUI()
		end
		showhide_bt.icon = GetOptionValue( setting_bt.modules, "hidden" ) and "icon_show" or "icon_hide"
	end
	self:show_info()
	self:RefreshUI()
end

function ResyncedSettings_Options:build_settings( list )
	self.list_settings:Clear()
	self.list_settings:Add([[
		<HorizontalList padding=4 >
			<Text valign=center text={op_name} />
		</HorizontalList>
	]], { op_name = L( 'synced.ui.module_title', list.name )})
	
	-- self.list_settings:Add([[
		-- <ResyncedTitleBox text_title={op_name} iconv=icon_small_durability />
	-- ]], { op_name = L( 'synced.ui.module_title', list.name )})
	
	for k, v in ipairs( list.options ) do
		if v.type == "button" then
			local widget = self.list_settings:Add([[
					<HorizontalList padding=4 >
						<Button height=32 text={op_text} fill=true />
					</HorizontalList>
				]], {
				
				tooltip = L( 'synced.ui.buttont', v.tooltip, tostring( v.value )),
				op_text = v.text,
			})
			local button = widget.children[ 1 ]
			button.active = GetOptionValue( list.id, v.id )
			button.on_click = function( button )
				button.active = not button.active
				Game.OfflinePause( false )
				Action.SendForLocalFaction( "SetOptionValue", { addon_id = list.id, option_id = v.id, value = button.active })
			end
				
		elseif v.type == "slider" then
			local widget = self.list_settings:Add([[
					<HorizontalList padding=4 >
						<Text valign=center width=200 size=12 />
						<Button icon=icon_minus height=24 valign=center margin_right=2 />
						<Slider height=32 step=1 on_change={on_update} fill=true />
						<Button icon=icon_add height=24 valign=center margin_left=2 />
						
					</HorizontalList>
				]], {
				tooltip = L( 'synced.ui.slidert', v.tooltip, tostring( v.value ), tostring( v.min ), tostring( v.max ))
			})
			
			local slider = widget.children[ 3 ]
			slider.min = v.min
			slider.max = v.max
			slider.step = v.step
			slider.value = GetOptionValue( list.id, v.id )
			widget.children[ 1 ].text = L( '<td>%s ( %s )</>', v.text, slider.value + 0.0 )
			slider.on_change = function( slider )
				widget.children[ 1 ].text = L( '<td>%s ( %s )</>', v.text, slider.value + 0.0 )
				Game.OfflinePause( false )
				Action.SendForLocalFaction( "SetOptionValue", { addon_id = list.id, option_id = v.id, value = slider.value })
			end
			
			widget.children[ 2 ].on_click = function( button )
				slider.value = slider.value > slider.min and slider.value - 1 or slider.value
				widget.children[ 1 ].text = L( '<td>%s ( %s )</>', v.text, slider.value + 0.0 )
				Game.OfflinePause( false )
				Action.SendForLocalFaction( "SetOptionValue", { addon_id = list.id, option_id = v.id, value = slider.value })
			end
			widget.children[ 4 ].on_click = function( button )
				slider.value = slider.value < slider.max and slider.value + 1 or slider.value
				widget.children[ 1 ].text = L( '<td>%s ( %s )</>', v.text, slider.value + 0.0 )
				Game.OfflinePause( false )
				Action.SendForLocalFaction( "SetOptionValue", { addon_id = list.id, option_id = v.id, value = slider.value })
			end
			
		elseif v.type == "combo" then
			local widget = self.list_settings:Add([[
					<HorizontalList padding=4 >
						<Text valign=center width=200 />
						<Combo height=32 step=1 on_change={on_update} fill=true />
					</HorizontalList>
				]], {
				tooltip = L( 'synced.ui.combot', v.tooltip, v.texts[ v.value ])
			})
			local combo = widget.children[ 2 ]
			combo.texts = v.texts
			combo.value = GetOptionValue( list.id, v.id ) -- - 1 As combo value start to 1 not 0
			widget.children[ 1 ].text = L( '<td>%s</>', v.text )
			combo.on_change = function( combo )
				Game.OfflinePause( false )
				Action.SendForLocalFaction( "SetOptionValue", { addon_id = list.id, option_id = v.id, value = combo.value })
			end
		elseif v.type == "separator" then
			self.list_settings:Add([[
				<Image height=2 color=ui_dark />
			]])
		end
	end
end

function ResyncedSettings_Options:resynced_click( button )
	if button.id == "apply" then -- Apply button
		Game.SaveGame( "Resynced_TEMP", "Resynced_TEMP" )
		Game.LoadGame( "Resynced_TEMP" )
	end
	
	if button.id == "infos" then -- Question mark button
		self:show_info()
	end
	
	if button.id == "unhide" then -- Show all modules ( eye ) button
		for k, v in pairs( self.list_modules.children ) do
			if button.icon == "icon_show" then
				v.hidden = false
			elseif button.icon == "icon_hide" then
				if self.list_modules.children[ k ].children[ 1 ].children[ 3 ].icon == "icon_show" then
					v.hidden = true
				end
			end
		end
		if button.icon == "icon_show" then
			button.icon = "icon_hide"
			button.tooltip = "synced.ui.hide_tooltip"
		elseif button.icon == "icon_hide" then
			button.icon = "icon_show"
			button.tooltip = "synced.ui.show_tooltip"
		end
		self:RefreshUI()
	end
end

function ResyncedSettings_Options:show_info()
	self.list_settings:Clear()
	self.list_settings:Add([[
		<Text text=synced.ui.help wrap=true />
	]])
end

function ResyncedSettings_Options:RefreshUI()
	local width, height = self.list_modules:GetDesiredSize()
	self.list_settings.height = 654 - height
end