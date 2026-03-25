
local package = ...

package.includes = {
	"options.lua",
}

local function DeepCopy(val)
	if type(val) ~= 'table' then return val end
	local res= {}
	for k, v in pairs(val) do res[type(k) == 'table' and DeepCopy(k) or k] = type(v) == 'table' and DeepCopy(v) or v end
	return res
end

function package:init_ui()

end

local function setup_settings()
    --Game.GetProfile().new_game_plus = nil
    if View.IsRunningHeadless() then return {} end
    local profile = DeepCopy(Game.GetProfile().new_game_plus)
    if not profile then return {} end
    
    if profile.additional_units then profile.n_additional_units = #profile.additional_units end
    if profile.additional_comps then profile.n_additional_comps = #profile.additional_comps end
    if profile.unlocked_techs then profile.n_unlocked_techs = #profile.unlocked_techs end
    
    if profile.start_type == "cub" then
        table.insert(profile.additional_units, 1, {
            id = "f_bot_1m_a", 
            bp = {
                name = "Starting Cub",
              	frame = "f_bot_1m_a",
              	race = "robot",
              	components = {
              		{ "c_solar_cell", 1 },
              		{ "c_internal_storage", 2 },
              	},
            }, 
            num = 1
        })
        table.insert(profile.additional_comps, 1, {id = "c_fabricator", num = 1})
    elseif profile.start_type == "deployer" then
        table.insert(profile.additional_comps, 1, {id = "c_deployment", num = 1})
        table.insert(profile.additional_comps, 2, {id = "c_fabricator", num = 1})
        table.insert(profile.additional_comps, 3, {id = "c_solar_cell", num = 1})
    end
    return profile
end

function package:setup_scenario(settings)
    settings.new_game_plus_settings = setup_settings()
end



local function check_start_type(faction, settings)
    local start_type = settings.start_type

    if start_type ~= "default" then
        for i,entity in ipairs(faction.entities) do
            if start_type == "nomad" then
                local comp = entity:FindComponent("c_deployment")
                if comp then
                    comp:Destroy(false)
                end
                --[[ Trying to remove deployers -- Not working because the drop pod spawn is delayed
                local n_comps = entity:CountComponents("c_deployer")
                while n_comps > 0 do
                    comp = entity:FindComponents("c_deployer", n_comps)
                    if comp then
                        print(comp)
                        comp:Destroy(false)
                    end
                    n_comps = n_comps - 1
                end
                --]]
            else
                entity:Destroy(false)
            end
        end
    end
end

