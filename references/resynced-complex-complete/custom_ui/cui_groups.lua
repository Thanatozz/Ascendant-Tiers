if not GetOptionValue( "resynced", "custom_ui" ) then return end

local ResyncedShortcutBar = {}
UI.Register( "ResyncedShortcutBar", [[
	<HorizontalList child_padding=4/>
]], ResyncedShortcutBar )

function ResyncedShortcutBar:construct()
	ResyncedShortcutBar.open = self
	self.chk = 0
	self:refresh()
end

function ResyncedShortcutBar:destruct()
	ResyncedShortcutBar.open = nil
end

local function ResyncedShortcutBar_FilterEntities(entities, group_num)
	if not entities or #entities == 0 then return end
	local local_player_faction_id, changed = Game.GetLocalPlayerFaction().id
	-- check for destroyed or foreign units
	for i=#entities,1,-1 do
		local entity = entities[i]
		local entfac = entity.exists and entity.faction.id
		if not entfac or (entfac ~= local_player_faction_id and entfac ~= "world") then
			changed = true
			table.remove(entities, i)
		end
	end
	if group_num and #entities == 0 then
		Game.GetLocalPlayerExtra().ShortcutFrames[group_num] = nil
	end
	return changed
end

function ResyncedShortcutBar:update()
	local chk, shortcut_frames = self.chk + 1, Game.GetLocalPlayerExtra().ShortcutFrames
	local do_refresh = ResyncedShortcutBar_FilterEntities(shortcut_frames and shortcut_frames[chk], chk)
	self.chk = chk % 10
	if do_refresh then self:refresh() end
end

