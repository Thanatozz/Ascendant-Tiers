if false then return end

local go_ingame_message<const> = [[
Settings need to be configured in-game with all the mods you will use in the new game.
                        
You can start a new game, configure this mod from <desc>Options > Mods > New Game Plus</>, and then <desc>Restart game</>.]]

local layout_settings<const> =
[[
	<Box bg=popup_box_bg blur=true max-height=800 width=616>
		<VerticalList child-padding=0>
            <Button text=Apply on_click={on_apply} hidden=true/>
			<Box padding=8 width=600 id=content/>
		</VerticalList>
	</Box>
]]

local function AddButton(list, text, tooltip, on_click)
	local hl = list:Add("<HorizontalList child_align=center child_fill=true height=32><Button/></HorizontalList>")
	local btn = hl[1]
	btn.text, btn.tooltip, btn.on_click = text, tooltip, on_click
	return btn
end

local function AddInfo(list, label, value, tooltip)
	local c = list:Add("<Canvas><Text/><Text color=ui_light halign=right/></Canvas>")
	c[1].text, c[2].text, c[2].tooltip = value, label, tooltip
end

local start_types = {
    default = {id = "default", text = "Default units", tooltip = "The default starting units. <desc>(May vary depending on the selected scenario)</>"},
    nomad = {id = "nomad", text = "Nomad", tooltip = "The default units without the initial deployer component."},
    cub = {id = "cub", text = "Cub only", tooltip = "One Cub with internal storage, fabricator and solar cell."},
    deployer = {id = "deployer", text = "Deployer", tooltip = "Only the initial deployer component, fabricator and solar cell. <desc>(Additional units required)</>"},
    nothing = {id = "nothing", text = "Nothing", tooltip = "Nothing is nothing. <desc>(Additional units and components required)</>"},
}

return {
	FillInputList = function(settings, list, in_game)
        if in_game then return end
        AddButton(list, "New Game Plus", "Open New Game Plus mod options", function (btn)
            UI.MenuPopup(layout_settings, {
                construct = function (self)
                    if in_game then
                        local w = self.content:SetContent(UI.MakeModOptionsWidget("NewGamePlus"))
                    else
                        local w = self.content:SetContent(UI.New("<Text wrap=true/>", {text = go_ingame_message}))
                    end
                end
            }, btn, "RIGHT", 20)
        end)
	end,

	FillSettings = function(settings, list, in_game)
        
	end,

	FillInfoList = function(settings, list)
        if not settings.new_game_plus_settings then return end 
		if settings.new_game_plus_settings.num_players and settings.new_game_plus_settings.num_players ~= 1  then AddInfo(list, "Number of Players/faction", settings.new_game_plus_settings.num_players) end
        local start_type = settings.new_game_plus_settings.start_type and start_types[settings.new_game_plus_settings.start_type] or start_types["default"] 
		AddInfo(list, "Starting setup", start_type.text, start_type.tooltip)
        if settings.new_game_plus_settings.n_additional_units then AddInfo(list, "Additional Units", settings.new_game_plus_settings.n_additional_units) end
        if settings.new_game_plus_settings.n_additional_comps then AddInfo(list, "Additional Comp/Items", settings.new_game_plus_settings.n_additional_comps) end
        if settings.new_game_plus_settings.n_unlocked_techs then AddInfo(list, "Unlocked Techs", settings.new_game_plus_settings.n_unlocked_techs) end
	end,
}