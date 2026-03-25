local ASCENDANT_TIERS_TECH_ID<const> = "tech_ascendant_tiers_start"
local ASCENDANT_TIERS_SETTINGS_KEY<const> = "ascendant_tiers"
local EARLY_PORTABLE_CRANE_OPTION_ID<const> = "enable_early_portable_crane"
local LEGACY_OPTION_FALLBACKS<const> = {
	t2_material_craft_time_pct = "t2_material_craft_speed_pct",
}

local GROUP_LABELS<const> = {
	buildings = "ascendant.option.group.buildings",
	robots = "ascendant.option.group.robots",
	components = "ascendant.option.group.components",
	materials = "ascendant.option.group.materials",
}

local COMPONENT_STAT_MODE_OPTION<const> = {
	id = "t2_component_stat_mode",
	label = "ascendant.option.component_stat_mode.label",
	texts = {
		"ascendant.option.component_stat_mode.global",
		"ascendant.option.component_stat_mode.per_stat",
	},
	default = 1,
}

local COMPONENT_STAT_PER_FIELD_OPTIONS<const> = {
	{ id = "t2_component_stat_repair_pct", label = "ascendant.option.stat.repair", default = 200, category = "ascendant.option.category.general" },
	{ id = "t2_component_stat_trigger_radius_pct", label = "ascendant.option.stat.trigger_radius", default = 200, category = "ascendant.option.category.general" },
	{ id = "t2_component_stat_storage_slots_pct", label = "ascendant.option.stat.storage_slots", default = 200, category = "ascendant.option.category.general" },
	{ id = "t2_component_stat_shield_max_pct", label = "ascendant.option.stat.shield_max_charge", default = 200, category = "ascendant.option.category.defensive" },
	{ id = "t2_component_stat_damage_pct", label = "ascendant.option.stat.damage_dot", default = 200, category = "ascendant.option.category.offensive" },
	{ id = "t2_component_stat_attack_radius_pct", label = "ascendant.option.stat.damage_range", default = 100, category = "ascendant.option.category.offensive" },
	{ id = "t2_component_stat_duration_pct", label = "ascendant.option.stat.effect_duration", default = 100, category = "ascendant.option.category.offensive" },
	{ id = "t2_component_stat_shoot_speed_pct", label = "ascendant.option.stat.fire_rate", default = 100, category = "ascendant.option.category.offensive" },
	{ id = "t2_component_stat_damage_air_bonus_pct", label = "ascendant.option.stat.air_damage_bonus", default = 100, category = "ascendant.option.category.offensive" },
	{ id = "t2_component_stat_dothits_pct", label = "ascendant.option.stat.dot_hits", default = 100, category = "ascendant.option.category.offensive" },
	{ id = "t2_component_stat_pulse_pct", label = "ascendant.option.stat.pulse_size", default = 100, category = "ascendant.option.category.offensive" },
	{ id = "t2_component_stat_disruptor_pct", label = "ascendant.option.stat.disruptor_strength", default = 100, category = "ascendant.option.category.offensive" },
	{
		id = "t2_component_stat_power_pct",
		label = "ascendant.option.stat.power_output",
		default = 200,
		category = "ascendant.option.category.utilities",
	},
	{ id = "t2_component_stat_transfer_radius_pct", label = "ascendant.option.stat.utility_range", default = 200, category = "ascendant.option.category.utilities" },
	{ id = "t2_component_stat_bandwidth_pct", label = "ascendant.option.stat.bandwidth", default = 200, category = "ascendant.option.category.utilities" },
	{ id = "t2_component_stat_mining_speed_pct", label = "ascendant.option.stat.mining_speed", default = 200, category = "ascendant.option.category.mining" },
	{ id = "t2_component_stat_mining_efficiency_pct", label = "ascendant.option.stat.mining_efficiency", default = 100, category = "ascendant.option.category.mining" },
}

