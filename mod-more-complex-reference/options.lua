function GetModInfos( id )
	for k, v in pairs( Game.GetInstalledMods() ) do
		if v.id == id then
			return v
		end
	end
end

data.styles.rv = { size = 10, outline_size = 1, color = "#F6C667" }

local ResyncedTitleBox = {}
UI.Register( "ResyncedTitleBox", [[<HorizontalList>
			<Box padding=4 bg=card_box_bg margin_right=4 ><Image image={iconv} width=26 height=26 /></Box>
			<Box padding=4 bg=card_box_bg fill=true ><Text text={text_title} valign=center margin_left=4 /></Box>
		</HorizontalList>]], ResyncedTitleBox )

local ResyncedTitleBoxTexted = {}
UI.Register( "ResyncedTitleBoxTexted", [[<VerticalList margin_bottom=4 >
		<HorizontalList>
			<Box padding=4 bg=card_box_bg margin_bottom=4 margin_right=4 ><Image image={iconv} width=26 height=26 /></Box>
			<Box padding=4 bg=card_box_bg margin_bottom=4 fill=true ><Text text={text_title} valign=center margin_left=4 /></Box>
		</HorizontalList>
		<Text text={text_content} wrap=true />
	</VerticalList>]], ResyncedTitleBoxTexted )

local ResyncedDefault_Options = {}
local ResyncedDefault_Layout< const > = [[
	<VerticalList child_padding=8 fill=true >
		<ResyncedTitleBoxTexted text_title=synced.option.title text_content=synced.option.titlet iconv=icon_small_day />
		<ResyncedTitleBoxTexted text_title=synced.option.languages text_content=synced.option.languagest iconv=icon_small_behavior />
		<ResyncedTitleBoxTexted text_title=synced.option.content text_content=synced.option.contentt iconv=icon_small_sort />
		<ResyncedTitleBoxTexted text_title=synced.option.warn text_content=synced.option.warnt iconv=icon_small_warning />
		<Text id=resynced_version dock=bottom-right size=8 color="#bbcece" />
	</VerticalList>
]]

if not UI.IsRegistered( "ResyncedDefault" ) then
	UI.Register( "ResyncedDefault", ResyncedDefault_Layout, ResyncedDefault_Options )
end

function ResyncedDefault_Options:construct()
	self.resynced_version.text = "v" .. GetModInfos( "Resynced" ).version_name
	-- self.resynced_version.text = L( '<nt>v%s</>', GetModInfos( "Resynced" ).version_name )
end

if Map.IsFrontEnd() or not UI.IsRegistered( "ResyncedSettings" ) or not Game.IsHostPlayer() then
	return UI.New( "ResyncedDefault" )
end

return UI.New( "ResyncedSettings" )