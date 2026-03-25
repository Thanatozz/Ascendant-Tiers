if not GetOptionValue( "resynced", "custom_ui" ) then return end

-- Tech notification
-- local ResyncedResyncedTechNotify_layout<const> = [[
	-- <Canvas hidden=true >
		-- <Box bg=popup_additional_bg on_click={on_click_tech} padding=4 width=254 >
			-- <HorizontalList>
				-- <Image id=techimg width=32 height=32 blocking=false />
				-- <VerticalList fill=true margin_left=4>
					-- <Text id=techname size=10 wrap=true wrapsize=160 fill=true valign=center y=-2/>
					-- <ProgressDualPip id=progress height=16 color=ui_light/>
				-- </VerticalList>
			-- </HorizontalList>
		-- </Box>
	-- </Canvas>
-- ]]

local ResyncedResyncedTechNotify_layout<const> = [[
	<Box bg=popup_additional_bg on_click={on_click_tech} padding=4 width=252 margin_right=2 margin_bottom=2 >
		<HorizontalList>
			<Canvas>
				<Image image=item_default width=32 height=32 />
				<Image id=techimg width=32 height=32 blocking=false />
			</Canvas>
			<VerticalList fill=true margin_left=4>
				<Text id=techname size=10 wrap=true wrapsize=160 fill=true valign=center y=-2/>
				<ProgressDualPip id=progress height=16 color=ui_light/>
			</VerticalList>
		</HorizontalList>
	</Box>
]]

local ResyncedTechNotify = {}
UI.Register("ResyncedTechNotify", ResyncedResyncedTechNotify_layout, ResyncedTechNotify)

function ResyncedTechNotify:on_click_tech()
	OpenMainWindow("Tech", { param = self.tech_id })
end

local function GetTechProgress(faction, research_progress, uplinks, def)
	if not def then return end
	local id, progress_count = def.id, def.progress_count
	local is_unlocked = faction:IsUnlocked(id)
	local progress = (is_unlocked and progress_count) or (research_progress and research_progress[id]) or 0
	local progress_fine = progress
	if not is_unlocked then
		for _,uplink in ipairs(uplinks) do
			if uplink:GetRegisterId(1) == id then
				progress_fine = progress_fine + math.max(uplink.interpolated_progress, 0.0)
			end
		end
	end
	return progress/progress_count, progress_fine/progress_count
end

function ResyncedTechNotify:update(first_update)
	local faction = Game.GetLocalPlayerFaction()
	if not faction:IsUnlocked("t_assembly") then
		self.hidden = true
		return
	end
	if self.hidden then
		self.hidden = false
		first_update = true
	end
	local faction_data = faction.extra_data
	local research_queue = faction_data.research_queue
	local tech_id = research_queue and research_queue[1]
	local tech_def = data.techs[tech_id]

	if not tech_def then tech_id = nil end

	if first_update or self.tech_id ~= tech_id then
		self.tech_id = tech_id
		if not tech_id then
			self.techname.text = "No Active Research"
			self.techimg.image = "Main/textures/skins/notification_research.png"
			self.techimg.tooltip = "No Active Research"
			self.progress.hidden = true
			return
		end

		self.techname.text = tech_def.name
		self.techimg.image = tech_def.texture
		self.techimg.tooltip = DefinitionTooltip(tech_def)
		self.progress.hidden = false
		self.progress.pips = tech_def.progress_count
	end

	if tech_id then
		local research_progress = faction_data.research_progress
		local uplinks = Game.GetLocalPlayerFaction():GetComponents("c_uplink", true)
		local progress, progress_fine = GetTechProgress(faction, research_progress, uplinks, tech_def)
		self.progress.progress, self.progress.darkprogress = progress, progress_fine
	end
end