local T2_MULTIPLIER_OPTIONS<const> = {
	{
		id = "t2_building_recipe_cost_pct",
		group = "buildings",
		label = "ascendant.option.multiplier.t2_building_recipe_cost",
		min = 10,
		max = 1000,
		step = 25,
		default = 100,
	},
	{
		id = "t2_building_health_pct",
		group = "buildings",
		label = "ascendant.option.multiplier.t2_building_health",
		min = 10,
		max = 1000,
		step = 25,
		default = 135,
	},
	{
		id = "t2_building_storage_pct",
		group = "buildings",
		label = "ascendant.option.multiplier.t2_building_storage",
		min = 10,
		max = 1000,
		step = 25,
		default = 200,
	},
	{
		id = "t2_building_slots_pct",
		group = "buildings",
		label = "ascendant.option.multiplier.t2_building_slots",
		min = 10,
		max = 1000,
		step = 25,
		default = 100,
	},
	{
		id = "t2_unit_recipe_cost_pct",
		group = "robots",
		label = "ascendant.option.multiplier.t2_robots_recipe_cost",
		min = 10,
		max = 1000,
		step = 25,
		default = 100,
	},
	{
		id = "t2_unit_health_pct",
		group = "robots",
		label = "ascendant.option.multiplier.t2_robots_health",
		min = 10,
		max = 1000,
		step = 25,
		default = 125,
	},
	{
		id = "t2_unit_inventory_pct",
		group = "robots",
		label = "ascendant.option.multiplier.t2_robots_inventory",
		min = 10,
		max = 1000,
		step = 25,
		default = 200,
	},
	{
		id = "t2_unit_slots_pct",
		group = "robots",
		label = "ascendant.option.multiplier.t2_robots_slots",
		min = 10,
		max = 1000,
		step = 25,
		default = 100,
	},
	{
		id = "t2_unit_speed_pct",
		group = "robots",
		label = "ascendant.option.multiplier.t2_robots_speed",
		min = 10,
		max = 1000,
		step = 25,
		default = 150,
	},
	{
		id = "t2_component_recipe_pct",
		group = "components",
		label = "ascendant.option.multiplier.t2_components_recipe_cost",
		min = 10,
		max = 1000,
		step = 25,
		default = 200,
	},
	{
		id = "t2_component_stats_pct",
		group = "components",
		label = "ascendant.option.multiplier.t2_components_stat_multipliers",
		min = 10,
		max = 1000,
		step = 25,
		default = 200,
	},
	{
		id = "t2_mining_speed_pct",
		group = "components",
		label = "ascendant.option.multiplier.t2_mining_speed",
		min = 10,
		max = 1000,
		step = 25,
		default = 200,
		hide_when_component_per_stat_mode = true,
	},
	{
		id = "t2_tech_cost_pct",
		group = "materials",
		label = "ascendant.option.multiplier.ascendant_research_cost",
		min = 10,
		max = 1000,
		step = 25,
		default = 100,
	},
	{
		id = "t2_material_recipe_cost_pct",
		group = "materials",
		label = "ascendant.option.multiplier.t2_materials_recipe_cost",
		min = 10,
		max = 1000,
		step = 25,
		default = 100,
	},
	{
		id = "t2_material_craft_time_pct",
		group = "materials",
		label = "ascendant.option.multiplier.t2_materials_craft_time",
		min = 10,
		max = 1000,
		step = 25,
		default = 100,
	},
}

for _, option in ipairs(COMPONENT_STAT_PER_FIELD_OPTIONS) do
	local default_from_option_id = nil
	if option.id == "t2_component_stat_mining_speed_pct" then
		default_from_option_id = "t2_mining_speed_pct"
	elseif option.default == 200 then
		default_from_option_id = "t2_component_stats_pct"
	end

	table.insert(T2_MULTIPLIER_OPTIONS, {
		id = option.id,
		group = "components",
		label = option.label,
		min = 10,
		max = 1000,
		step = 25,
		default = option.default,
		default_from_option_id = default_from_option_id,
		is_component_per_stat = true,
		per_stat_category = option.category,
	})
end

local function clamp_number(value, min_value, max_value)
	if value < min_value then
		return min_value
	end
	if value > max_value then
		return max_value
	end
	return value
end

local function is_front_end()
	return Map and type(Map.IsFrontEnd) == "function" and Map.IsFrontEnd()
end

local function get_local_faction()
	if not Game or type(Game.GetLocalPlayerFaction) ~= "function" then
		return nil
	end
	return Game.GetLocalPlayerFaction()
end

local function can_edit_settings()
	return is_front_end()
end

local function get_map_ascendant_settings()
	if not Map or type(Map.GetSettings) ~= "function" then
		return nil
	end
	local settings = Map.GetSettings()
	local mod_settings = settings and settings[ASCENDANT_TIERS_SETTINGS_KEY]
	if type(mod_settings) == "table" then
		return mod_settings
	end
	return nil
end

