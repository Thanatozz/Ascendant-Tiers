-- Custom bug frames for wave event only ( no drop )
data.frames.f_trilobyte1:RegisterFrame( "synced_f_trilobyte1", { on_destroy = function( entity, damager ) end, minimap_color = { 255, 0, 0 } })
data.frames.f_gastarias1:RegisterFrame( "synced_f_gastarias1", { on_destroy = function( entity, damager ) end, minimap_color = { 255, 0, 0 } })
data.frames.f_scaramar1:RegisterFrame( "synced_f_scaramar1", { on_destroy = function( entity, damager ) end, minimap_color = { 255, 0, 0 } })
data.frames.f_gastarid1:RegisterFrame( "synced_f_gastarid1", { on_destroy = function( entity, damager ) end, minimap_color = { 255, 0, 0 } })

function GetEntityTexture( entity )
	return data.frames[ entity.def.id:gsub( "%synced_", "" )].texture
end

function CountEntities( faction )
	local buildings, bots = 0, 0
	for k, v in pairs( faction.entities ) do
		local entity = v.def
		if entity.type ~= "Wall" and entity.type ~= "Construction" then
			if entity.trigger_channels == "building" then
				buildings = buildings + 1
			else
				bots = bots + 1
			end
		end
	end
	return buildings, bots
end

function GetPowerGridTotal( faction )
	if #faction:GetPowerGrids() == 0 then return 0 end
	local total = 0
	for k, v in pairs( faction:GetPowerGrids() ) do
		total = total + v.total
	end
	return total
end

function GetAngerLevelFrom( faction )
	local buildings, bots = CountEntities( faction )
	local p_buil = buildings / ( 10 - faction.extra_data.resynced.bug_wave.difficulty )
	local p_bots = bots / ( 5 - faction.extra_data.resynced.bug_wave.difficulty )
	local p_tech = #faction.unlocked_techs / ( 8 - faction.extra_data.resynced.bug_wave.difficulty )
	local p_powe = math.ceil(( GetPowerGridTotal( faction ) * 5 ) / 1000 )

	return math.ceil( p_buil + p_bots + p_tech + p_powe ) or 1
end

