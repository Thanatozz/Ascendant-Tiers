
if View.IsRunningHeadless() then return end
if Map.IsFrontEnd() and Game.GetScenarioModPackage().id == "FrontEnd" then return UI.New("<Text wrap=true/>", {text = "Settings need to be configured in-game with all the mods you will use in the new game. You can start a new game, configure this options and then restart the game."}) end

local profile = Game.GetProfile().new_game_plus
if not profile then profile = {} Game.GetProfile().new_game_plus = profile end
local additional_units = profile.additional_units
local additional_comps = profile.additional_comps
local unlocked_techs = profile.unlocked_techs
if not additional_units then additional_units = {} profile.additional_units = additional_units end
if not additional_comps then additional_comps = {} profile.additional_comps = additional_comps end
if not unlocked_techs then unlocked_techs = {} profile.unlocked_techs = unlocked_techs end
if not profile.start_type then profile.start_type = "default" end

local blueprints = Game.GetProfile("Main").library

local Register_layout<const> =
[[
	<Reg width=56 height=56 bg=reg_base on_click={on_reg_click} />
]]

local tech_categories = {}

for i,tech_cat in ipairs(data.tech_categories) do
    for j,tech_subcat in ipairs(tech_cat.sub_categories) do
        tech_categories[tech_subcat] = { idx = i * 100 + j, cat = tech_cat.name }
    end
end

tech_categories["Story"] = {idx = 1, cat = "Story"}

local function ProcessAllDefinitions(cb, get_library_blueprints, filter_defs)
	local categories, frames = data.categories, data.frames
	local library_blueprints = get_library_blueprints and Game.GetProfile("Main").library or {}
    local faction_blueprints = get_library_blueprints and Game.GetLocalPlayerFaction().extra_data.library
	local cat_value_idx, cat_value
    for catidx=1,#categories do
		local category = categories[catidx]
		if category.name == "Value" then cat_value_idx = catidx cat_value = category end
        local defs, filter_field, filter_val = category.defs, category.filter_field, category.filter_val
		if not filter_defs or defs == filter_defs then
			for def_id, def in pairs(defs) do
				if def[filter_field] == filter_val then cb(def_id, def, category, nil, catidx) end
			end
			if defs == frames then
				for i,bp in ipairs(library_blueprints) do
                    if bp.type == 'B' then
    					local f = frames[bp.frame]
                        if f and f[filter_field] == filter_val then
                            cb(i, bp, category, f, catidx, "profile")
                        end
                    end
				end
                for i,bp in ipairs(faction_blueprints) do
                    if bp.type == 'B' then
    					local f = frames[bp.frame]
                        if f and f[filter_field] == filter_val then
                            cb(i, bp, category, f, catidx, "faction")
                        end
                    end
				end
			end
		end
	end
    
    for i,v in pairs(data.techs) do
         if v.category and tech_categories[v.category] then
            cb(i, v, cat_value, nil, tech_categories[v.category].idx * 1000 + cat_value_idx)
         end
    end
end