local function get_profile_ascendant_settings(create_if_missing)
	if not Game or type(Game.GetProfile) ~= "function" then
		return nil
	end

	local profile = Game.GetProfile(nil)
	if type(profile) ~= "table" then
		return nil
	end

	if type(profile.options) ~= "table" then
		if not create_if_missing then
			return nil
		end
		profile.options = {}
	end

	local settings = profile.options[ASCENDANT_TIERS_SETTINGS_KEY]
	if type(settings) ~= "table" then
		if not create_if_missing then
			return nil
		end
		settings = {}
		profile.options[ASCENDANT_TIERS_SETTINGS_KEY] = settings
	end

	return settings
end

local function read_setting_value(option_id)
	local profile_settings = get_profile_ascendant_settings(false)
	local map_settings = get_map_ascendant_settings()
	local legacy_option_id = LEGACY_OPTION_FALLBACKS[option_id]

	local function read_from_settings(settings_table)
		if not settings_table then
			return nil
		end
		if settings_table[option_id] ~= nil then
			return settings_table[option_id]
		end
		if legacy_option_id and settings_table[legacy_option_id] ~= nil then
			return settings_table[legacy_option_id]
		end
		return nil
	end

	if is_front_end() then
		local profile_value = read_from_settings(profile_settings)
		if profile_value ~= nil then
			return profile_value
		end
		return read_from_settings(map_settings)
	end

	local map_value = read_from_settings(map_settings)
	if map_value ~= nil then
		return map_value
	end

	return read_from_settings(profile_settings)
end

local function write_profile_setting(option_id, value)
	local profile_settings = get_profile_ascendant_settings(true)
	if not profile_settings then
		return false
	end

	profile_settings[option_id] = value
	return true
end

local function clear_profile_settings()
	if not Game or type(Game.GetProfile) ~= "function" then
		return false
	end

	local profile = Game.GetProfile(nil)
	if type(profile) ~= "table" then
		return false
	end

	if type(profile.options) ~= "table" then
		return true
	end

	profile.options[ASCENDANT_TIERS_SETTINGS_KEY] = nil
	return true
end

local function read_option_percent(option_def)
	local value = read_setting_value(option_def.id)
	local numeric = tonumber(value)
	if not numeric and option_def.default_from_option_id then
		local fallback_value = read_setting_value(option_def.default_from_option_id)
		numeric = tonumber(fallback_value)
	end
	if not numeric then
		numeric = option_def.default
	end
	local rounded = math.floor(numeric + 0.5)
	return clamp_number(rounded, option_def.min, option_def.max)
end

