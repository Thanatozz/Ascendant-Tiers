local function clone_table(value)
	if type(value) ~= "table" then return value end
	local copy = {}
	for key, item in pairs(value) do
		copy[key] = clone_table(item)
	end
	return copy
end

local default_balance = {
	materials = {
		map = {
			metalplate = "ascendant_tiers_metal_plate",
			reinforced_plate = "ascendant_tiers_reinforced_plate",
			energized_plate = "ascendant_tiers_energized_plate",
			hdframe = "ascendant_tiers_high_density_frame",
			high_density_frame = "ascendant_tiers_high_density_frame",
			circuit_board = "ascendant_tiers_circuit_board",
			icchip = "ascendant_tiers_ic_chip",
			ic_chip = "ascendant_tiers_ic_chip",
		},
	},
	components = {
		recipe = {
			base_ingredient_multiplier = 2.0,
			overrides = {
				c_miner_t2 = {
					convert_ingredient = {
						from = "metalbar",
						to = "ascendant_tiers_metal_plate",
						multiplier = 1.0,
						mode = "add",
					},
				},
				c_portable_relay_t2 = {
					set_ingredient = {
						item = "ascendant_tiers_metal_plate",
						amount = 5,
					},
					remove_ingredients = {
						"metalbar",
					},
				},
			},
		},
		mining = {
			ticks_divisor = 2.0,
			min_ticks = 1,
		},
		stats = {
			repair = 2.0,
			trigger_radius = 2.0,
			shield_max = 2.0,
			damage = 2.0,
			dotdps = 2.0,
			storage_slots = 2.0,
			power = 2.0,
			drain_rate = 2.0,
			bandwidth = 2.0,
			max_power = 2.0,
			solar_power_generated = 2.0,
			solar_power_summer = 2.0,
			power_storage = 2.0,
			power_capacity = 2.0,
			transfer_radius = 2.0,
			range = 2.0,
			power_range = 2.0,
			relay_range = 2.0,
			field_radius = 2.0,
			radius = 2.0,
		},
	},
	buildings = {
		socket_scale = {
			default = 1.0,
			Internal = 1.5,
			Small = 2.0,
			Medium = 2.0,
			Large = 2.0,
		},
		health_multiplier_default = 1.35,
		storage_multiplier_default = 2.0,
		storage_multiplier_overrides = {
			f_storage16_t2 = 2.0,
			f_storage32_t2 = 2.0,
			f_storage48_t2 = 2.0,
		},
		storage_slot_bonus_overrides = {
			f_building1x1_4s_t2 = 1,
		},
		construction_overrides = {
			f_building1x1_2s_t2 = {
				convert_ingredient = {
					from = "metalbar",
					to = "ascendant_tiers_metal_plate",
					divisor = 2.0,
					minimum = 1,
					mode = "add",
				},
			},
			f_storage16_t2 = {
				convert_ingredient = {
					from = "metalbar",
					to = "ascendant_tiers_metal_plate",
					divisor = 2.0,
					minimum = 1,
					mode = "add",
				},
			},
		},
	},
	units = {
		socket_scale = {
			default = 1.0,
			Internal = 1.5,
			Small = 2.0,
			Medium = 2.0,
			Large = 2.0,
		},
		health_multiplier = 1.25,
		no_sml_inventory_multiplier = 2.0,
		no_sml_speed_multiplier = 1.5,
	},
}

data.ascendant_tiers_t2_balance = clone_table(default_balance)
