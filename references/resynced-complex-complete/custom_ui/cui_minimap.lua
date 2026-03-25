if not GetOptionValue( "resynced", "custom_ui" ) then return end
-- <Button width=32 height=32 icon=icon_expand id=enlarge_map />
local CUIMinimapLayout = [[
	<HorizontalList dock=bottom-right >
		<VerticalList dock=bottom >
			<Box bg=popup_additional_bg padding=4 id=tab_anger width=252 margin_right=2 margin_bottom=2 tooltip=synced.ui.pg_anger_bar.tooltip >
				<HorizontalList>
					<Canvas>
						<Image image=item_default width=32 height=32 />
						<Image image="Main/textures/icons/bugs/gigakaiju.png" width=30 height=30 margin=1 />
					</Canvas>
					<VerticalList margin_left=4 >
						<HorizontalList width=211 >
							<Text id=tx_anger_bar text=synced.ui.threat_level size=10 />
							<Spacer fill=true />
							<Text id=tx_anger_timer text=synced.ui.next_wave size=10 />
						</HorizontalList>
						<Progress id=pg_anger_bar height=12 progress=0.5 color=ui_light fill=true />
					</VerticalList>
				</HorizontalList>
			</Box>
			<ResyncedTechNotify />
			<ResyncedProgressNotifications child_padding=0 />
			<Box dock=bottom-right bg=popup_additional_bg padding=4 id=minimapbar valign=bottom >
				<HorizontalList child_padding=4 >
					<VerticalList child_padding=4 >
						<Button width=32 height=32 icon=icon_small_zoom_in id=zoom_in />
						<Button width=32 height=32 icon=icon_small_zoom_out id=zoom_out />
						<Button width=32 height=32 icon=icon_small_object id=mapbtnunits />
						<Button width=32 height=32 icon=icon_small_energy id=mapbtnpower />
						<Button width=32 height=32 icon=icon_small_stick_to id=mapbtnfocuscamera />
						<Button id=bigmapbtn width=32 height=32 icon=icon_remote on_click={on_map_fullscreen}/>
					</VerticalList>
					<Canvas>
						<Minimap width=212 height=212 id=minimap on_follow_camera_changed={on_follow_camera_changed} />
						<Text id=mapcoords text="0,0" />
					</Canvas>
				</HorizontalList>
			</Box>
		</VerticalList>
		<Box dock=bottom-right bg=popup_additional_bg padding=4 >
			<VerticalList child_padding=4 >
				<Button width=32 height=32 icon=icon50_Tech id=btn_tech on_click={on_open_window} window=Tech />
				<Button width=32 height=32 icon=icon50_Build id=btn_build on_click={on_open_window} window=BuildView />
				<Button width=32 height=32 icon=icon50_Progress id=btn_progress on_click={on_open_window} window=ResyncedProgressView />
				<Button width=32 height=32 icon=icon50_Codex id=btn_codex on_click={on_open_window} window=Codex />
				<Button width=32 height=32 icon=icon50_Library id=btn_library on_click={on_open_window} window=Library />
				<Button width=32 height=32 icon=icon50_Faction id=btn_faction on_click={on_open_window} window=Faction />
				<Button width=32 height=32 icon=icon_small_navigation id=reset_camera />
				<Button width=32 height=32 icon=icon_arrow_right id=map_collapse />
				<Button width=32 height=32 icon=icon_small_energy id=toggle_power />
				<Button width=32 height=32 icon=icon_small_cursor_area id=toggle_grid />
				<Button width=32 height=32 icon=icon_small_camera id=toggle_follow />
				<Button width=32 height=32 icon=icon_small_visual id=toggle_mapoverlay />
				
				<Button id=overlaybtn width=32 height=32 icon=icon_small_visual on_click={on_open_overlay_options}/>
				<Button id=editpinbtn width=32 height=32 icon=icon_small_edit tooltip="Edit Pins" on_click={on_map_pin}/>
				
				<Button width=32 height=32 icon=icon_small_arrow id=toggle_movepath />
			</VerticalList>
		</Box>
	</HorizontalList>
]]

local CUIMinimap = {}
local CoordText, MinimapUI
UI.Register( "CUIMinimap", CUIMinimapLayout, CUIMinimap )

