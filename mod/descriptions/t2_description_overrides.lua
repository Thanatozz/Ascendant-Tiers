local function ticks_per_second()
	local constants = rawget(_G, "const")
	if type(constants) == "table" and type(constants.TICKS_PER_SECOND) == "number" and constants.TICKS_PER_SECOND > 0 then
		return constants.TICKS_PER_SECOND
	end
	return 1
end

local function rounded(value)
	return math.floor(value + 0.5)
end

local function format_int(value)
	local sign = ""
	if value < 0 then
		sign = "-"
		value = math.abs(value)
	end
	local digits = tostring(rounded(value))
	local formatted = digits:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
	return sign .. formatted
end

local function format_number(value)
	if type(value) ~= "number" then
		return tostring(value or 0)
	end

	if math.abs(value - math.floor(value)) < 0.001 then
		return format_int(value)
	end

	local text = string.format("%.1f", value)
	return text:gsub("%.0$", "")
end

local function first_field(component, fields)
	if type(component) ~= "table" then
		return 0
	end
	for _, field in ipairs(fields) do
		local value = component[field]
		if type(value) == "number" and value > 0 then
			return value
		end
	end
	return 0
end

local function per_second(value)
	return value * ticks_per_second()
end

-- Fallback used when no assembler/reassembler multiplier can be detected from data.
local default_reassembly_energy_multiplier = 5
local cached_reassembly_energy_multiplier

local function normalize_multiplier(raw_value)
	if type(raw_value) ~= "number" or raw_value <= 0 then
		return nil
	end

	if raw_value > 20 then
		return raw_value / 100
	end

	if raw_value > 1 then
		return raw_value
	end

	if raw_value < 1 then
		return 1 + raw_value
	end

	return 1
end

local function read_multiplier_fields(entry)
	if type(entry) ~= "table" then
		return nil
	end

	local fields = {
		"component_boost",
		"energy_multiplier",
		"power_multiplier",
		"production_multiplier",
		"component_multiplier",
	}

	for _, field in ipairs(fields) do
		local parsed = normalize_multiplier(entry[field])
		if parsed and parsed > 1 then
			return parsed
		end
	end

	return nil
end

local function detect_reassembly_energy_multiplier()
	local best_multiplier

	local function consider_entry(entry)
		local parsed = read_multiplier_fields(entry)
		if parsed and parsed > 1 and (not best_multiplier or parsed > best_multiplier) then
			best_multiplier = parsed
		end
	end

	local direct_component_ids = { "c_assembler", "c_reassembler" }
	local direct_frame_ids = { "f_assembler", "f_reassembler" }

	for _, component_id in ipairs(direct_component_ids) do
		consider_entry(data.components and data.components[component_id])
	end

	for _, frame_id in ipairs(direct_frame_ids) do
		consider_entry(data.frames and data.frames[frame_id])
	end

	for id, component_def in pairs(data.components or {}) do
		if type(id) == "string" and (id:find("assembler", 1, true) or id:find("reassem", 1, true)) then
			consider_entry(component_def)
		end
	end

	for id, frame_def in pairs(data.frames or {}) do
		if type(id) == "string" and (id:find("assembler", 1, true) or id:find("reassem", 1, true)) then
			consider_entry(frame_def)
		end
	end

	return best_multiplier
end

local function reassembly_energy_multiplier()
	local configured = data.ascendant_tiers_reassembly_energy_multiplier
	if type(configured) == "number" and configured > 0 then
		return configured
	end

	if type(cached_reassembly_energy_multiplier) == "number" and cached_reassembly_energy_multiplier > 0 then
		return cached_reassembly_energy_multiplier
	end

	cached_reassembly_energy_multiplier = detect_reassembly_energy_multiplier() or default_reassembly_energy_multiplier
	return cached_reassembly_energy_multiplier
end

local function effective_power_per_second(value)
	return per_second(value) * reassembly_energy_multiplier()
end

