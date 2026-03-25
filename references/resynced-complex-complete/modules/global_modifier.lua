local InOreList = { metalore = true, crystal = true, laterite = true, silica = true, obsidian = true, blight_crystal = true }
local InToolList = { c_miner = true, c_adv_miner = true, c_extractor = true }
local InFrameList = {}
for k, v in pairs( data.frames ) do -- Dynamically add all robot and human bot
	if v.race == "robot" or v.race == "human" or v.race == "synced" then
		if v.trigger_channels ~= nil then
			if v.trigger_channels == "bot" then
				InFrameList[ k ] = v.name
			end
		end
	end
end

---------------------------------------------------------------------------------------------------
-- GLOBAL MODIFIER --------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

for _, x in pairs({ "items", "components", "frames", "techs" }) do -- Looking for desired 'data{}' only
	for k, v in pairs( data[ x ] ) do
		
		if data[ x ][ k ].production_recipe then -- Production time
			for t, _ in pairs( data[ x ][ k ].production_recipe.producers ) do -- In case multiple producers defined
				data[ x ][ k ].production_recipe.producers[ t ] = math.ceil( data[ x ][ k ].production_recipe.producers[ t ] / GetOptionValue( "global_modifier", "production_speed" ))
			end
		end
		
		-- Items modifier only
		if x == "items" then
			if data[ x ][ k ].stack_size then
				if data[ x ][ k ].stack_size > 1 then
					if InOreList[ k ] then -- For ore only
						data[ x ][ k ].stack_size = math.ceil( data[ x ][ k ].stack_size * GetOptionValue( "global_modifier", "ore_stack_size" )) -- Ore stack size
						for t, _ in pairs( data[ x ][ k ].mining_recipe ) do -- Mining efficiency
							data[ x ][ k ].mining_recipe[ t ] = math.ceil( data[ x ][ k ].mining_recipe[ t ] / GetOptionValue( "global_modifier", "mining_efficiency" ))
						end
					else
						if data[ x ][ k ].stack_size == 1 and GetOptionValue( "global_modifier", "stack_override" ) == true then
							data[ x ][ k ].stack_size = 1 -- Force stack size to 1 for any items do not stack by default
						else
							data[ x ][ k ].stack_size = math.ceil( data[ x ][ k ].stack_size * GetOptionValue( "global_modifier", "stack_size" )) -- Item stack size
						end
					end
				end
			end
			
			if data[ x ][ k ].production_recipe and not data[ x ][ k ].convert_to then -- Production multiplier
				data[ x ][ k ].production_recipe.amount = math.ceil( data[ x ][ k ].production_recipe.amount * GetOptionValue( "global_modifier", "production_multiplier" ))
			end
		end
		
		-- Components modifier only
		if x == "components" then
			if InToolList[ k ] then -- Mining range
				data[ x ][ k ].miner_range = math.ceil( data[ x ][ k ].miner_range + GetOptionValue( "global_modifier", "mining_range" ))
			end
			
			if k == "c_blight_extractor" then -- Blight extraction
				data[ x ][ k ].extraction_time = math.ceil( data[ x ][ k ].extraction_time / GetOptionValue( "global_modifier", "blight_extraction_efficiency" ))
			end
			
			if data[ x ][ k ].power ~= nil then -- Power Production
				if data[ x ][ k ].power > 0 then
					data[ x ][ k ].power = math.ceil( data[ x ][ k ].power * GetOptionValue( "global_modifier", "energy_production" ))
				end
			end
			
			if data[ x ][ k ].transfer_radius ~= nil then -- Power Transfer Range
				data[ x ][ k ].transfer_radius = math.ceil( data[ x ][ k ].transfer_radius * GetOptionValue( "global_modifier", "energy_range" ))
			end
			
			if data[ x ][ k ].repair ~= nil then -- Increase repair ability
				data[ x ][ k ].repair = math.ceil( data[ x ][ k ].repair + GetOptionValue( "global_modifier", "repair_rate" ))
			end
			
			if k == "c_crane" or k == "c_portablecrane" or k == "c_internal_crane1"
				or k == "c_internal_crane2" or k == "c_internal_transporter" then
				data[ x ][ k ].range = math.ceil( data[ x ][ k ].range + GetOptionValue( "global_modifier", "transfer_range" )) > 255 and 255 or math.ceil( data[ x ][ k ].range + GetOptionValue( "global_modifier", "transfer_range" ))
			end
		end
		
		-- Frames modifier only
		if x == "frames" then
			if InFrameList[ k ] and data[ x ][ k ].movement_speed then -- Bot speed
				data[ x ][ k ].movement_speed = math.ceil( data[ x ][ k ].movement_speed + GetOptionValue( "global_modifier", "bot_speed" ))
			end
		end
		
		-- Techs modifier only
		if x == "techs" then
			if data[ x ][ k ].uplink_recipe then -- Research speed
				data[ x ][ k ].uplink_recipe.ticks = math.ceil( data[ x ][ k ].uplink_recipe.ticks / GetOptionValue( "global_modifier", "research_speed" ))
			end
		end
	end
end

---------------------------------------------------------------------------------------------------
-- BUG MODIFIER -----------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

local notInFirstSlot = { f_gastarias2 = 2 }
for _,v in pairs( data.frames ) do
	if v.race == "virus" and v.trigger_channels == "bot|bug" and _ ~= "f_trilobyte_testdummy" then
		local health_temp = ( v.health_points + GetOptionValue( "bug_settings", "bug_hp_add" )) * GetOptionValue( "bug_settings", "bug_hp_mult" )
		health_temp = health_temp > 1 and health_temp or 1	-- Health min (1) security
		health_temp = health_temp > 65535 and 65535 or health_temp -- Health max (65535) security
		data.frames[ _ ].health_points = health_temp
		
		local speed_temp = data.frames[ _ ].movement_speed + GetOptionValue( "bug_settings", "bug_speed_modifier" )
		speed_temp = speed_temp > 1 and speed_temp or 1
		data.frames[ _ ].movement_speed = speed_temp
		
		local slot = 1
		if notInFirstSlot[ _ ] then slot = notInFirstSlot[ _ ] end
		if data.components[ v.components[ slot ][ 1 ]].damage then
			
			local damage_temp = ( data.components[ v.components[ slot ][ 1 ]].damage + GetOptionValue( "bug_settings", "bug_damage_add" )) * GetOptionValue( "bug_settings", "bug_damage_mult" )
			damage_temp = damage_temp > 1 and damage_temp or 1 -- Damage min (1) security
			data.components[ v.components[ slot ][ 1 ]].damage = damage_temp
		end
	end
end