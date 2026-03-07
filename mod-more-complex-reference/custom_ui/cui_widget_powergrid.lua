if not GetOptionValue( "resynced", "custom_ui" ) then return end

local WidgetPowerGrid = {}
UI.Register( "WidgetPowerGrid", [[
	<Box bg=no_background padding=4 margin_top=-4 margin_right=-4 >
		<Canvas tooltip={power_tooltip} >
			<Image image=item_default width=104 height=18 />
			<Image id=powerimg image=icon_small_energy color=ui_light height=16 width=16 y=1 />
			<Text margin_right=3 y=1 id=powerusage halign=right size=10 />
			<Progress halign=fill margin_top=20 height=12 id=powerprogress color=ui_light />
			<Image halign=fill margin=2 margin_top=22 height=8 id=powerexcess color=ui_light image=progress_mask />
		</Canvas>
	</Box>
]], WidgetPowerGrid )
	
local function GetFilteredLocalPowerGrid()
	local filter_grid_index = Faction_PowerGridFilterIndex()
	return filter_grid_index and Game.GetLocalPlayerFaction():GetPowerGrid(filter_grid_index)
end

function WidgetPowerGrid:construct()
	-- print( self )
	self.on_click = function() ResyncedOpenMainWindow("Faction", { show_tab = "power" }) end
end

function WidgetPowerGrid:power_tooltip()
	return UI.New("<Box bg=popup_box_bg padding=12 blur=true><VerticalList width=300/></Box>", {
		update = function(tt)
			local faction = Game.GetLocalPlayerFaction()
			local grids = faction:GetPowerGrids()
			local list = tt[1]
			list:Clear()

			if #grids == 0 then
				list:Add('<Text text="No Power Grid" textalign=center color=red/>')
				return
			end

			local sum_unused, sum_efficiency, num_grids = 0, 0.0, 0
			for i,grid in ipairs(grids) do
				if grid.total > 0 or grid.received > 0 or grid.load > 0 or grid.unused > 0 then
					sum_unused = sum_unused + grid.unused
					sum_efficiency = sum_efficiency + math.min(1, grid.available / math.max(grid.load, 1))
					num_grids = num_grids + 1
				end
			end

			local function add_entry(title, val)
				list:Add("<Canvas><Text text={title}/><Text text={val} color=title halign=right/></Canvas>", { title = title, val = val })
			end

			local local_grid = GetFilteredLocalPowerGrid()
			if local_grid then
				local gtotal, greceived, gload, gunused = local_grid.total, local_grid.received, local_grid.load, local_grid.unused
				list:Add('<Text text="Local Power Grid" textalign=center color=ui_light/>')
				add_entry("Generated",    string.format("+%d", gtotal*TICKS_PER_SECOND))
				if greceived > 0 then
					add_entry("Received", string.format("+%d", greceived*TICKS_PER_SECOND ))
				end
				add_entry("Load",         string.format("-%d", gload*TICKS_PER_SECOND))
				local charge_or_transmit = local_grid.available - gload - gunused
				if charge_or_transmit > 0 then
					add_entry("Batteries/Transmitters", string.format("-%d", charge_or_transmit*TICKS_PER_SECOND))
				end
				add_entry("Unused",       string.format("%d", gunused*TICKS_PER_SECOND))
				add_entry("Efficiency",   string.format("%d%%", local_grid.efficiency))
				list:Add('<Image height=2 color=ui_light margin=12/>')
			end

			local pwr = faction:GetPowerHistory(1, 1)
			add_entry("Total Generated", string.format("+%d", pwr.total_produced * TICKS_PER_SECOND))
			add_entry("Total Load", string.format("-%d", pwr.total_consumed * TICKS_PER_SECOND))
			add_entry("Total Unused", string.format("%d", sum_unused * TICKS_PER_SECOND))
			add_entry("Average Efficiency", string.format("%.0f%%", sum_efficiency * 100.0 / (num_grids or 1)))

			list:Add('<Image height=2 color=ui_light margin=12/>')
			list:Add('<Text text="Largest Power Grids" textalign=center color=ui_light/>')
			table.sort(grids, function (a,b) return a.available > b.available end)
			for i=1,math.min(#grids, 3) do
				local grid = grids[i]
				local gtotal, greceived, gload, gunused = grid.total, grid.received, grid.load, grid.unused
				if gtotal > 0 or greceived > 0 or gload > 0 or gunused > 0 then
					list:Add('<Image height=2 color=ui_light margin=12/>')
					if gtotal > 0 then
						add_entry("Generated",  string.format("+%d", gtotal*TICKS_PER_SECOND))
					end
					if greceived > 0 then
						add_entry("Received",   string.format("+%d", greceived*TICKS_PER_SECOND ))
					end
					if gload > 0 then
						add_entry("Load",       string.format("-%d", gload*TICKS_PER_SECOND))
					end
					local charge_or_transmit = grid.available - gload - gunused
					if charge_or_transmit > 0 then
						add_entry("Batteries/Transmitters", string.format("-%d", charge_or_transmit*TICKS_PER_SECOND))
					end
					if gunused > 0 then
						add_entry("Unused",     string.format("%d", gunused*TICKS_PER_SECOND))
					end
					add_entry("Efficiency",     string.format("%d%%", grid.efficiency))
				end
			end
		end,
	})
end

function WidgetPowerGrid:show_power()
	ResyncedOpenMainWindow("Faction", { show_tab = "power" })
end

function WidgetPowerGrid:update()
	local faction = Game.GetLocalPlayerFaction()
	local local_grid, power_produced, power_required = GetFilteredLocalPowerGrid()

	local sum_unused, sum_efficiency = 0, 0.0

	if local_grid == false then -- false means show global grid, nil means no local power grid found
		local pwr = faction:GetPowerHistory(1, 1)
		power_produced = pwr.total_produced
		power_required = pwr.total_consumed

		local grids = faction:GetPowerGrids()
		local num_grids = 0
		for _,grid in ipairs(grids or {}) do
			if grid.total > 0 or grid.received > 0 or grid.load > 0 or grid.unused > 0 then
				sum_unused = sum_unused + grid.unused
				sum_efficiency = sum_efficiency + math.min(1, grid.available / math.max(grid.load, 1))
				num_grids = num_grids + 1
			end
		end
		sum_efficiency = sum_efficiency * 100.0 / (num_grids or 1)
	else
		power_produced = local_grid and ((local_grid.total or 0) + (local_grid.received or 0)) or 0
		power_required = local_grid and local_grid.load or 0
		sum_efficiency = local_grid and local_grid.efficiency or 0
	end
	local ratio = math.min(power_produced, power_required) / math.max(power_produced, power_required, 0.1)
	local power_usage = math.ceil(( power_produced - power_required ) * TICKS_PER_SECOND )
	-- self.produced.text = "+"..math.ceil(power_produced*TICKS_PER_SECOND)
	-- self.required.text = "-"..math.ceil(power_required*TICKS_PER_SECOND)
	self.powerusage.text = power_usage >= 0 and "+" .. power_usage or "-" .. power_usage
	self.powerprogress.progress = ratio
	self.powerexcess.hidden = math.ceil(power_produced) <= math.ceil(power_required)

	--string.format("%.0f%%", all_eff)
	self.powerimg.color = sum_efficiency < 50 and "red" or (sum_efficiency < 100 and "yellow") or "ui_light"
	if power_produced > power_required then
		self.powerprogress.color = "ui_light"
	else
		self.powerprogress.color = self.powerimg.color
	end
end