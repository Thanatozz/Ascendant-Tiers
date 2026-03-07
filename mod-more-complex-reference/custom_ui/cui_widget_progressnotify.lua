if not GetOptionValue( "resynced", "custom_ui" ) then return end

local ProgressPopup_layout<const> = [[
	<Box dock=top-left bg=popup_box_bg padding=4 blur=true width=520 y=0>
		<Box bg=popup_pattern padding=4 blocking=false>
			<VerticalList>
				<HorizontalList child_padding=8>
					<Reg width=96 height=96 def_id={reg_item_id} icon={reg_icon} bg=item_default on_click={on_click}/>
					<VerticalList fill=true valign=center>
						<Text size=16 text={header} color=ui_light/>
						<Text size=20 text={title}/>
					</VerticalList>

				</HorizontalList>

				<HorizontalList halign=center child_padding=4 hidden={hide_stars}>
					<Image color=ui_light tooltip={tooltip1} image={star1}/>
					<Image color=ui_light tooltip={tooltip2} image={star2}/>
					<Image color=ui_light tooltip={tooltip3} image={star3}/>
				</HorizontalList>
			</VerticalList>
		</Box>
	</Box>
]]

local ProgressPopupOpen
local function ShowProgressPopup(goal_def, milestone, count)
	if Action.IsReplayPlayback() then return end -- no popups while playing back replay
	if ProgressPopupOpen then ProgressPopupOpen:RemoveFromParent() end

	local prop
	if goal_def then
		prop = {
			header = "Completed Goal",
			title = goal_def.title,
			--details = goal_def.details,
			reg_icon = goal_def.goalicon,
			hide_stars = true,
		}
	else
		prop = {
			header = "Reached Milestone",
			title = milestone.title,
			--details = milestone.details,
			reg_item_id = milestone.id,
			reg_icon = milestone.icon,
			star1 = count >= milestone.levels[1] and "icon_achieved" or "icon_achieve",
			star2 = count >= milestone.levels[2] and "icon_achieved" or "icon_achieve",
			star3 = count >= milestone.levels[3] and "icon_achieved" or "icon_achieve",
			tooltip1 = L("Reach %d", milestone.levels[1]),
			tooltip2 = L("Reach %d", milestone.levels[2]),
			tooltip3 = L("Reach %d", milestone.levels[3]),
		}
	end
	function prop:construct()
		self.timer = 5
		self:TweenFromTo("sy", 0.5, 1, 200, "OutQuad")
		self:TweenFromTo("x", -1000, 0, 200, "OutQuad")
	end
	function prop:on_click()
		self:closepopup()
		ResyncedProgressViewTabIsMilestones = not self.hide_stars
		ResyncedOpenMainWindow("ResyncedProgressView")
	end
	function prop:closepopup()
		self.timer = nil
		self:TweenFromTo("sy", 1, 0.5, 200, "InQuad")
		self:TweenFromTo("x", 0, -1000, 200, "InQuad", function() self:RemoveFromParent() end)
		self.on_click = nil
		ProgressPopupOpen = nil
	end
	function prop:every_frame_update(dt)
		if not self.timer then self.every_frame_update = nil return end
		self.timer = self.timer - dt
		if self.timer <= 0.0 then
			self:closepopup()
		end
	end
	ProgressPopupOpen = UI.AddLayout(ProgressPopup_layout, prop)
end