local function copy_default_units(faction, settings)
    local home_location = faction.home_location
    local default_units = {}
    for i,entity in ipairs(faction.entities) do
        local loc = {x = entity.placed_location.x - home_location.x, y = entity.placed_location.y - home_location.y}
        local hidden_components = {}
        for _,comp in ipairs(entity.components) do
    		if comp.is_hidden and (comp.register_count > 0 or comp.slot_count > 0) then
                local component = { comp.id, "hidden" }
                hidden_components[#hidden_components + 1] = component
    
    			local base_id = comp.base_id
    			if base_id == "c_behavior" and comp.has_extra_data then
    				local behavior_main = comp.extra_data.main
    				if behavior_main then components[#components][3] = DeepCopy(behavior_main) end
    			elseif base_id == "c_fabricator" and comp.has_extra_data then
    				local fab_bp = comp.extra_data.custom_blueprint
    				if fab_bp then components[#components][3] = DeepCopy(fab_bp) end
    			elseif base_id == "c_deployer" and comp.has_extra_data then
    				local deployer_bp = comp.extra_data.bp
    				if deployer_bp then components[#components][3] = DeepCopy(deployer_bp) end
    			end
                comp:Destroy(false)
            end
        end

        local storage = {}        
        for _,slot in ipairs(entity.slots) do
            if slot.id and slot.stack > 0 then
                storage[#storage + 1] = {id = slot.id, num = slot.stack}
            end
        end
        
        local bp = MakeBlueprintFromEntity(entity, false, true)
        default_units[i] = { id = entity.id, bp = bp, num = 1, loc = loc, storage = storage }
        local components = bp.components
        for _,component in ipairs(hidden_components) do
            if not components then components = {} bp.components = components end
            components[#components + 1] = component
            entity:AddComponent(component[1], "hidden")
        end
    end
    settings.default_units = default_units
end

local function spawn_additional_units(faction, settings, location, spawn_default_units)
    local home_location = location or faction.home_location
    local entities = {}
    if spawn_default_units then
        for i,unit in ipairs(settings.default_units) do
            local loc = home_location
            local entity = CreateFrameOrBlueprint(faction, unit.bp or data.frames[unit.id], true)
    		entity:Place(loc.x + unit.loc.x, loc.y + unit.loc.y)
            for _,slot in ipairs(unit.storage) do
                entity:AddItem(slot.id, slot.num)
            end
            entities[i] = entity
        end
    else
        for i,entity in ipairs(faction.entities) do
            entities[i] = entity
        end
    end
    
    for i,unit in ipairs(settings.additional_units) do
        for i=1,unit.num do
            if data.frames[unit.id] then
                local entity = CreateFrameOrBlueprint(faction, unit.bp or data.frames[unit.id])
        		entity:Place(home_location.x, home_location.y)
        		if not unit.bp then entity.disconnected = false end
            
                entities[#entities + 1] = entity
            end
        end
    end
    
    if not entities or #entities == 0 then
        local entity = Map.CreateEntity(faction, "f_carrier_bot")
        entity:Place(home_location.x, home_location.y)
    end
    
    if not faction.home_entity or not faction.home_entity.exists then faction.home_entity = faction.entities[1] end
    
    return entities
end

local function spawn_additional_comps(faction, settings, entities, location)
    local spacedrops = {}
    local drops = {}
    
    local home_location = location or faction.home_location
    local drop_location = {home_location.x + 5, home_location.y + 5}
    
    for _,comp_item in ipairs(settings.additional_comps) do
        local num = comp_item.num
        local is_comp, is_item = data.components[comp_item.id], data.items[comp_item.id]
        local is_storage = is_item and is_item.slot_type and is_item.slot_type == "storage"
        
        if is_comp then
            for i,entity in ipairs(entities) do
                if entity:AddComponent(comp_item.id) then
                    num = num - 1
                    if num == 0 then break end
                end
            end
        end
        
        if is_comp or is_item then
            if num > 0 then
                for i,entity in ipairs(entities) do
                    local freespace = entity:CountFreeSpace(comp_item.id)
                    if freespace >= num then
                        entity:AddItem(comp_item.id, num)
                        num = 0
                        break
                    elseif freespace > 0 then
                        entity:AddItem(comp_item.id, freespace)
                        num = num - freespace
                    end
                end
            end
            
            if data.frames["f_spacedrop"] and data.visuals["v_spacedrop_1"] and is_storage then
                if num > 0 then
                    for i,entity in ipairs(spacedrops) do
                        local freespace = entity:CountFreeSpace(comp_item.id)
                        if freespace >= num then
                            entity:AddItem(comp_item.id, num)
                            num = 0
                            break
                        elseif freespace > 0 then
                            entity:AddItem(comp_item.id, freespace)
                            num = num - freespace
                        end
                    end
                end
                
                while num > 0 do
                    local spacedrop = Map.CreateEntity(faction, "f_spacedrop", "v_spacedrop_1")
                    spacedrop:AddComponent("c_disappear_empty", "hidden")
                    spacedrops[#spacedrops + 1] = spacedrop
                    
                    local freespace = spacedrop:CountFreeSpace(comp_item.id)
                    if freespace >= num then
                        spacedrop:AddItem(comp_item.id, num)
                        num = 0
                    elseif freespace > 0 then
                        spacedrop:AddItem(comp_item.id, freespace)
                        num = num - freespace
                    end
                end
            else
                if num > 0 then
                    Map.DropItemAt(drop_location, comp_item.id, num)
                end
            end
        end
    end
    
    for i,spacedrop in ipairs(spacedrops) do
    
	    --Map.Delay("EjectDropPod", 3, { location = {loc.x-5, loc.y+5}, entity = spacedrop1, effect = "fx_EMP", notification = true })
        if Delay.PlaceAndPlayEffect then --EjectDropPod
            Map.Delay("PlaceAndPlayEffect", 13 + i, { location = {home_location.x+5, home_location.y+5}, entity = spacedrop, effect = "fx_EMP",})
        else
            Map.Delay("EjectDropPod", 13 + i, { location = {home_location.x+5, home_location.y+5}, entity = spacedrop, effect = "fx_EMP",})
        end
    end
end

local function unlock_techs(faction, settings)
    for i,tech in ipairs(settings.unlocked_techs) do
        faction:Unlock(tech.id, false)
    end
end

function toXY(location)
    return {x = location[1], y = location[2]}
end

function package:post_init()
    local scenarioPackage = Game.GetScenarioModPackage()
    
    if scenarioPackage.skipNewGamePlus then return end
    
    local org_on_player_faction_spawn = scenarioPackage.on_player_faction_spawn
    local respawn = true
    scenarioPackage.on_player_faction_spawn = function(mod_package, faction, is_respawn, player_faction_num, ...)
        
        if org_on_player_faction_spawn then org_on_player_faction_spawn(mod_package, faction, is_respawn, player_faction_num, ...) end
        
        local settings = DeepCopy(Map.GetSettings().new_game_plus_settings)
        
        
        if settings.start_type then
            local num_players = settings.num_players or 1
            
            check_start_type(faction, settings)
            
            if num_players > 1 then
                copy_default_units(faction, settings)
            end                                                                                  
            
            if not faction.extra_data.library then faction.extra_data.library = {} end
            
            for i=1,num_players do
                local location = i == 1 and faction.home_location or toXY(GetPlayerFactionHomeOnGround())
                
                local entities = spawn_additional_units(faction, settings, location, i > 1)
                
                spawn_additional_comps(faction, settings, entities, location)
            end

            unlock_techs(faction, settings)
        end
        
        
        --Delay:Unbind("StartOfGame", Delay.StartOfGame)
        --Delay.StartOfGame = nil
        
        --Delay.StartOfGame = CustomStartOfGame
        --Delay["StartOfGame"] = CustomStartOfGame
        --Delay:Bind("StartOfGame", CustomStartOfGame)
    end
end


function CustomStartOfGame(arg)
	-- unlock starting tech/codex for this scenario for the local player (unlocked by default)
	arg.faction:Unlock("x_freeplay_start")

    --[[
	local loc = arg.faction.home_location
	local spacedrop1 = Map.CreateEntity(arg.faction, "f_spacedrop", "v_spacedrop_1")
	local slot = spacedrop1:AddItem("c_deployer", 1)
	slot.extra_data = {
		onetime = true,
		bp = {
			regs = { [5] = { id = "metalbar", num = REG_INFINITE }, },
			frame = "f_building1x1d",
			components = { { "c_fabricator", 1 } },
			links = { { 3, 5 } },
			name = "Metal Bar Production"
		}
	}
	spacedrop1:AddItem("c_fabricator", 1)
	spacedrop1:AddItem("circuit_board", 10)
	spacedrop1:AddItem("metalbar", 20)
	Map.Delay("EjectDropPod", 3, { location = {loc.x-5, loc.y+5}, entity = spacedrop1, effect = "fx_EMP", notification = true })
    --]]
end