local function relay_radius(component)
	return first_field(component, { "transfer_radius", "range", "power_range", "relay_range", "field_radius", "radius" })
end

local function battery_capacity(component)
	return first_field(component, { "power_storage", "power_capacity" })
end

local function storage_slots(frame_def)
	if type(frame_def) ~= "table" or type(frame_def.slots) ~= "table" then
		return 0
	end
	local value = frame_def.slots.storage
	if type(value) == "number" and value > 0 then
		return value
	end
	return 0
end

local function battery_desc(component, label)
	local capacity = battery_capacity(component)
	if capacity > 0 then
		return string.format("<hl>[T2]</> %s that stores up to <hl>%s</> power.", label, format_number(capacity))
	end
	return string.format("<hl>[T2]</> %s with improved storage capacity.", label)
end

local function relay_desc(component, label)
	local radius = relay_radius(component)
	if radius > 0 then
		return string.format("<hl>[T2]</> %s extending your power field by <hl>%s</> tiles.", label, format_number(radius))
	end
	return string.format("<hl>[T2]</> %s with extended power field coverage.", label)
end

local desc_overrides = {
	c_solar_cell_t2 = function(component)
		local daylight_output = effective_power_per_second(first_field(component, { "solar_power_generated", "power" }))
		local summer_output = effective_power_per_second(first_field(component, { "solar_power_summer" }))
		if summer_output > 0 then
			return string.format(
				"<hl>[T2]</> Photovoltaic cell that supplies <hl>%s</> power to your grid during daylight, with increased output up to <hl>%s</> throughout summer.",
				format_number(daylight_output),
				format_number(summer_output)
			)
		end
		return string.format(
			"<hl>[T2]</> Photovoltaic cell that supplies <hl>%s</> power to your grid during daylight.",
			format_number(daylight_output)
		)
	end,

	c_solar_panel_t2 = function(component)
		local daylight_output = effective_power_per_second(first_field(component, { "solar_power_generated", "power" }))
		local summer_output = effective_power_per_second(first_field(component, { "solar_power_summer" }))
		if summer_output > 0 then
			return string.format(
				"<hl>[T2]</> Advanced photovoltaic panel that delivers <hl>%s</> daytime power and up to <hl>%s</> during summer peaks.",
				format_number(daylight_output),
				format_number(summer_output)
			)
		end
		return string.format(
			"<hl>[T2]</> Advanced photovoltaic panel that delivers <hl>%s</> daytime power.",
			format_number(daylight_output)
		)
	end,

	c_wind_turbine_t2 = function(component)
		local base_output = effective_power_per_second(first_field(component, { "power" }))
		local peak_output = effective_power_per_second(first_field(component, { "max_power" }))
		if peak_output > 0 then
			return string.format(
				"<hl>[T2]</> Wind turbine that generates up to <hl>%s</> power (base output <hl>%s</>) depending on wind conditions.",
				format_number(peak_output),
				format_number(base_output)
			)
		end
		return string.format(
			"<hl>[T2]</> Wind turbine that generates <hl>%s</> power.",
			format_number(base_output)
		)
	end,

	c_wind_turbine_l_t2 = function(component)
		local base_output = effective_power_per_second(first_field(component, { "power" }))
		local peak_output = effective_power_per_second(first_field(component, { "max_power" }))
		if peak_output > 0 then
			return string.format(
				"<hl>[T2]</> Large wind turbine with base output <hl>%s</> and peak output <hl>%s</> power.",
				format_number(base_output),
				format_number(peak_output)
			)
		end
		return string.format(
			"<hl>[T2]</> Large wind turbine that generates <hl>%s</> power.",
			format_number(base_output)
		)
	end,

	c_crystal_power_t2 = function(component)
		local storage = battery_capacity(component)
		local power_value = component and component.power or 0
		local generated_power = effective_power_per_second(math.abs(type(power_value) == "number" and power_value or 0))
		if generated_power <= 0 then
			generated_power = effective_power_per_second(first_field(component, { "max_power", "solar_power_generated" }))
		end
		local crystal_drain = per_second(first_field(component, { "drain_rate" }))
		if storage > 0 and generated_power > 0 then
			return string.format(
				"<hl>[T2]</> Crystal reactor that stores up to <hl>%s</> power, outputs up to <hl>%s</>, and consumes <hl>%s</> crystal per second.",
				format_number(storage),
				format_number(generated_power),
				format_number(crystal_drain)
			)
		end
		if storage > 0 then
			return string.format(
				"<hl>[T2]</> Crystal reactor that stores up to <hl>%s</> power while consuming <hl>%s</> crystal per second.",
				format_number(storage),
				format_number(crystal_drain)
			)
		end
		return string.format(
			"<hl>[T2]</> Crystal reactor that converts fuel into <hl>%s</> power while consuming <hl>%s</> crystal per second.",
			format_number(generated_power),
			format_number(crystal_drain)
		)
	end,

	c_small_battery_t2 = function(component)
		return battery_desc(component, "Compact battery module")
	end,

	c_capacitor_t2 = function(component)
		return battery_desc(component, "Rapid capacitor bank")
	end,

	c_medium_capacitor_t2 = function(component)
		return battery_desc(component, "Medium capacitor bank")
	end,

	c_battery_t2 = function(component)
		return battery_desc(component, "High-capacity battery")
	end,

	c_power_cell_t2 = function(component)
		local capacity = battery_capacity(component)
		local output = effective_power_per_second(first_field(component, { "power", "max_power" }))
		if capacity > 0 and output > 0 then
			return string.format(
				"<hl>[T2]</> Hybrid power cell that stores <hl>%s</> power and provides up to <hl>%s</> output.",
				format_number(capacity),
				format_number(output)
			)
		end
		return battery_desc(component, "Hybrid power cell")
	end,

	c_power_core_t2 = function(component)
		local capacity = battery_capacity(component)
		local output = effective_power_per_second(first_field(component, { "power", "max_power" }))
		if capacity > 0 and output > 0 then
			return string.format(
				"<hl>[T2]</> Power core with <hl>%s</> storage and up to <hl>%s</> output.",
				format_number(capacity),
				format_number(output)
			)
		end
		return battery_desc(component, "Power core")
	end,

	c_portable_relay_t2 = function(component)
		return relay_desc(component, "Portable power relay")
	end,

	c_small_relay_t2 = function(component)
		return relay_desc(component, "Small relay node")
	end,

	c_power_relay_t2 = function(component)
		return relay_desc(component, "Power relay")
	end,

	c_power_transmitter_t2 = function(component)
		return relay_desc(component, "Power transmitter")
	end,

	c_large_power_transmitter_t2 = function(component)
		return relay_desc(component, "Large power transmitter")
	end,

	f_storage16_t2 = function(frame_def)
		local slots = storage_slots(frame_def)
		if slots > 0 then
			return string.format("<hl>[T2]</> Storage block with capacity for <hl>%s</> item stacks.", format_number(slots))
		end
		return "<hl>[T2]</> Storage block with expanded capacity."
	end,

	f_storage32_t2 = function(frame_def)
		local slots = storage_slots(frame_def)
		if slots > 0 then
			return string.format("<hl>[T2]</> Storage block with capacity for <hl>%s</> item stacks.", format_number(slots))
		end
		return "<hl>[T2]</> Storage block with expanded capacity."
	end,

	f_storage48_t2 = function(frame_def)
		local slots = storage_slots(frame_def)
		if slots > 0 then
			return string.format("<hl>[T2]</> Storage block with capacity for <hl>%s</> item stacks.", format_number(slots))
		end
		return "<hl>[T2]</> Storage block with expanded capacity."
	end,
}

local merged = data.ascendant_tiers_t2_description_overrides or {}
for item_id, override in pairs(desc_overrides) do
	merged[item_id] = override
end

data.ascendant_tiers_t2_description_overrides = merged