local milestones_db<const> = {
	{
		type = "ITEM",
		title = "Mine Metal Ore",
		details = "Use a miner component to mine metal ore",
		id = "metalore",
		levels = { 5000, 50000, 500000 },
	},
	{
		type = "ITEM",
		title = "Mine Crystal Chunks",
		details = "Use a miner component to mine crystal chunks",
		id = "crystal",
		levels = { 5000, 50000, 500000 },
	},
	{
		type = "ITEM",
		title = "Mine Silica Sand",
		details = "Use a miner component to mine silica sand",
		id = "silica",
		levels = { 5000, 50000, 500000 },
	},
	{
		type = "ITEM",
		title = "Mine Laterite Ore",
		details = "Use a laser extractor component to mine laterite ore",
		id = "laterite",
		levels = { 5000, 50000, 500000 },
	},
	{
		type = "ITEM",
		title = "Fabricate Metal Bars",
		details = "Use a fabricator component to fabricate metal bars",
		id = "metalbar",
		levels = { 1000, 10000, 500000 },
	},
	{
		type = "COUNTER",
		title = "Bots Built",
		details = "How many bot units you have produced",
		icon = "Main/textures/icons/values/bot.png",
		counter = "built_bot",
		levels = { 5, 30, 100 },
	},
	{
		type = "COUNTER",
		title = "Buildings Built",
		details = "How many buildings you have built",
		icon = "Main/textures/icons/values/building.png",
		counter = "buildings_built",
		levels = { 10, 50, 200 },
	},
	{
		type = "COUNTER",
		title = "Solve Robot Explorables",
		details = "Visit and solve the challenges on explorables by the robot race",
		icon = "Main/textures/icons/values/solved.png",
		counter = "solved_explorable_robot",
		levels = { 5, 10, 100 },
	},
	{
		type = "COUNTER",
		title = "Solved Circuit puzzles",
		details = "Solve Circuit puzzle in ruins",
		icon = "Main/textures/icons/explorablespanel/netwalk/source.png",
		counter = "ExplorableGameNetWalk",
		levels = { 5, 10, 50 },
		hidden = true,
	},
	{
		type = "COUNTER",
		title = "Solved Nine Clicks puzzle",
		details = "Solve Nine Clicks puzzle in ruins",
		icon = "Main/textures/icons/explorablespanel/powerclickpuzzle/powerclickpuzzle-base.png",
		counter = "ExplorableGameNineClicks",
		levels = { 5, 10, 50 },
		hidden = true,
	},
	{
		type = "COUNTER",
		title = "Solved Balance Puzzles",
		details = "Solve Balance puzzle in ruins",
		icon = "Main/textures/icons/alien_text/alien_a.png",
		counter = "ExplorableGameBalance",
		levels = { 5, 10, 50 },
		hidden = true,
	},
	{
		type = "COUNTER",
		title = "Solved Sliding Puzzles",
		details = "Solve Sliding puzzle in ruins",
		icon = "Main/textures/icons/values/number_8.png",
		counter = "ExplorableGameSlide",
		levels = { 5, 10, 50 },
		hidden = true,
	},
	{
		type = "COUNTER",
		title = "Bugs Killed",
		details = "How many alien creatures you've killed",
		icon = "Main/textures/icons/values/bug.png",
		counter = "BugsKilled",
		levels = { 10, 250, 1000 },
	},
	{
		type = "COUNTER",
		title = "Satellites launched",
		details = "Launch satellites off the planet",
		icon = "Main/textures/icons/frame/satellite.png",
		counter = "satellites_launched",
		levels = { 1, 10, 100 },
	},
	{
		type = "FIELD",
		title = "Tiles Discovered",
		details = "How many map tiles you've discovered",
		icon = "Main/textures/icons/values/world.png",
		field = "discovered_tiles",
		levels = { 50000, 250000, 1000000 },
	}
}

local function GetMilestone(v, faction, counters)
	local count, show
	if v.type == "ITEM" then
		show = faction:IsUnlocked(v.id)
		count = show and faction:GetItemTotals(v.id) or 0
	elseif v.type == "COUNTER" then
		count = counters and counters[v.counter] or 0
		if count == true then count = 1 end
		show = not v.hidden or (count > 0)
	elseif v.type == "FIELD" then
		count = faction[v.field] or 0
		show = not v.hidden or (count > 0)
	end
	return count, show
end

local function IsGoalDone(def, faction)
	local progress = def.goal_check(faction or Game.GetLocalPlayerFaction())
	if type(progress) == "number" then return progress >= (def.steps or 1) end
	return progress
end

local function IsGoalHidden(def, hidden_goals)
	return (hidden_goals or Game.GetLocalPlayerExtra().hidden_goals or {})[def.id]
end

local ResyncedProgressView_layout<const> =
[[
	<VerticalList child_padding=4>
		<Box bg=popup_pattern padding=4>
			<VerticalList>
				<Text text="In Progress" color=ui_light height=24/>
				<ScrollList id=listinprogress width=596 min_height=50 child_padding=2/>
				<Text text="Completed" color=ui_light height=24/>
				<ScrollList id=listcompleted width=596 min_height=50 child_padding=2/>
			</VerticalList>
		</Box>
		<Box bg=popup_additional_bg padding=6>
			<HorizontalList child_fill=true child_padding=4>
				<Button id=btngoals      text="Goals"      on_click={on_switch_tab} active=true disabled=true/>
				<Button id=btnmilestones text="Milestones" on_click={on_switch_tab} active=false disabled=false/>
			</HorizontalList>
		</Box>
	</VerticalList>
]]

