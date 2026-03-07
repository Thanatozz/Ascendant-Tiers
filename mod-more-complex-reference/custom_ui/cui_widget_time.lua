if not GetOptionValue( "resynced", "custom_ui" ) then return end

local WidgetTime = {}
UI.Register( "WidgetTime", [[
	<Box bg=no_background padding=4 margin_top=-4 >
		<Canvas tooltip={time_tooltip} >
			<Image width=152 image=item_default height=18 />
			<Image id=sunrise_icon image=icon_small_day   width=16 height=16 color=yellow y=1 margin_left=4 />
			<Image id=sunset_icon  image=icon_small_night width=16 height=16 color=ui_dark y=1 halign=right margin_right=4 />
			<Progress id=time_bar progress=0.5 y=20 height=12 color=ui_light halign=fill />
			<Image id=sunrise_arrow width=2 height=12 y=20 color=yellow margin_left=11 />
			<Image id=sunset_arrow  width=2 height=12 y=20 color=ui_dark halign=right margin_right=11 />
			<Text id=day size=10 margin_left=22 y=1 />
			<Text id=time halign=right size=10 margin_right=22 y=1 />
		</Canvas>
	</Box>
]], WidgetTime )

local timestr_sunrise, timestr_sunset

function WidgetTime:construct()

	-- local timebarwidth = self.time_bar.width - 4
	local sunrise, sunset = Map.GetSunriseAndSunset()
	-- self.sunrise_icon.x, self.sunrise_arrow.x = 4 + sunrise * timebarwidth - 10, 2 + sunrise * timebarwidth - 1
	-- self.sunset_icon.x,  self.sunset_arrow. x = 4 + sunset  * timebarwidth - 10, 2 + sunset  * timebarwidth - 1
	-- self.txt_pause.x = (self.sunrise_arrow.x + self.sunset_arrow.x) / 2 + 1
	timestr_sunrise = string.format("%02d:%d0", math.floor(sunrise * 24), math.floor(sunrise * 144 % 6))
	timestr_sunset = string.format("%02d:%d0", math.floor(sunset * 24), math.floor(sunset * 144 % 6))

end

function WidgetTime:update()
	local total = Map.GetTotalDays()
	-- self.time_day.text = L("Day %d", math.floor(total + 1))
	-- self.time_txt.text = string.format("%02d:%d0", math.floor(total * 24 % 24), math.floor(total * 144 % 6))
	self.day.text = L( "Day %d", math.floor( total + 1 ))
	self.time.text = L( "%02d:%d0", math.floor( total * 24 % 24 ), math.floor( total * 144 % 6 ))
	self.time_bar.progress = (total % 1.0)

	-- local pause = (Map.GetGameSpeed() == 0)
	-- if self.lastpause ~= pause then
		-- self.lastpause = pause
		-- self.txt_pause.hidden = not pause
		-- self.btn_pause.active = pause
		-- if pause and not PausedOpen then
			-- PausedOpen = UI.AddLayout(Paused_layout)
		-- elseif PausedOpen then
			-- PausedOpen:RemoveFromParent()
			-- PausedOpen = nil
		-- end
	-- end
end

function WidgetTime:time_tooltip()
	return UI.New([[<Box padding=8 bg=popup_box_bg blur=true><VerticalList>
			<HorizontalList child_align=center><Image image=icon_tiny_day      color=ui_light margin_right=4/><Text id=sunrise width=100/><Text text="Sunrise"         color=ui_light fill=true textalign=right/></HorizontalList>
			<HorizontalList child_align=center><Image image=icon_tiny_night    color=ui_light margin_right=4/><Text id=sunset  width=100/><Text text="Sunset"          color=ui_light fill=true textalign=right/></HorizontalList>
			<HorizontalList child_align=center><Image image=icon_tiny_tick     color=ui_light margin_right=4/><Text id=tick    width=100/><Text text="Simulation Tick" color=ui_light fill=true textalign=right/></HorizontalList>
			<HorizontalList child_align=center><Image image=icon_tiny_save     color=ui_light margin_right=4/><Text id=save    width=100/><Text text="Since Last Save" color=ui_light fill=true textalign=right/></HorizontalList>
			<HorizontalList child_align=center><Image image=icon_tiny_duration color=ui_light margin_right=4/><Text id=played  width=100/><Text text="Time Played"     color=ui_light fill=true textalign=right/></HorizontalList>
			<HorizontalList child_align=center><Image image=icon_tiny_time     color=ui_light margin_right=4/><Text id=current width=100/><Text text="Current Time"    color=ui_light fill=true textalign=right/></HorizontalList>
		</VerticalList></Box>]], {
		update = function(w)
			w.sunrise.text = timestr_sunrise
			w.sunset.text = timestr_sunset
			w.tick.text = Map.GetTick()
			w.save.text = Tool.GetTimeDurationStr(Game.GetTimeSinceSave())
			w.played.text = Tool.GetTimeDurationStr(Game.GetGameDuration())
			w.current.text = NOLOC(Tool.GetDateStr("%X"))
		end
	})
end