function CUIMinimap:construct()
	MinimapUI = self
	CoordText = self.mapcoords
	
	self.tab_anger.hidden = not GetOptionValue( "bug_wave", "allow_wave" ) or not GetOptionValue( "bug_wave" )
	-- self.bt_wave.hidden = not GetOptionValue( "bug_wave" )
	-- self.tab_speed.hidden = ( not Game.IsHostPlayer() and GetOptionValue( "resynced", "game_speed" ) == 1 )
	
	-- local bt_tootlips = { "btn_tech", "btn_build", "btn_progress", "btn_codex", "btn_library", "btn_faction", "zoom_in", "zoom_out", "mapbtnunits", "mapbtnpower", "mapbtnfocuscamera", "enlarge_map", "reset_camera", "map_collapse", "toggle_power", "toggle_grid", "toggle_follow", "toggle_mapoverlay", "toggle_movepath", "overlaybtn", "editpinbtn" }
	local bt_tootlips = { "btn_tech", "btn_build", "btn_progress", "btn_codex", "btn_library", "btn_faction", "zoom_in", "zoom_out", "mapbtnunits", "mapbtnpower", "mapbtnfocuscamera", "reset_camera", "map_collapse", "toggle_power", "toggle_grid", "toggle_follow", "toggle_mapoverlay", "toggle_movepath", "overlaybtn", "editpinbtn" }
	local as_shortcut = { btn_tech = "Tech", btn_build = "Build", btn_codex = "Codex", btn_progress = "Progress", btn_library = "Library", btn_faction = "FactionView", toggle_power = "PowerInfo_Toggle", toggle_grid = "CursorGrid_Toggle", toggle_follow = "Camera_FollowTarget", toggle_mapoverlay = "MapOverlay", toggle_movepath = "ShowPath" }
	for _, v in pairs( bt_tootlips ) do
		if as_shortcut[ v ] ~= nil then self[ v ].tooltip = L( '<hl>%s</>\n<bl>[Shortcut :</> <Key action="%S" style="gl"/><bl>]</>', "synced.ui." .. v, as_shortcut[ v ] )
		else self[ v ].tooltip = L( '<hl>%s</>', "synced.ui." .. v ) end
	end
	
	self.zoom_in.on_click = function( button ) self.minimap:ZoomIn() end
	self.zoom_out.on_click = function( button ) self.minimap:ZoomOut() end
	self.mapbtnunits.on_click = function( button )
		self.minimap:SetShowFrames( not self.minimap:GetShowFrames() )
		self.mapbtnunits.active = self.minimap:GetShowFrames()
	end
	self.mapbtnunits.active = self.minimap:GetShowFrames()
	
	self.mapbtnpower.on_click = function( button )
		self.minimap:SetShowPowerGrid( not self.minimap:GetShowPowerGrid() )
		self.mapbtnpower.active = self.minimap:GetShowPowerGrid()
	end
	self.mapbtnpower.active = self.minimap:GetShowPowerGrid()
	
	self.mapbtnfocuscamera.on_click = function( button )
		self.minimap:SetFollowCamera(not self.minimap:GetFollowCamera())
		self.mapbtnfocuscamera.active = self.minimap:GetFollowCamera()
	end
	self.mapbtnfocuscamera.active = self.minimap:GetFollowCamera()
	-- self.enlarge_map.on_click = function( button )
		-- if self.minimap.width > 212 then
			-- self.enlarge_map.icon = "icon_expand"
			-- self.enlarge_map.tooltip = L( '<hl>%s</>', "synced.ui.enlarge_map" )
			-- self.minimap.width = 212
			-- self.minimap.height = 212
		-- else
			-- local swidth, sheight = Game.GetScreenResolution()
			-- self.minimap.width = swidth - 32 * 2 - 4 * 5
			-- self.minimap.height = sheight - 4 * 2
			-- self.enlarge_map.icon = "icon_minimize"
			-- self.enlarge_map.tooltip = L( '<hl>%s</>', "synced.ui.minimize_map" )
		-- end
	-- end
	self.reset_camera.on_click = function( button ) View.ResetCamera() end
	self.map_collapse.on_click = function( button )
		button.active = not self.minimapbar.hidden
		button.icon = not button.active and "icon_arrow_right" or "icon_arrow_left"
		self.minimapbar.hidden = button.active
	end
	self.toggle_power.on_click = function( button ) Quickview_TogglePower() ToggledButton( button ) end
	self.toggle_grid.on_click = function( button ) Quickview_ToggleGrid() ToggledButton( button ) end
	self.toggle_follow.on_click = function( button ) Quickview_ToggleFollow() end
	self.toggle_mapoverlay.on_click = function( button ) Quickview_ToggleMapOverlay() end
	self.toggle_movepath.on_click = function( button ) Quickview_ToggleMovePaths() ToggledButton( button ) end
end

function ToggledButton( btn )
	btn.active = not btn.active
end

function CUIMinimap:update()
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

function CUIMinimap:deconstruct()
	MinimapUI, CoordText = nil, nil
end

local open_window, open_window_name = nil, nil
function ResyncedCloseMainWindowAndPopup( no_sound, close_only_name )
	local res = not close_only_name and UI.CloseMenuPopup()
	if open_window then
		if not close_only_name or close_only_name == open_window_name then
			if open_window:IsValid() then
				if open_window.can_close and not open_window:can_close() then return false end
				open_window:RemoveFromParent()
				if not no_sound then UI.PlaySound("fx_ui_WINDOW_GENERIC_CLOSE") end
			end
			open_window, open_window_name = nil, nil
			return true
		end
	end
	return res
end