function ResyncedShortcutBar:refresh()
	self:Clear()
	local shortcut_frames = Game.GetLocalPlayerExtra().ShortcutFrames
	for num=1,10 do
		local entities = shortcut_frames and shortcut_frames[num]
		if entities and #entities > 0 then
			local entity = entities[1]
			if not entity.exists then
				ResyncedShortcutBar_FilterEntities(entities, num)
				if #entities == 0 then goto skip_entity end
				entity = entities[1]
			end
			self:Add('<Reg bg="Main/textures/skins/bg_item_selectable.png" on_click={on_click_shortcut}/>', {
				icon = entity.def.texture,
				ent = entity,
				num = num,
				tooltip = L("%d Units in Shortcut Group #%d", #entities, num),
			})
			::skip_entity::
		end
	end

	-- add idle button
	self:Add('<Reg bg="Main/textures/skins/bg_item_selectable.png" on_click={on_click_next_idle}/>', {
		icon = "Main/textures/icons/states/idle.png?filter=bilinear?mipmaps=true",
		tooltip = L("Next Idle Unit"),
	})
	self.hidden = (#self == 0)
end

local function array_contains(a, b)
	for _,y in ipairs(b) do
		local idx
		for i,x in ipairs(a) do if x == y then idx = i break end end
		if not idx then return false end
	end
	return true
end

local function ResyncedShortcutBar_DoSelect(num, ctrl, shift)
	local extra = Game.GetLocalPlayerExtra()
	local group = extra.ShortcutFrames and extra.ShortcutFrames[num] or {}
	local selected = View.GetSelectedEntities() or {}
	ResyncedShortcutBar_FilterEntities(group, num)
	ResyncedShortcutBar_FilterEntities(selected)

	local function array_add(a, b)
		for _,y in ipairs(b) do
			local idx
			for i,x in ipairs(a) do if x == y then idx = i break end end
			if not idx then table.insert(a, y) end
		end
	end
	local function array_remove(a, b)
		for _,y in ipairs(b) do
			local idx
			for i,x in ipairs(a) do if x == y then idx = i break end end
			if idx then table.remove(a, idx) end
		end
	end

	if ctrl then
		if shift and #group > 0 then
			-- Modify existing shortcut group
			if array_contains(group, selected) then
				array_remove(group, selected)
			else
				array_add(group, selected)
			end
		else
			-- Set new shortcut group
			if not extra.ShortcutFrames then
				extra.ShortcutFrames = {}
			end
			extra.ShortcutFrames[num] = selected
		end
		if ResyncedShortcutBar.open then
			ResyncedShortcutBar.open:refresh()
		end
	elseif shift then
		-- Modify current selection
		if array_contains(selected, group) then
			array_remove(selected, group)
		else
			array_add(selected, group)
		end
		View.SelectEntities(selected)
	elseif #selected == #group and array_contains(selected, group) then
		-- Set current selection
		View.JumpCameraToEntities(group)
	else
		View.SelectEntities(group)
	end
end

function ResyncedShortcutBar:on_click_shortcut(btn, key)
	local num = btn.num
	if key ~= "RIGHTMOUSEBUTTON" then
		ResyncedShortcutBar_Select(num)
		return
	end

	UI.MenuPopup([[<Box padding=5><VerticalList>
			<Text id=title textalign=center margin_bottom=5/>
			<Button id=ctrlshift on_click={on_ctrlshift}/>
			<Button id=shift     on_click={on_shift}    />
			<Button id=ctrl      on_click={on_ctrl}     />
			<Button id=select    on_click={on_select}   />
			<Button id=clear     on_click={on_clear}    text="Remove Shortcut Group"/>
		</VerticalList></Box>]], {
		construct = function(menu)
			menu:TweenFromTo("sy", 0, 1, 100)
			local shortcut_groups = Game.GetLocalPlayerExtra().ShortcutFrames
			local group = shortcut_groups and shortcut_groups[num] or {}
			local selected = View.GetSelectedEntities() or {}
			ResyncedShortcutBar_FilterEntities(group, num)
			ResyncedShortcutBar_FilterEntities(selected)
			local selected_in_group = array_contains(group, selected)
			local group_in_selected = array_contains(selected, group)
			local equal = selected_in_group and group_in_selected
			local show_modify = #selected > 0 and not equal

			local key_action = string.format("Select%d", (num % 10))
			menu.title.text = L("%d Units in Shortcut Group #%d", #group, num)
			menu.ctrlshift.text = L('%s (%S+%S+<Key action="%S"/>)', selected_in_group and "Remove Selection from Group" or "Add Selection to Group", "Ctrl", "Shift", key_action)
			menu.shift.text = L('%s (%S+<Key action="%S"/>)', group_in_selected and "Remove Group from Selection" or "Add Group to Selection", "Shift", key_action)
			menu.ctrl.text = L('%s (%S+<Key action="%S"/>)', "Overwrite Group with Selection", "Ctrl", key_action)
			menu.select.text = L('%s (<Key action="%S"/>)', equal and "Move Camera to Group" or "Select Group", key_action)

			menu.ctrlshift.hidden = not show_modify
			menu.shift.hidden     = not show_modify
			menu.ctrl.hidden      = not show_modify
		end,
		on_ctrlshift = function(menu) ResyncedShortcutBar_DoSelect(num,  true,  true) UI.CloseMenuPopup() end,
		on_shift     = function(menu) ResyncedShortcutBar_DoSelect(num, false,  true) UI.CloseMenuPopup() end,
		on_ctrl      = function(menu) ResyncedShortcutBar_DoSelect(num,  true, false) UI.CloseMenuPopup() end,
		on_select    = function(menu) ResyncedShortcutBar_DoSelect(num, false, false) UI.CloseMenuPopup() end,
		on_clear = function(menu)
			Game.GetLocalPlayerExtra().ShortcutFrames[num] = nil
			if ResyncedShortcutBar.open then
				ResyncedShortcutBar.open:refresh()
			end
			UI.CloseMenuPopup()
		end,
	}, btn)
end

function ResyncedShortcutBar:on_click_next_idle(btn)
	local next_idle
	local selected_entities = View.GetSelectedEntities()
	local curr_idle = selected_entities and selected_entities[1]
	local entities = Game.GetLocalPlayerFaction().entities

	for _,e in ipairs(entities) do
		if e.def.movement_speed and e.state_idle then
			if not next_idle then next_idle = e end
			if curr_idle then
				if e == curr_idle then curr_idle = nil end
			else
				next_idle = e
				break
			end
		end
	end
	if next_idle then
		View.SelectEntities(next_idle)
	else
		Notification.Warning("No Idle Units")
	end
end

function ResyncedShortcutBar_Select(num)
	ResyncedShortcutBar_DoSelect(num, Input.IsControlDown(), Input.IsShiftDown())
end