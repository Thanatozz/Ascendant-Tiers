if not GetOptionValue( "resynced", "custom_ui" ) then return end

local ActionBar = {}
UI.Register( "ResyncedActionBar", [[
	<VerticalList dock=top-right child_align=top >
		<Box bg=popup_additional_bg >
			<VerticalList>
				<ResyncedTopBarMenu />
				<HorizontalList>
					<WidgetPowerGrid />
					<WidgetTime />
				</HorizontalList>
			</VerticalList>
		</Box>
		<Notifications/>
	</VerticalList>
]], ActionBar )

function ActionBar:update()
	if Map.GetGameSpeed() == 0 and not PausedOpen then
		PausedOpen = UI.AddLayout([[
			<Canvas dock=center >
				<Box dock=fill opacity=0.7/>
				<Image color="#5CEBA319" dock=fill/>
				<Image image=warning_pattern color="#60D4A2" dock=top-right/>
				<Text textalign=center text="Paused" style=notify_info width=446 wrap=true fill=true valign=center/>
			</Canvas>
		]])
	elseif Map.GetGameSpeed() > 0 and PausedOpen then
		PausedOpen:RemoveFromParent()
		PausedOpen = nil
	end
end