local function FillDB(rs)
	local is_production, is_miner, producer_id, def_filter = rs.is_production, rs.is_miner, rs.producer_id, rs.def_filter

	local function on_click_def_id(w) rs:SetDefId(w.def_id) end
	local function on_click_blueprint(w)
        rs.register.lib_type = w.lib_type
        rs:SetDefId(w.bp.frame, w)
    end
	local function on_double_click() rs:on_apply() end
	local function on_tooltip_def(w) return BuildDefinitionTooltip(w.def) end
	local function on_tooltip_bp(w) return BuildDefinitionTooltip(w.bp) end

	local db, db_defs, folders, last_bp_cat_name = { item = {}, frame = {}, value = {} }, {}, {}
	ProcessAllDefinitions(function(id, def, category, bp_frame_def, catidx, lib_type)
		local cat_tab = category.tab
		if not cat_tab then return end

		if def_filter and not def_filter(type(id) ~= "string" and bp_frame_def or def, category) then return end

		if is_production then
			local production_recipe = (bp_frame_def or def).production_recipe
			if producer_id and (not production_recipe or not production_recipe.producers[producer_id]) then return end
			cat_tab = "item"
		elseif is_miner then
			local mining_recipe = def.mining_recipe
			if not mining_recipe or not mining_recipe[producer_id] then return end
			cat_tab = "item"
		end

		local tab_db = db[cat_tab]
		db_defs[def] = cat_tab

		if type(id) == "string" then
			tab_db[#tab_db+1] = {
				catidx = catidx,
                def = def, def_id = id,
				icon = def.texture or (bp_frame_def and bp_frame_def.texture),
				tooltip = on_tooltip_def,
				on_click = on_click_def_id,
				on_double_click = on_double_click,
				cat_name = category.name,
				sort_key = (def.race or def.tag or "") .. (def.order or "1") .. id,
				racebg = def.race and GetComponentRaceBG(def.race),
                folder = def.category
			}
		else -- library blueprint (id is index)
			local i, bpcatidx, bpfolder = #tab_db+1, catidx + 100, def.folder
            if lib_type == "faction" then
                bpcatidx = bpcatidx * 1000
            end
			if bpfolder then
				local folder_idx = folders[bpfolder]
				if not folder_idx then folders[bpfolder], folder_idx = i*1000, i*1000 end
				bpcatidx = bpcatidx + folder_idx
			end
			if bpcatidx ~= last_bp_cat_idx then
				last_bp_cat_name = (id > 0 and L("%s Blueprint", category.name) or category.name)
				if bpfolder then last_bp_cat_name = L("%s (%S)", last_bp_cat_name, bpfolder) end
                if lib_type == "faction" then
                    last_bp_cat_name = L("%s - Library", last_bp_cat_name)
                else
                    last_bp_cat_name = L("%s - Favorites", last_bp_cat_name)
                end
			end
			tab_db[i] = {
				catidx = bpcatidx, 
                bp = def, bp_index = id, idx = id, library_id = id,
                folder = bpfolder,
				icon = def.texture or bp_frame_def and bp_frame_def.texture,
				tooltip = on_tooltip_bp,
				on_click = on_click_blueprint,
				on_double_click = on_double_click,
				cat_name = last_bp_cat_name,
				sort_key = string.format("|%08d%08d", bpcatidx, id),
				racebg = "blueprint_bg",
                lib_type = lib_type 
			}
		end
	end, true)

	for _,regs in pairs(db) do
		table.sort(regs, function (a,b) return a.catidx < b.catidx or (a.catidx == b.catidx and a.sort_key > b.sort_key) end)
	end
	return db, db_defs
end

local filter_unit = function(def, cat) return def.movement_speed and def.movement_speed > 0 and def.size == "Unit" or cat.number_panel end
local filter_comp = function(def, cat) return cat.tab == "item" and not def.non_removable and def.type ~= "PassivePuzzle" or cat.number_panel end
local filter_tech = function(def, cat) return def.unlocks end

local FILTERS<const> = {
    unit = filter_unit,
    comp = filter_comp,
    tech = filter_tech,
}

local LISTS<const> = {
    unit = additional_units,
    comp = additional_comps,
    tech = unlocked_techs,
}

local RegisterSelection = UI.GetRegisteredLayoutClass("RegisterSelection") or {}
local RegisterSelection_old_Refresh = RegisterSelection.Refresh
function RegisterSelection:Refresh()
    local mine
    
    for i,f in pairs(FILTERS) do
        if self.def_filter == f then mine = true break end
    end
    
    if mine then
    
        self.hide_entity_panel = true
        self.hide_coord_panel = true
        self.db, self.db_defs = FillDB(self)
    	self:RefreshTab()
        
        for i,w in ipairs(self.list) do
            local text = w.text
            if text and text:find("Value Blueprint") then
                local subcat = text:sub(18, -3)
                local cat = tech_categories[subcat].cat
                w.text =  (cat == "Basic" and "Robot" or cat) .. " - " .. subcat
            end
        end
        
    	self:UpdateVisuals()
    else
        RegisterSelection_old_Refresh(self)
    end
end

local function IndexOf(list, object)
    for i,v in ipairs(list) do
        if v == object then return i end
    end
    return false
end 

local start_types = {
    {id = "default", text = "Default units", tooltip = "The default starting units. <desc>(May vary depending on the selected scenario)</>"},
    {id = "nomad", text = "Nomad", tooltip = "The default units without the initial deployer component."},
    {id = "cub", text = "Cub only", tooltip = "One Cub with internal storage, fabricator and solar cell."},
    {id = "deployer", text = "Deployer", tooltip = "Only the initial deployer component, fabricator and solar cell. <desc>(Additional units required)</>"},
    {id = "nothing", text = "Nothing", tooltip = "Nothing is nothing. <desc>(Additional units and components required)</>"},
}