function ResyncedOpenMainWindow( name, param, no_sound )
	local popupY, popupNextToBtn = 0
	if name == "BuildView"    then popupNextToBtn         = MinimapUI.btn_build         end
	if name == "Codex"        then popupNextToBtn, popupY = MinimapUI.btn_codex,    156 end
	if name == "ResyncedProgressView" then popupNextToBtn, popupY = MinimapUI.btn_progress, 104 end
	if name == "Library"      then popupNextToBtn, popupY = MinimapUI.btn_library,   52 end
	if name == "Faction"      then popupNextToBtn         = MinimapUI.btn_faction       end
	if name == "Tech"      then popupNextToBtn         = MinimapUI.btn_tech       end
	if name == "ScreenMap"      then popupNextToBtn         = MinimapUI.bigmapbtn       end
	if popupNextToBtn then
		if open_window then ResyncedCloseMainWindowAndPopup(no_sound, open_window_name) end
		-- <VerticalList dock=center >
		UI.MenuPopup([[
			<VerticalList>
				<Box bg=popup_box_bg padding=4 blur=true />
			</VerticalList>
				]],
			{
				
				construct = function(w)
					w[1]:SetContent(name, param)
					UI.PlaySound("fx_ui_WINDOW_SELECTION_MENU_OPEN")
					popupNextToBtn.active = true
				end,

				destruct = function()
					if popupNextToBtn:IsValid() then popupNextToBtn.active = false end
				end,

				name = name, param = param, -- to avoid closing of an already open window if these differ
			},
			popupNextToBtn, "LEFT", "BOTTOM", -10, 4 )
	elseif name == "Chat" then
		UIShowTextChat()
	else -- Tech, Program, InGameMenu
		local open_new_window = (open_window_name ~= name)
		ResyncedCloseMainWindowAndPopup(open_new_window or param or no_sound)
		if open_new_window or param then
			if not no_sound then UI.PlaySound("fx_ui_WINDOW_GENERIC_OPEN") end
			open_window, open_window_name = UI.AddLayout(name, param, (name == "InGameMenu" and 22 or 0)), name
		end
	end
end

function CUIMinimap:on_open_window( button )
	-- if button.window == "Tech" then OpenMainWindow( button.window )
	-- else ResyncedOpenMainWindow( button.window ) end
	ResyncedOpenMainWindow( button.window )
end

--------------------
--------------------
function CUIMinimap:on_map_pin(btn)
	local map_pins = Game.GetLocalPlayerExtra().MapPins
	local function on_place_pin(ok, id)
		self.minimap.on_mouse_button_down = nil
		View.StopCursor()
		Quickview_HideGrid()
		if not ok then Notification.Warning("Aborted") return end

		local x, y = View.GetHoveredTilePosition()
		if id then
			if not map_pins then map_pins = {} Game.GetLocalPlayerExtra().MapPins = map_pins end
			map_pins[#map_pins+1] = { x, y, id }
			Notification.Warning(ok and L('Placed pin <img id="%s"/>', id))
			map_pin_indices[#map_pins] = self.minimap:AddPin(x, y, data.all[id].texture)
		elseif map_pins and #map_pins > 0 then
			local function getdist(i) local dx, dy = map_pins[i][1] - x, map_pins[i][2] - y return dx*dx+dy*dy end
			local closest, closest_distsq = 1, getdist(1)
			for i=2,#map_pins do
				local distsq = getdist(i)
				if distsq < closest_distsq then closest, closest_distsq = i, distsq end
			end
			Notification.Warning(ok and L('Removed pin <img id="%s"/>', map_pins[closest][3]))
			self.minimap:RemovePin(map_pin_indices[closest])
			table.remove(map_pins, closest)
			table.remove(map_pin_indices, closest)
		end
	end
	local function on_set_pin(rsel, new_reg_val)
		local id = new_reg_val and new_reg_val.id
		Notification.Warning(id and L('Click on location to place pin <img id="%s"/>', id) or "Click on pin to remove")
		Quickview_ShowGrid(0)
		View.StartCursorChooseLocation(function() on_place_pin(true, id) end, function() on_place_pin(false) end)
		self.minimap.on_mouse_button_down = function(minimap, mousebtn) on_place_pin(mousebtn == "LEFTMOUSEBUTTON", id) end
	end
	local function def_filter(def, cat) return not (cat.number_panel or cat.coord_panel or cat.entity_panel) end
	local rsel = ShowRegisterSelection(btn, on_set_pin, def_filter)
	if not rsel then return end
	rsel.orgUpdateVisuals = rsel.UpdateVisuals
	rsel.UpdateVisuals = function(self, switch_tab) self:orgUpdateVisuals(switch_tab) self.applybtn.disabled = self.register.id == nil end
	rsel.applybtn.disabled = true
	rsel.applybtn.tooltip = "Place new Pin"
	rsel.clearbtn.disabled = not map_pins or #map_pins == 0
	rsel.clearbtn.tooltip = "Remove a Pin"
end

function CUIMinimap:on_open_overlay_options(btn)
	OpenOverlayOptions(btn)
end

function CUIMinimap:on_map_fullscreen()
	ResyncedOpenMainWindow("ScreenMap")
end

function UIMsg.OnEntityHovered( entity, x, y )
	CoordText.text = x .. ", " .. y
end