local GoalEntry_layout<const> =
[[
	<Box bg=popup_additional_bg padding=6>
		<VerticalList child_padding=4>
			<HorizontalList child_padding=4>
				<Box bg=item_default padding=3 valign=top>
					<Image image={icon} width=50 height=50/>
				</Box>
				<VerticalList fill=true>
					<Text text={title}/>
					<Text text={details} wrap=true wrapsize=510/>
				</VerticalList>
			</HorizontalList>
			<HorizontalList child_align=center child_padding=5 hidden={hidebar}>
				<Progress progress={progress} color=ui_light bg=progress_stroke width=440 height=16/>
				<Text text={steps}/>
			</HorizontalList>
			<HorizontalList child_align=center child_padding=5>
				<Button icon={checkicon} hidden={checkhidden} active={checkactive} on_click={on_click_goal_toggle}/>
				<Text text="Show on Game Screen" hidden={checkhidden}/>
				<Spacer fill=true/>
				<Button text="More Information" width=300 on_click={on_click_goal_info}/>
			</HorizontalList>
		</VerticalList>
	</Box>
]]

local MilestoneEntry_layout<const> =
[[
	<Box bg=popup_additional_bg padding=6>
		<VerticalList child_padding=4>
			<HorizontalList child_padding=4>
				<Reg def_id={reg_item_id} icon={reg_icon} bg=item_default valign=top/>
				<VerticalList fill=true>
					<Text text={title}/>
					<Text text={details} wrap=true wrapsize=510/>
				</VerticalList>
				<Image color=ui_light tooltip={tooltip1} image={star1}/>
				<Image color=ui_light tooltip={tooltip2} image={star2}/>
				<Image color=ui_light tooltip={tooltip3} image={star3}/>
			</HorizontalList>
			<HorizontalList child_align=center child_padding=5 hidden={hidebar}>
				<Progress progress={progress} color=ui_light bg=progress_stroke width=440 height=16/>
				<Text text={steps}/>
			</HorizontalList>
		</VerticalList>
	</Box>
]]

local DoneMilestoneEntry_layout<const> =
[[
	<Box bg=popup_additional_bg padding=6>
		<HorizontalList child_padding=4>
			<Image image=icon_large_medal/>
			<VerticalList child_padding=4>
				<Text text={title} fill=true/>
				<Text text={steps}/>
			</VerticalList>
		</HorizontalList>
	</Box>
]]

local ProgressNotificationsOpen
local ResyncedProgressViewTabIsMilestones
local ResyncedProgressView<const> = {}
UI.Register("ResyncedProgressView", ResyncedProgressView_layout, ResyncedProgressView)

function ResyncedProgressView:construct()
	if ResyncedProgressViewTabIsMilestones then
		self:on_switch_tab()
	else
		self:Refresh()
	end
end

function ResyncedProgressView:on_switch_tab()
	local is_milestones = not self.btnmilestones.active
	self.btngoals.active, self.btngoals.disabled = not is_milestones, not is_milestones
	self.btnmilestones.active, self.btnmilestones.disabled = is_milestones, is_milestones
	self:Refresh()
	ResyncedProgressViewTabIsMilestones = is_milestones
end

function ResyncedProgressView:Refresh()
	self.listinprogress:Clear()
	self.listcompleted:Clear()
	if self.btngoals.active then
		self:ListGoals()
	else
		self:ListMilestones()
	end
	local hideinprogress, hidecompleted = #self.listinprogress == 0, #self.listcompleted == 0
	self.listinprogress.max_height, self.listinprogress.hidden, self.listinprogress.previous_sibling.hidden = hidecompleted  and 874 or 450, hideinprogress, hideinprogress
	self.listcompleted.max_height,  self.listcompleted.hidden,  self.listcompleted.previous_sibling.hidden  = hideinprogress and 874 or 400, hidecompleted,  hidecompleted
end

function ResyncedProgressView:ListGoals()
	local goal_defs = {}
	local faction, hidden_goals = Game.GetLocalPlayerFaction(), Game.GetLocalPlayerExtra().hidden_goals or {}

	for id, def in pairs(data.codex) do
		if def.goal_check and faction:IsUnlocked(id) then
			table.insert(goal_defs, def)
		end
	end
	table.sort(goal_defs, function(a,b) if a.index and b.index then return a.index > b.index end return a.title < b.title end)

	for _,goal_def in ipairs(goal_defs) do

		local res, steps = goal_def.goal_check(faction), goal_def.steps or 1
		local num = type(res) == "number" and res or not res and 0 or steps
		local done, hidden = IsGoalDone(goal_def, faction), hidden_goals[goal_def.id]
		local list = done and self.listcompleted or self.listinprogress
		local newentry = list:Add(GoalEntry_layout, {
			goal_def = goal_def,
			icon = goal_def.goalicon,
			title = goal_def.title,
			details = goal_def.details,
			hidebar = not goal_def.steps,
			progress = num / steps,
			steps = string.format("%d / %d", num, steps),
			checkhidden = done,
			checkactive = not hidden,
			checkicon = hidden and "icon_small_empty" or "icon_small_confirm",
		})
		if goal_def.id == self.param then
			self.highlight = newentry
			self.hl = 1
		end
	end