local function read_combo_index(option_def)
	local value = read_setting_value(option_def.id)
	local numeric = tonumber(value)
	if not numeric then
		numeric = option_def.default
	end
	local rounded = math.floor(numeric + 0.5)
	return clamp_number(rounded, 1, #option_def.texts)
end

local function read_bool_setting(option_id, default_value)
	local value = read_setting_value(option_id)
	if value == nil then
		return default_value
	end

	if type(value) == "boolean" then
		return value
	end
	if type(value) == "number" then
		return value ~= 0
	end
	if type(value) == "string" then
		local lowered = string.lower(value)
		return lowered == "true" or lowered == "1" or lowered == "yes" or lowered == "on"
	end

	return default_value
end

local layout<const> =
[[
	<VerticalList child_padding=8 fill=true>
		<Text style=header text="ascendant.option.title"/>
		<Box bg=card_box_bg padding=8 blur=true>
			<VerticalList child_padding=6>
				<Text id=context_hint wrap=true/>
				<Image id=portable_divider height=1 color=ui_dark/>
				<HorizontalList child_align=center child_padding=8 fill=true>
					<Text text="ascendant.option.portable_prototype" fill=true color=ui_light/>
					<CheckBox id=crane_toggle on_change={on_crane_toggle_changed}/>
				</HorizontalList>
				<Text id=crane_hint size=10 wrap=true/>
				<Image id=legacy_divider height=1 color=ui_dark/>
				<Text id=legacy_title text="ascendant.option.legacy_save_unlock" color=ui_light/>
				<Text id=status wrap=true/>
				<Button id=unlock_btn on_click={on_unlock_click} width=280/>
				<Text id=unlock_frontend_note size=10 wrap=true hidden=true/>
				<Image id=save_divider height=1 color=ui_dark hidden=true/>
				<Button id=save_settings_btn on_click={on_save_settings_click} width=280 hidden=true/>
				<Text id=save_settings_hint size=10 wrap=true hidden=true/>
				<Image id=reset_divider height=1 color=ui_dark/>
				<Button id=reset_settings_btn on_click={on_reset_settings_click} width=280/>
				<Text id=reset_settings_hint size=10 wrap=true/>
			</VerticalList>
		</Box>
		<Box bg=popup_additional_bg padding=8 fill=true blur=true>
			<VerticalList child_padding=7 fill=true>
				<Text text="ascendant.option.balance_settings" color=ui_light/>
				<Text text="ascendant.option.main_menu_only" size=10 wrap=true/>
				<Image height=1 color=ui_dark/>
				<ScrollList id=t2_options_list child_padding=10 fill=true/>
			</VerticalList>
		</Box>
	</VerticalList>
]]

AscendantTiersOptions = AscendantTiersOptions or {}
if not UI.IsRegistered("AscendantTiersOptions") then
	UI.Register("AscendantTiersOptions", layout, AscendantTiersOptions)
end

local option_group_header_layout<const> =
[[
	<VerticalList child_padding=2 margin_top=12 margin_bottom=6>
		<Text id=label color=ui_light/>
	</VerticalList>
]]

local option_row_layout<const> =
[[
	<VerticalList child_padding=8 margin_bottom=4>
		<HorizontalList child_align=center child_padding=8 fill=true>
			<Text id=label fill=true size=11 wrap=true/>
			<Text id=value width=56 textalign=right color=ui_light size=11/>
		</HorizontalList>
		<HorizontalList child_align=center child_padding=8 fill=true margin_left=2 margin_right=2>
			<Button id=minus icon=icon_minus width=26 height=26/>
			<Slider id=slider height=30 fill=true/>
			<Button id=plus icon=icon_add width=26 height=26/>
		</HorizontalList>
		<Image height=1 color=ui_dark/>
	</VerticalList>
]]

local combo_row_layout<const> =
[[
	<VerticalList child_padding=8 margin_bottom=4>
		<HorizontalList child_align=center child_padding=8 fill=true>
			<Text id=label fill=true size=11 wrap=true/>
			<Combo id=combo width=240/>
		</HorizontalList>
		<Image height=1 color=ui_dark/>
	</VerticalList>
]]

function AscendantTiersOptions:apply_row_visual_state(row, option_def, percent, enabled)
	row.label.text = option_def.label
	row.slider.min = option_def.min
	row.slider.max = option_def.max
	row.slider.step = option_def.step
	if row.slider.value ~= percent then
		row.is_syncing = true
		row.slider.value = percent
		row.is_syncing = false
	end
	row.value.text = string.format("%d%%", percent)

	row.label.disabled = not enabled
	row.minus.disabled = not enabled
	row.slider.disabled = not enabled
	row.plus.disabled = not enabled
	row.value.disabled = not enabled
end

function AscendantTiersOptions:apply_combo_row_visual_state(row, option_def, value, enabled)
	row.label.text = option_def.label
	row.combo.texts = option_def.texts
	if row.combo.value ~= value then
		row.is_syncing = true
		row.combo.value = value
		row.is_syncing = false
	end
	row.label.disabled = not enabled
	row.combo.disabled = not enabled
end

function AscendantTiersOptions:send_option_update(option_def, percent)
	if not is_front_end() then
		return
	end

	local value = clamp_number(percent, option_def.min, option_def.max)
	write_profile_setting(option_def.id, value)
end

function AscendantTiersOptions:send_combo_update(option_def, index)
	if not is_front_end() then
		return
	end

	local value = clamp_number(index, 1, #option_def.texts)
	write_profile_setting(option_def.id, value)
end

function AscendantTiersOptions:send_boolean_option_update(option_id, value)
	if not is_front_end() then
		return
	end

	write_profile_setting(option_id, value and true or false)
end

function AscendantTiersOptions:add_group_header(label)
	local widget = self.t2_options_list:Add(option_group_header_layout)
	widget[1].text = label
	return widget
end

function AscendantTiersOptions:add_combo_row(option_def)
	local widget = self.t2_options_list:Add(combo_row_layout)
	local row = {
		root = widget,
		label = widget[1][1],
		combo = widget[1][2],
	}

	row.combo.on_change = function(combo, value)
		if row.is_syncing then
			return
		end
		local selected = tonumber(value) or combo.value or option_def.default
		self:send_combo_update(option_def, selected)
		self:refresh_state()
	end

	return row
end

function AscendantTiersOptions:add_option_row(option_def)
	local widget = self.t2_options_list:Add(option_row_layout)
	local row = {
		root = widget,
		label = widget[1][1],
		value = widget[1][2],
		minus = widget[2][1],
		slider = widget[2][2],
		plus = widget[2][3],
	}
	local slider = row.slider
	local update_label = function()
		row.value.text = string.format("%d%%", math.floor(slider.value + 0.5))
	end

	slider.on_change = function()
		local was_syncing = row.is_syncing
		local percent = clamp_number(math.floor(slider.value + 0.5), option_def.min, option_def.max)
		if not was_syncing and slider.value ~= percent then
			row.is_syncing = true
			slider.value = percent
			row.is_syncing = false
		end
		update_label()
		if was_syncing then
			return
		end
		self:send_option_update(option_def, percent)
	end

	row.minus.on_click = function()
		local value = slider.value - option_def.step
		local percent = clamp_number(math.floor(value + 0.5), option_def.min, option_def.max)
		row.is_syncing = true
		slider.value = percent
		row.is_syncing = false
		update_label()
		self:send_option_update(option_def, percent)
	end

	row.plus.on_click = function()
		local value = slider.value + option_def.step
		local percent = clamp_number(math.floor(value + 0.5), option_def.min, option_def.max)
		row.is_syncing = true
		slider.value = percent
		row.is_syncing = false
		update_label()
		self:send_option_update(option_def, percent)
	end

	return row
end

function AscendantTiersOptions:build_option_rows()
	if self.option_rows then
		return
	end

	self.option_rows = {}
	self.combo_rows = {}
	self.per_stat_section_rows = {}
	local seen_groups = {}
	local component_per_stat_defs = {}
	for _, option_def in ipairs(T2_MULTIPLIER_OPTIONS) do
		if option_def.is_component_per_stat then
			table.insert(component_per_stat_defs, option_def)
		end
	end

	for _, option_def in ipairs(T2_MULTIPLIER_OPTIONS) do
		if not option_def.is_component_per_stat then
			if not seen_groups[option_def.group] then
				self:add_group_header(GROUP_LABELS[option_def.group] or option_def.group)
				seen_groups[option_def.group] = true
			end
			self.option_rows[option_def.id] = self:add_option_row(option_def)
			if option_def.id == "t2_component_stats_pct" then
				self.combo_rows[COMPONENT_STAT_MODE_OPTION.id] = self:add_combo_row(COMPONENT_STAT_MODE_OPTION)
				local active_category = nil
				for _, per_stat_option in ipairs(component_per_stat_defs) do
					local category = per_stat_option.per_stat_category or "ascendant.option.category.general"
					if category ~= active_category then
						local section_header = self:add_group_header(category)
						table.insert(self.per_stat_section_rows, section_header)
						active_category = category
					end
					self.option_rows[per_stat_option.id] = self:add_option_row(per_stat_option)
				end
			end
		end
	end
end

function AscendantTiersOptions:refresh_state()
	local in_front_end = is_front_end()
	local settings_editable = can_edit_settings()

	self.context_hint.hidden = true
	self.context_hint.text = ""

	if in_front_end then
		self.legacy_divider.hidden = true
		self.legacy_title.hidden = true
		self.status.hidden = true
		self.unlock_btn.hidden = true
		self.unlock_frontend_note.text = ""
		self.unlock_frontend_note.hidden = true

		self.save_divider.hidden = false
		self.save_settings_btn.hidden = false
		self.save_settings_btn.text = "ascendant.option.save_settings"
		self.save_settings_btn.disabled = false
		self.save_settings_hint.hidden = true
		self.save_settings_hint.text = ""

		self.reset_divider.hidden = false
		self.reset_settings_btn.hidden = false
		self.reset_settings_btn.text = "ascendant.option.reset_settings"
		self.reset_settings_btn.disabled = false
		self.reset_settings_hint.hidden = false
		self.reset_settings_hint.text = "ascendant.option.reset_hint_frontend"
	else
		self.legacy_divider.hidden = false
		self.legacy_title.hidden = false
		self.status.hidden = false
		self.unlock_btn.hidden = false
		self.unlock_frontend_note.hidden = true

		local faction = get_local_faction()
		if not faction then
			self.status.text = "ascendant.option.status.no_local_faction"
			self.unlock_btn.text = "ascendant.option.unlock.unavailable"
			self.unlock_btn.disabled = true
		else
			local unlocked = faction:IsUnlocked(ASCENDANT_TIERS_TECH_ID)
			self.status.text = unlocked
				and "ascendant.option.status.already_unlocked"
				or "ascendant.option.status.legacy_hint"
			self.unlock_btn.text = unlocked
				and "ascendant.option.unlock.already"
				or "ascendant.option.unlock.action"
			self.unlock_btn.disabled = unlocked
		end

		self.save_divider.hidden = true
		self.save_settings_btn.hidden = true
		self.save_settings_hint.hidden = true
		self.save_settings_hint.text = ""

		self.reset_divider.hidden = false
		self.reset_settings_btn.hidden = false
		self.reset_settings_btn.text = "ascendant.option.reset_settings"
		self.reset_settings_btn.disabled = false
		self.reset_settings_hint.hidden = false
		self.reset_settings_hint.text = "ascendant.option.reset_hint_ingame"
	end

	local crane_enabled = read_bool_setting(EARLY_PORTABLE_CRANE_OPTION_ID, true)
	self.crane_toggle.disabled = not settings_editable
	self.crane_syncing = true
	self.crane_toggle.check = crane_enabled
	self.crane_syncing = false
	self.crane_hint.text = crane_enabled
		and "ascendant.option.crane_hint.enabled"
		or "ascendant.option.crane_hint.disabled"

	local component_stat_mode = read_combo_index(COMPONENT_STAT_MODE_OPTION)
	local component_stat_mode_row = self.combo_rows and self.combo_rows[COMPONENT_STAT_MODE_OPTION.id]
	if component_stat_mode_row then
		self:apply_combo_row_visual_state(
			component_stat_mode_row,
			COMPONENT_STAT_MODE_OPTION,
			component_stat_mode,
			settings_editable
		)
	end
	for _, section_row in ipairs(self.per_stat_section_rows or {}) do
		section_row.hidden = component_stat_mode ~= 2
	end

	for _, option_def in ipairs(T2_MULTIPLIER_OPTIONS) do
		local row = self.option_rows and self.option_rows[option_def.id]
		if row then
			local percent = read_option_percent(option_def)
			local hidden = false
			if option_def.is_component_per_stat then
				hidden = component_stat_mode ~= 2
			elseif option_def.hide_when_component_per_stat_mode then
				hidden = component_stat_mode == 2
			end
			row.root.hidden = hidden
			if not hidden then
				self:apply_row_visual_state(row, option_def, percent, settings_editable)
			end
		end
	end
end

function AscendantTiersOptions:construct()
	self:build_option_rows()
	self:refresh_state()
end

function AscendantTiersOptions:on_crane_toggle_changed(_, value)
	if self.crane_syncing then
		return
	end

	self:send_boolean_option_update(EARLY_PORTABLE_CRANE_OPTION_ID, value and true or false)
	self.crane_hint.text = value
		and "ascendant.option.crane_hint.toggled_enabled"
		or "ascendant.option.crane_hint.toggled_disabled"
end

function AscendantTiersOptions:on_unlock_click()
	if is_front_end() then
		return
	end
	Action.SendForLocalFaction("UnlockAscendantTiersTech")
	self:refresh_state()
end

function AscendantTiersOptions:on_save_settings_click()
	if not is_front_end() then
		return
	end

	write_profile_setting(EARLY_PORTABLE_CRANE_OPTION_ID, read_bool_setting(EARLY_PORTABLE_CRANE_OPTION_ID, true))
	write_profile_setting(COMPONENT_STAT_MODE_OPTION.id, read_combo_index(COMPONENT_STAT_MODE_OPTION))
	for _, option_def in ipairs(T2_MULTIPLIER_OPTIONS) do
		write_profile_setting(option_def.id, read_option_percent(option_def))
	end

	self:refresh_state()
	if Notification and Notification.Info then
		Notification.Info("ascendant.notify.settings_saved")
	end
end

function AscendantTiersOptions:on_reset_settings_click()
	if is_front_end() then
		clear_profile_settings()
		self:refresh_state()
		if Notification and Notification.Info then
			Notification.Info("ascendant.notify.settings_reset")
		end
		return
	end

	local faction = get_local_faction()
	if not faction then
		return
	end

	Action.SendForLocalFaction("ResetAscendantTiersSettings")
	self:refresh_state()
end

return UI.New("AscendantTiersOptions")