return UI.New([[
	<ScrollList wrap=true child_padding=5>
        <Spacer/>
        <Text size=16 text="Description" color=ui_light/>
        <Text wrap=true text="Add units, components, items or unlocked techs to start the next game with." />
        <Text text = "<desc>(Right-click to remove)</>"/>
        <HorizontalList child_padding=3 child_align=center>
            <Text id=text_players y=-2 size=16 text="Number of players:" margin_right=5 color=ui_light />
            <Combo id=combo_players on_change={on_change_players} width=80/>
        </HorizontalList>
        <Text size=16 text="Starting setup" color=ui_light/>
        <Spacer/>
        <Wrap id=list_common wrapsize=600 child_padding=3></Wrap>
        <Spacer/>
        <Text size=16 text="Additional units" color=ui_light/>
        <Spacer/>
        <Wrap id=list_units wrapsize=600 child_padding=3></Wrap>
        <Button id=btn_add_unit reg_type=unit height=56 on_click={on_reg_click} icon=icon_add text="Add unit"/>
        <Spacer/>
        <Text size=16 text="Additional components/items" color=ui_light/>
        <Spacer/>
        <Wrap id=list_comps wrapsize=600 child_padding=3></Wrap>
        <Button id=btn_add_comp reg_type=comp height=56 on_click={on_reg_click} icon=icon_add text="Add component/item"/>
        <Spacer/>
        <Text size=16 text="Unlocked techs" color=ui_light/>
        <Spacer/>
        <Wrap id=list_techs wrapsize=600 child_padding=3></Wrap>
        <Button id=btn_add_tech reg_type=tech height=56 on_click={on_reg_click} icon=icon_add text="Add tech"/>
	</ScrollList>
	]], {
    construct = function(menu)
        
        local texts = {}
        for i=1,8 do
            texts[#texts + 1] = "x" .. i
        end
        menu.combo_players.texts = texts
        menu.combo_players.value = profile.num_players or 1
        
        local tooltip = UI.New([[<Box bg=card_box_bg padding=10 blur=true><VerticalList child_padding=3>
            <Text text="All units will spawn for every player in a different region of the map as if multiple factions were created." />
            <Text text="<desc>Designed to simulate multiple factions in Coop mode. Zoom out the minimap to find them.</>" />
        </VerticalList></Box>]])
        menu.combo_players.tooltip = tooltip
        menu.text_players.tooltip = tooltip
        
        for i, v in ipairs(start_types) do
            menu.list_common:Add("<Button height=56 width=112 on_click={on_reg_click} />", {
                reg_type = "common",
                start_type = v,
                text = v.text,
                tooltip = v.tooltip,
                active = not profile.start_type and v.id == "default" or v.id == profile.start_type,
            })
        end
        
        for i, v in ipairs(additional_units) do
            menu:add_reg_to_list(menu.list_units, v, "unit")
        end
        
        for i, v in ipairs(additional_comps) do
            menu:add_reg_to_list(menu.list_comps, v, "comp")
        end
        
        for i, v in ipairs(unlocked_techs) do
            menu:add_reg_to_list(menu.list_techs, v, "tech")
        end        
    end,
    on_change_players = function(menu, combo, value)
        profile.num_players = value
    end, 
    add_reg_to_list = function(menu, w_list, reg_data, reg_type)
        local reg = w_list:Add(Register_layout, {
            reg_data = reg_data,
            reg_type = reg_type,
            update = function(w)
                local reg_data = w.reg_data
                local def = data.all[reg_data.id]
                local bp = reg_data.bp
                w.num = reg_data.num
                if not def then
                    w.icon = "icon_small_warning"
                    w.tooltip = "Mod not installed. Definition not found: " .. reg_data.id
                    if w.prev then w.prev:RemoveFromParent() w.prev = nil end
                    return
                end
                --w.prev.hidden = not reg_data.bp
                w.base.image = bp and "blueprint_bg" or GetComponentRaceBG(def.race)
                w.bg = bp and "blueprint_bg" or GetComponentRaceBG(def.race)
                w.icon = not bp and def.texture or nil
                w.tooltip = DefinitionTooltip(bp or def)
                if bp then
                    local comps = {}
            		local visual = data.visuals[def.visual]
            		if visual and visual.sockets then
            			for i,v in ipairs(bp.components or {}) do
            				local socket = visual.sockets[v[2]]
                			local socket_name = socket and socket[1]
                			if socket_name and socket_name ~= "" then
                				local comp_def = data.components[v[1]]
                				local comp_visual = comp_def and comp_def.visual
                				if comp_visual then comps[socket_name] = comp_visual end
                			end
            			end
            		end
                    
                    if not w.prev then
                        w.prev = w:Add("<Preview quality=150 width=56 height=56 rotate=false pitch=45 yaw=-20/>", {visual = def.visual, components = comps})
                    else
                        w.prev.visual = def.visual
                        w.prev.components = comps
                    end
                else
                    if w.prev then w.prev:RemoveFromParent() w.prev = nil end
                end
            end,
        })
        reg.on_mouse_wheel = function(self, wheel)
        	if self.read_only then return end
            if self.reg_type == "tech" then return end
        	local ctrl, shift = Input.IsControlDown(), Input.IsShiftDown()
        	local change = (wheel > 0 and 1 or -1) * (ctrl and 10 or 1) * (shift and 5 or 1)
        	local n = math.max(math.max(self.num or 0, -1) + change, -1)
        	if n <= 0 then n = 1 end
        	if n == self.num then return end
        	self:SetNum(n)
        	self.num = n
            self.reg_data.num = n
        	UI.PlaySound("fx_ui_WINDOW_SELECTION_MENU_INCREMENT")
        end
        return reg
    end,
    on_reg_click = function(menu, reg, btn)
        local reg_type = reg.reg_type
        if reg_type == "common" then
            for i,w in ipairs(menu.list_common) do
                w.active = false
            end
            reg.active = true
            profile.start_type = reg.start_type.id
        else
            local list = LISTS[reg_type]
            if btn == "RIGHTMOUSEBUTTON" then
                if not reg.id then table.remove(list, IndexOf(list, reg.reg_data)) reg:RemoveFromParent() end
            else
                local rsel = ShowRegisterSelection(reg, function(rsel, new_reg_val, library_id) menu["add_" .. reg_type](menu, rsel.library_index or rsel.bp_index or library_id or new_reg_val.id, new_reg_val.num == REG_INFINITE and 1000 or new_reg_val.num, reg, new_reg_val.lib_type) end, FILTERS[reg_type])
                if not rsel then return end -- popup was closed
                if reg.reg_data then rsel:on_input_change(not reg.reg_data.bp and reg.reg_data.id, reg.reg_data.num) end
            end
        end
    end,
    add_unit = function(menu, id, num, reg, lib_type)
        local reg_type = reg.reg_type
        local list = LISTS[reg_type]
        local blueprint = type(id) ~= "string" and Tool.Copy(lib_type == "profile" and blueprints[id] or Game.GetLocalPlayerFaction().extra_data.library[id])
        local frame = blueprint and blueprint.frame or id
        if reg.id then
            if not frame then return end
            list[#list + 1] = {id = frame, bp = blueprint, num = num}
            reg = menu:add_reg_to_list(reg.previous_sibling, list[#list], reg_type)
        else
            if not num or num <= 0 then table.remove(list, IndexOf(list, reg.reg_data)) reg:RemoveFromParent() return end
            reg.reg_data.id = frame or reg.reg_data.id
            reg.reg_data.bp = not frame and reg.reg_data.bp or blueprint 
            reg.reg_data.num = num
            reg:update()
        end
        return reg
    end,
    add_comp = function(menu, id, num, reg)
        local reg_type = reg.reg_type
        local list = LISTS[reg_type]
        if reg.id then
            if not id then return end
            list[#list + 1] = {id = id, num = num}
            reg = menu:add_reg_to_list(reg.previous_sibling, list[#list], reg_type)
        else
            if not num or num <= 0 then table.remove(list, IndexOf(list, reg.reg_data)) reg:RemoveFromParent() return end
            reg.reg_data.id = id or reg.reg_data.id
            reg.reg_data.num = num
            reg:update()
        end
        return reg
    end,
    add_tech = function(menu, id, num, reg)
        local reg_type = reg.reg_type
        local list = LISTS[reg_type]
        if reg.id then
            if not id then return end
            list[#list + 1] = {id = id}
            reg = menu:add_reg_to_list(reg.previous_sibling, list[#list], reg_type)
        else
            reg.reg_data.id = id or reg.reg_data.id
            reg:update()
        end
        return reg
    end,
})