end

function ResyncedProgressView:ListMilestones()
	local faction = Game.GetLocalPlayerFaction()
	local counters = faction.extra_data.counters
	for _,v in ipairs(milestones_db) do
		local count, show = GetMilestone(v, faction, counters)
		if show then
			local done = count >= v.levels[3]
			local list = done and self.listcompleted or self.listinprogress
			local nextlevel = v.levels[count < v.levels[1] and 1 or (count < v.levels[2] and 2 or 3)]
			list:Add(done and DoneMilestoneEntry_layout or MilestoneEntry_layout, {
				milestone_def = v,
				reg_item_id = v.id,
				reg_icon = v.icon,
				title = v.title,
				details = v.details,
				star1 = count >= v.levels[1] and "icon_achieved" or "icon_achieve",
				star2 = count >= v.levels[2] and "icon_achieved" or "icon_achieve",
				star3 = count >= v.levels[3] and "icon_achieved" or "icon_achieve",
				tooltip1 = L("Reach %d", v.levels[1]),
				tooltip2 = L("Reach %d", v.levels[2]),
				tooltip3 = L("Reach %d", v.levels[3]),
				nextlevel = nextlevel,
				progress = count / nextlevel,
				steps = string.format("%d / %d", count, nextlevel),
			})
		end
	end
end

function ResyncedProgressView:update()
	-- flash
	if self.hl then
		if (self.hl % 2) == 0 then self.highlight.bg = "popup_additional_bg"
		else self.highlight.bg = nil
		end
		self.hl = self.hl + 1
		if self.hl == 8 then self.hl = nil end
	end
	local faction = Game.GetLocalPlayerFaction()
	local counters = faction.extra_data.counters
	for _,w in ipairs(self.listinprogress) do
		local goal_def, num, total = w.goal_def
		if goal_def then
			local res = goal_def.goal_check(faction)
			total = goal_def.steps or 1
			num = type(res) == "number" and res or not res and 0 or total
		else
			num, total = GetMilestone(w.milestone_def, faction, counters), w.nextlevel
		end

		if num >= total then
			self:Refresh()
			return
		end
		w.progress = num / total
		w.steps = string.format("%d / %d", num, total)
	end
end

function ResyncedProgressView:on_click_goal_toggle(w)
	local extra = Game.GetLocalPlayerExtra()
	if not extra.hidden_goals then extra.hidden_goals = {} end
	local new_hidden = not extra.hidden_goals[w.goal_def.id]
	extra.hidden_goals[w.goal_def.id] = new_hidden
	w.checkactive = not new_hidden
	w.checkicon = new_hidden and "icon_small_empty" or "icon_small_confirm"

	if ProgressNotificationsOpen then
		ProgressNotificationsOpen:set_goal_visibility(w.goal_def.id, not new_hidden)
	end
end

function ResyncedProgressView:on_click_goal_info(w)
	ResyncedOpenMainWindow("Codex", { param = w.goal_def.id })
end



local ResyncedProgressNotify_layout<const> = [[
	<Box bg=popup_additional_bg on_click={on_click_goal} padding=4 width=252 margin_right=2 margin_bottom=2 >
		<HorizontalList>
			<Canvas width=32 height=32 child_fill=true valign=center >
				<Image image=item_default />
				<Image image={goalicon} margin=1 hide_no_image=true />
				<Text id=check text="✓" size=28 hidden=true />
			</Canvas>
			<VerticalList fill=true margin_left=4 >
				<Text text={title} size=10 fill=true valign=center y=-2 />
				<HorizontalList height=16 >
					<Progress id=bar fill=true color=ui_light />
					<Text id=txt textalign=center size=10 y=-1 margin_left=4 />
				</HorizontalList>
			</VerticalList>
		</HorizontalList>
	</Box>
]]

local active_goals<const> = {}
local ProgressCheckCount = 0
local ResyncedProgressNotifications<const> = {}
UI.Register("ResyncedProgressNotifications", "<VerticalList child_padding=2/>", ResyncedProgressNotifications)

function ResyncedProgressNotifications:construct()
	ResyncedProgressNotificationsOpen = self
	self:refresh(Game.GetLocalPlayerFaction())
end

