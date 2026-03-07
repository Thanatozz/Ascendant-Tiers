local package = ...

-- Addons data and default settings
-- ResyncedAddonOrder = { "resynced", "custom_ui", "overwrite", "global_modifier", "bug_wave", "bug_settings" }
ResyncedAddonOrder = { "resynced", "overwrite", "global_modifier", "bug_wave", "bug_settings" }
ResyncedAddons = {
	resynced = {
		options = {
			{ id = "enabled", type = "button", value = true },
			-- { id = "alien_artifact_recipe", type = "button", value = false },
			{ id = "puzzle_hacker", type = "button", value = false },
			{ type = "separator" },
			{ id = "game_speed", type = "combo", texts = { "", "", "" }, value = 1 },
			{ id = "vote_speed1", type = "hidden", value = false },
			{ id = "vote_speed2", type = "hidden", value = false },
			{ id = "vote_speed3", type = "hidden", value = false },
			{ type = "separator" },
			{ id = "infinite_resource_node", type = "button", value = false },
			{ id = "selected_node_type", type = "combo", texts = { "All", "Only Big Node" }, value = 1 },
			{ id = "node_metal", type = "slider", min = 50, max = 10000, value = 600, step = 50 },
			{ id = "node_crystal", type = "slider", min = 50, max = 10000, value = 600, step = 50 },
			{ id = "node_silica", type = "slider", min = 50, max = 10000, value = 600, step = 50 },
			{ id = "node_laterite", type = "slider", min = 50, max = 10000, value = 600, step = 50 },
			{ id = "node_blightcrystal", type = "slider", min = 50, max = 10000, value = 100, step = 50 },
			{ id = "node_obsidian", type = "slider", min = 50, max = 10000, value = 300, step = 50 },
			{ type = "separator" },
			{ id = "custom_ui", type = "button", value = false },
		}
	},
	-- custom_ui = {
		-- options = {
			-- { id = "cui_", type = "", value = false },
		-- }
	-- },
	overwrite = {
		options = {
			{ id = "alien_artifact_recipe", type = "button", value = false },
			{ id = "unit_chain_teleport", type = "button", value = false },
		}
	},
	global_modifier = {
		options = {
			{ id = "bot_speed", type = "slider", min = 1, max = 10, value = 1, step = 1, text = "Bot Speed" },
			{ type = "separator" },
			{ id = "stack_override", type = "button", value = false },
			{ id = "stack_size", type = "slider", min = 1, max = 100, value = 1, step = 1, text = "Stack Size" },
			{ id = "ore_stack_size", type = "slider", min = 1, max = 10, value = 1, step = 1, text = "Ore Stack Size" },
			{ type = "separator" },
			{ id = "production_speed", type = "slider", min = 1, max = 10, value = 1, step = 1, text = "Production Speed" },
			{ id = "production_multiplier", type = "slider", min = 1, max = 10, value = 1, step = 1, text = "Production Multiplier" },
			{ id = "research_speed", type = "slider", min = 1, max = 10, value = 1, step = 1, text = "Research Speed" },
			{ type = "separator" },
			{ id = "mining_range", type = "slider", min = 0, max = 10, value = 1, step = 1, text = "Mning Range" },
			{ id = "mining_efficiency", type = "slider", min = 1, max = 10, value = 1, step = 1, text = "Mining Efficiency" },
			{ id = "blight_extraction_efficiency", type = "slider", min = 1, max = 50, value = 1, step = 1, text = "Blight Extraction Efficiency" },
			{ type = "separator" },
			{ id = "energy_production", type = "slider", min = 1, max = 10, value = 1, step = 1, text = "Enery Production" },
			{ id = "energy_range", type = "slider", min = 1, max = 10, value = 1, step = 1, text = "Energy Range" },
			{ type = "separator" },
			{ id = "repair_rate", type = "slider", min = 0, max = 10, value = 0, step = 1, text = "Repair Rate" },
			{ type = "separator" },
			{ id = "transfer_range", type = "slider", min = 0, max = 100, value = 0, step = 1, text = "Item Transfert Range" },
		},
	},
	bug_wave = {
		options = {
			{ id = "enabled", type = "button", value = false },
			{ type = "separator" },
			{ id = "allow_wave", type = "button", value = false },
			{ id = "difficulty", type = "combo", texts = { "", "", "", "" }, value = 2 },
			{ type = "separator" },
			{ id = "allow_event", type = "button", value = false },
			{ id = "event_possibility", type = "slider", min = 1, max = 40, value = 1, step = 1 },
		}
	},
	bug_settings = {
		options = {
			{ id = "bug_hp_add", type = "slider", min = -100, max = 100, value = 0, step = 1, text = "Bug HP Addition" },
			{ id = "bug_hp_mult", type = "slider", min = 1, max = 10, value = 1, step = 1, text = "Bug HP Multiplier" },
			{ id = "bug_damage_add", type = "slider", min = -100, max = 100, value = 0, step = 1, text = "Bug Damage Addition" },
			{ id = "bug_damage_mult", type = "slider", min = 1, max = 10, value = 1, step = 1, text = "Bug Damage Multiplier" },
			{ id = "bug_speed_modifier", type = "slider", min = -20, max = 20, value = 0, step = 1, text = "Bug Speed Modifier" },
		}
	},
}

-- Creating translations key and dynamics vars
for k, v in pairs( ResyncedAddons ) do
	v.id = k
	v.name = "synced." .. v.id
	v.tooltip = v.name .. "t"
	for _, x in pairs( ResyncedAddons[ k ].options ) do
		if x.type == "button" or x.type == "combo" then
			x.text = v.name .. "." .. x.id
			x.tooltip = x.text .. "t"
			if x.type == "combo" then
				for _, y in pairs( x.texts ) do
					x.texts[ _ ] = x.text .. "c" .. _
				end
			end
		elseif x.type == "slider" then
			x.text = v.name .. "." .. x.id
			x.tooltip = v.name .. "." .. x.id .. "t"
		end
	end
	v.options[ #v.options + 1 ] = { id = "hidden", type = "hidden", value = false }
end

-- Used to create an external addon @param id = <String>,  @param data = <Table>
function ResyncedAddonSetup( id, data )
	ResyncedAddonOrder[ #ResyncedAddonOrder + 1 ] = id
	ResyncedAddons[ id ] = data
end

function FactionAction.SetOptionValue( faction, arg )
	local settings = Map.GetSettings().resynced or {}
	if settings[ arg.addon_id ] == nil then settings[ arg.addon_id ] = {} end
	settings[ arg.addon_id ][ arg.option_id ] = arg.value
	Map.ModifySettings( "resynced", settings )
	faction:RunUI( function() Game.OfflinePause( true ) end )
end

-- Global Resynced function
function GetOptionValue( id, key )
	local key = key or "enabled"
	
	if Map.GetSettings().resynced == nil or
		Map.GetSettings().resynced[ id ] == nil or
		Map.GetSettings().resynced[ id ][ key ] == nil then
		for k, v in pairs( ResyncedAddons[ id ].options ) do
			if v.id == key then
				return ResyncedAddons[ id ].options[ k ].value
			end
		end
	end
	return Map.GetSettings().resynced[ id ][ key ]
end

package.includes = {
	"data.lua",
	"ui.lua",
	"modules/",
	"custom_ui/"
}

function package:on_player_faction_spawn( faction, is_respawn, player_faction_num )
	-- Add faction extra data for resynced bug wave event
	if faction.extra_data.resynced == nil then
		faction.extra_data.resynced = { bug_wave = { difficulty = 1, last_tick_wave = 0, next_tick_wave = 0, initial_wave = true }}
	end
end