function GetRandomFactionBuilding( faction )
	local list = {}
	for k, v in ipairs( faction.entities ) do
		if v.def.type ~= "Wall" and v.def.trigger_channels == "building" then
			list[ #list + 1 ] = v
		end
	end
	return list
end

function BugWaveStart( faction )
	if #GetRandomFactionBuilding( faction ) == 0 then return end
	if faction.is_player_controlled and not faction.extra_data.resynced.bug_wave.initial_wave then
		
		local flc = ( 5 * 1 + 4 * 2 + 2 * 4 + 1 * 6 ) * 2 -- #frame list counter 27 * 2 = 54
		local multiplier = ( GetAngerLevelFrom( faction ) + ( faction.extra_data.resynced.bug_wave.difficulty * 2 ))
		local num_wave = math.ceil( multiplier / flc ) -- CreateBugWave function > total #frame_list.count is 27 so every 54 'pts' it will create a new group
		local last_wave_power = math.fmod( multiplier, flc ) -- Only used when multiplier > 54
		
		for i = 1, num_wave do
			Map.Delay( "BugWaveCall", 5 * i, { i = i, faction = faction, multiplier = multiplier, num_wave = num_wave, last_wave_power = last_wave_power, flc = flc })
		end
	end
	faction.extra_data.resynced.bug_wave.initial_wave = false
end

function Delay.BugWaveCall( arg )
	local targets = GetRandomFactionBuilding( arg.faction )
	local target = targets[ math.random( 1, #targets )]
	local lx, ly = GetRandomHiddenCoord( arg.faction, target )
	local wave_power = arg.num_wave > arg.i and arg.flc or arg.multiplier < arg.flc and arg.multiplier or arg.last_wave_power
	local bug, counter, texture = CreateBugWave( target, lx, ly, wave_power )
		
	arg.faction:RunUI( function()
		-- View.DoPlayerPing( bug )
		Notification.Add( EVENT_NOTIFY_ID, texture, "synced.ui.bug_wave_start", L( 'synced.ui.bug_wave_info', counter ), {
			tooltip = "World Event",
			duration = 30.0,
			on_click = bug and function()
				View.JumpCameraToEntities( bug )
				-- View.DoPlayerPing( bug )
			end,
		})
	end )
end

function FactionAction.SyncedBugWave( faction, arg )
	local difficulty = GetOptionValue( "bug_wave", "difficulty" )
	local tick_rand = ( 3600 * 5 ) - ( math.random( 0, difficulty * 1500 )) -- Hour based - random tick wave start between 1h and 40min
	local events = faction.extra_data.resynced.bug_wave
	if Map.GetTick() >= events.next_tick_wave or events.last_tick_wave >= Map.GetTick() then
		faction.extra_data.resynced.bug_wave.last_tick_wave = Map.GetTick()
		faction.extra_data.resynced.bug_wave.next_tick_wave = Map.GetTick() + tick_rand
	end
	
	if faction.extra_data.resynced.bug_wave.difficulty ~= difficulty then
		faction.extra_data.resynced.bug_wave.difficulty = difficulty
	end
end

function CreateBugWave( target_location, x, y, anger )
	local current_anger, counter = anger, 0
	local texture = ""
	local frame_list = {
		{ entity = "synced_f_trilobyte1", count = 5, value = 1 },
		{ entity = "synced_f_gastarias1", count = 4, value = 2 },
		{ entity = "synced_f_scaramar1", count = 2, value = 4 },
		{ entity = "synced_f_gastarid1", count = 1, value = 6 },
	}
	
	while current_anger >= 0 do
		for k, v in pairs( frame_list ) do
			for i = 0, v.count do
				local entity = Map.CreateEntity( "bugs", v.entity )
				entity:Place( x + math.random( -5, 5 ), y  + math.random( -5, 5 ))
				entity:MoveTo( target_location )
				current_anger = current_anger - v.value
				counter = counter + 1
				
				-- Upgrade the texture untill it reach the heavier ennemy
				if not string.find( texture, "gastarid" ) then
					texture = GetEntityTexture( entity )
				end
				
				if current_anger <= 0 then return entity, counter, texture end
			end
		end
	end
end

function GetOnlinePlayerFaction( faction )
	local counter = 0
	for k, v in pairs( Game.GetAllPlayers() ) do
		if v.faction_id == faction.id then
			counter = counter + 1
		end
	end
	return counter
end

-- Use to avoid using twice action
function IsFirstOnlinePlayerFaction()
	local counter = 0
	for k, v in pairs( Game.GetAllPlayers() ) do
		if Game.GetLocalPlayer().name == v.name and
			Game.GetLocalPlayer().faction_id == Game.GetLocalPlayerFaction().id and
			counter == 0 then
			return true
		end
		counter = counter + 1
	end
	return false
end


function GetRandomHiddenCoord( faction, target )
	local dist = 100
	local dmin = dist / 2
	local dmax = dist
	local counter = 0
	while true do
		local cx = target.location.x + math.random( -dmax, dmax )
		local cy = target.location.y + math.random( -dmax, dmax )
		if not faction:IsVisible({ cx, cy }, true ) and target:GetRangeTo({ cx, cy }) >= dmin then
			return cx, cy
		end
		counter = counter + 1
		if counter % 10 == 0 then
			dmax = dmax * 10
		end
	end
end

if GetOptionValue( "bug_wave" ) and GetOptionValue( "bug_wave", "allow_event" ) then
	data.world_events.bug_wave = {
		GetPossibility = function() return GetOptionValue( "bug_wave", "event_possibility" ) end,
		SimulationTick = function( event ) return false end,
		Init = function( event ) return 1 end,
		Start = function( event )
			for _, faction in ipairs( Map.GetFactions() ) do
				BugWaveStart( faction )
			end
		end
	}
end