function ResyncedProgressNotifications:refresh(faction)
	for _,w in ipairs(self) do self:close(w) end
	while #active_goals > 0 do active_goals[#active_goals] = nil end
	if not faction then return end

	local hidden_goals = Game.GetLocalPlayerExtra().hidden_goals or {}
	for id, def in pairs(data.codex) do
		if def.goal_check and faction:IsUnlocked(id) and not IsGoalDone(def, faction) then
			active_goals[#active_goals+1] = id
			if not self[id] and not IsGoalHidden(def, hidden_goals) then
				self:add_entry(id)
			end
		end
	end

	local counters = faction.extra_data.counters
	for _,v in ipairs(milestones_db) do
		v.last_value = GetMilestone(v, faction, counters)
	end
end

function ResyncedProgressNotifications:every_frame_update()
-- function ResyncedProgressNotifications:update()
	local faction = Game.GetLocalPlayerFaction()
	local n = ProgressCheckCount
	ProgressCheckCount = ProgressCheckCount + 1

	local active_goal_idx = (#active_goals > 0) and (1 + (n % #active_goals))
	local check_goal_id = active_goals[active_goal_idx]
	local check_goal_def = data.codex[check_goal_id]
	if check_goal_def then
		local total, res = check_goal_def.steps or 1, check_goal_def.goal_check(faction)
		local num = type(res) == "number" and res or not res and 0 or total
		local w = self[check_goal_id]
		if w then
			w.bar.progress = num / total
			w.txt.text = string.format("%d/%d", num, total)
		end
		if num >= total then
			-- if w then
				-- w.goalicon = nil
				-- w.check.hidden = false
				-- w.check:TweenFromTo("sx",      0, 1, 1000, "OutBack")
				-- w.check:TweenFromTo("sy",      0, 1, 1000, "OutBack")
				-- w.check:TweenFromTo("angle", 180, 0, 1000, 500, "OutBack", function() self:close(w) end)
			-- end
			-- ShowProgressPopup(check_goal_def)
			table.remove(active_goals, active_goal_idx)
		end
	end

	local counters = faction.extra_data.counters
	local check_milestone_idx = (1 + (n % #milestones_db))
	local check_milestone = milestones_db[check_milestone_idx]
	if check_milestone then
		local count, show = GetMilestone(milestones_db[check_milestone_idx], faction, counters)
		local old_count = check_milestone.last_value or 0
		if show and count ~= old_count then
			check_milestone.last_value = count
			for i,v in ipairs(check_milestone.levels) do
				if old_count < v and count >= v then
					ShowProgressPopup(nil, check_milestone, v)
					break
				end
			end
		end
	end
end

function ResyncedProgressNotifications:add_entry(id)
	local insert_index, def, vl, layout = 1, data.codex[id]
	if not def.goal_check then error() end
	if def.index then
		local faction = Game.GetLocalPlayerFaction()
		for i,w in ipairs(self) do
			if (w.def and w.def.index and w.def.index < def.index) or IsGoalDone(w.def, faction) then
				insert_index = i + 1
			end
		end
	end
	local w = self:Add(ResyncedProgressNotify_layout, {
		id = id,
		def = def,
		title = def.title,
		details = def.details,
		tooltip = L("<hl>%s</>\n%s\n\n%s", def.title, def.details or "", "Click for more details"),
		goalicon = def.goalicon,
	})
	-- print( w )
	w.child_index = insert_index
	self:update_visibilities()
	-- w:TweenFromTo("sx", 0, 1, 150)
	-- w:TweenFromTo("x", w.width, 0, 150)
	self[id] = w
end

function ResyncedProgressNotifications:update_visibilities()
	for i,w in ipairs(self) do
		w.hidden = i > 3
	end
end

function ResyncedProgressNotifications:close(w)
	if not w.on_click then return end
	self[w.id] = nil
	w.on_click = nil
	w:TweenTo("sx", 0, 150)
	w:TweenTo("x", w.width, 150, function()
		w:RemoveFromParent()
		self:update_visibilities()
	end)
end

function ResyncedProgressNotifications:on_click_goal(w, mousebtn)
	-- print( w, mousebtn )
	-- if w.check.hidden and mousebtn == "LEFTMOUSEBUTTON" then
		--OpenMainWindow("Codex", { param = w.id })
		ResyncedOpenMainWindow("ResyncedProgressView", { param = w.id })
	-- end
end

function ResyncedProgressNotifications:set_goal_visibility(id, show)
	for _,w in ipairs(self) do
		if w.id == id then
			self:close(w)
		end
	end
	if show then
		self:add_entry(id)
	end
end