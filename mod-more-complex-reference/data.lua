if GetOptionValue( "resynced", "puzzle_hacker" ) then

	data.components[ "synced_c_puzzle_hacker" ] = {
		base_id = "synced_c_puzzle_hacker",
		name = "synced_c_puzzle_hacker.name",
		texture = "Main/textures/icons/components/radio_transmitter.png",
		desc = "synced_c_puzzle_hacker.desc",
		production_recipe = CreateProductionRecipe({ circuit_board = 1 }, { c_assembler = 30 }, 1 ),
		power = 0,
		attachment_size = "Internal",
		slot_type = "storage",
		visual = "v_generic_i",
		race = "synced",
		registers = {
			{ type = "entity", tip = "Autosolve Explorable", ui_icon = "icon_unlocked" },
		},
		range = 5,
		activation = "OnFirstRegisterChange",
		duration = 5,
		
		on_update = function( self, comp, cause )

			if cause & CC_FINISH_WORK == 0 and comp.is_working then
				return comp:SetStateContinueWork()
			end
			
			local target = comp:GetRegister( 1 ).entity
			if not target then
				comp:SetRegister( 1, nil )
				return comp:SetStateSleep()
			end
			
			local is_explo = string.find( target.def.id, "_explorable" ) and true or false
			if not is_explo then
				comp:SetRegister( 1, nil )
				return comp:SetStateSleep()
			end
			
			-- Use this to properly solve the puzzle ( actually generate error but work )
			if not target:FindComponent( "c_explorable_autosolve" , true ) then
				target:AddComponent( "c_explorable_autosolve", "hidden" ):SetRegister( 1, { id = "robot_datacube", num = 0 })
			end
			
			local comp_explo = { "c_explorable_fix", "c_explorable_scannable", "c_explorable_nineclicks", "c_explorable_netwalk", "c_explorable_slide", "c_explorable_balance" }
			for _, v in ipairs( comp_explo ) do
				local target_comp = target:FindComponent( v )
				if target_comp then
					target_comp.extra_data.ok = true
				end
			end
			-- target.extra_data.solved = true
			-- target.lootable = true
			
			comp:SetRegister( 1, nil )
			return comp:SetStateStartWork( self.duration )
		end
	}
end

if not GetOptionValue( "resynced" ) then return end

---------------------------------------------------------------------------------------------------
-- ITEMS ------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

data.items[ "synced_i_artifact" ] = {
	name = "synced_i_artifact.name",
	desc = "synced_i_artifact.desc",
	race = "synced",
	tag = "research",
	slot_type = "storage",
	stack_size = 20,
	texture = "Resynced/textures/synced_artifact.png",
	visual = "v_alien_artifact",
	production_recipe = CreateProductionRecipe({ virus_research_data = 1, blight_extraction = 5, alien_artifact = 1 }, { c_fabricator = 15 }, 40 ),
}

---------------------------------------------------------------------------------------------------
-- COMPONENTS -------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

data.components[ "synced_c_blightfuel" ] = {
	name = "synced_c_blightfuel.name",
	base_id = "synced_c_blightfuel",
	desc = "synced_c_blightfuel.desc",
	attachment_size = "Internal",
	slot_type = "storage",
	visual = "v_generic_i",
	texture = "Resynced/textures/synced_core.png",
	production_recipe = CreateProductionRecipe({ synced_i_artifact = 10 }, { c_assembler = 5 }, 1 ),
	activation = "Always",
	race = "synced",
	adjust_extra_power = true,
	
	on_update = function( self, comp, cause )
		if cause & CC_FINISH_WORK == 0 and comp.is_working then
			return comp:SetStateContinueWork()
		end
		
		local can_make = comp:PrepareConsumeProcess({ blight_extraction = 1 }, 11 )
		if not can_make then
			comp.owner.powered_down = not comp.is_working
			return comp:SetStateSleep()
		end
		
		comp.extra_power = 10
		comp:FulfillProcess()
		return comp:SetStateStartWork( 60 * 5 ) -- 60 sec fuel usage * 5 ticks
	end
}

data.components[ "synced_c_nanobot_firewall" ] = {
	name = "synced_c_nanobot_firewall.name",
	base_id = "synced_c_nanobot_firewall",
	desc = "synced_c_nanobot_firewall.desc",
	attachment_size = "Internal",
	slot_type = "storage",
	visual = "v_generic_i",
	texture = "Resynced/textures/synced_core.png",
	production_recipe = CreateProductionRecipe({ c_blight_shield = 1, c_virus_cure = 1, c_repairkit = 1, c_shield_generator3 = 1 }, { c_assembler = 40 }, 1 ),
	activation = "Always",
	race = "synced",
	power = -5,
	repair = 2,
	duration = 5,
	power_storage = 80,
	charge_rate = 1,
	effect = "fx_shield2",
	damage_to_power_ratio = 1,
	slots = { virus = 1 },
	trigger_radius = 3,
	trigger_channels = "bot|building",
	
	on_add = function( self, comp )
		comp.owner.has_blight_shield = true
		local virus_comp = comp.owner:FindComponent( "c_virus" )
		if virus_comp ~= nil then
			virus_comp:Destroy()
		end
	end,
	
	on_remove = function( self, comp )
		if comp.owner:CountComponents( "synced_c_nanobot_firewall" ) == 1 then comp.owner.has_blight_shield = false end
	end,
	
	on_update = function( self, comp, cause )
		if cause & CC_FINISH_WORK == 0 and comp.is_working then
			return comp:SetStateContinueWork()
		end
		
		if not comp.owner.is_damaged then
			return comp:SetStateSleep( self.duration )
		end
		
		if comp.owner.has_power then
			comp.owner:AddHealth( self.repair )
		end
		return comp:SetStateStartWork( self.duration )
	end,
	
	on_take_damage = function( self, comp, amount )
		local reduce_amount = comp.stored_power // self.damage_to_power_ratio
		if reduce_amount == 0 then
			return
		end
		if reduce_amount > amount then
			reduce_amount = amount
		end
		comp.stored_power = comp.stored_power - reduce_amount * self.damage_to_power_ratio
		return amount - reduce_amount
	end,
	
	on_trigger = function( self, comp, other_entity )
		local virus_comp = other_entity:FindComponent( "c_virus" )
		if virus_comp ~= nil then
			virus_comp:Destroy()
			other_entity:PlayEffect( "fx_digital" )
			other_entity.powered_down = false

			if other_entity.id == "f_exploreable_bot_glitch" then
				FactionCount( "cured_anomaly", true, comp.faction )
				other_entity:AddComponent( "c_anomaly_go_home", "hidden" )
			end

			comp.owner:AddItem( "virus_source_code", 1 )
			Map.Run( "OnItemPickup", comp.faction, "virus_source_code" )

			for _,v in ipairs( other_entity.slots or {} ) do
				local vir = v.entity and v.entity:FindComponent( "c_virus" )
				if vir then
					vir:Destroy()
					v.entity.powered_down = false
				end
			end
		end
	end,
	
	get_ui = function( self, comp )
		return UI.New( "<Progress height=56 width=56 color=green angle=270/>", {
			update = function( w )
				local comp_def, comp_details = comp.def, comp.power_details
				if comp_details then
					w.progress = comp.stored_power / comp_def.power_storage
					if w.tt then
						w.tt.text = L(( comp_details.change ~= 0 and "%s: %.0f/%.0f (%+.0f)" or "%s: %.0f/%.0f"), "synced_c_nanobot_firewall.energy", comp_details.stored, comp_def.power_storage, comp_details.change*TICKS_PER_SECOND)
					end
				end
			end,
			tooltip = function( w )
				w.tt = UI.New( "<Box bg=popup_box_bg padding=12 blur=true><Text/></Box>", { destruct = function() w.tt = nil end })[ 1 ]
				w:update()
				return w.tt.parent
			end,
		})
	end
}

-- c_modulehealth:RegisterComponent( "synced_c_modulehealth", {
	-- name = "Small Health Module",
	-- desc = "Increased structural integrity, adds 100 durability",
	-- race = "synced",
	-- attachment_size = "Internal",
	-- texture = "Main/textures/icons/components/module_health.png",
	-- production_recipe = CreateProductionRecipe({ icchip = 5, hdframe = 5 }, { c_assembler = 60 }),
	-- visual = "v_generic_i",
	-- boost = 100,
	-- power = -2,
-- })

-- c_modulevisibility:RegisterComponent( "c_modulevisibility_s", {
	-- name = "Small Visibility Module",
	-- desc = "Increase unit visibility range by 10",
	-- race = "robot",
	-- attachment_size = "Internal",
	-- production_recipe = CreateProductionRecipe({ icchip = 5, hdframe = 5 }, { c_assembler = 60 }),
	-- texture = "Main/textures/icons/components/module_visibility.png",
	-- visual = "v_generic_i",
	-- boost = 10,
	-- power = -2,
-- })


---------------------------------------------------------------------------------------------------
-- FRAMES / VISUAL --------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

data.frames[ "synced_f_wolf" ] = {
	texture = "Main/textures/icons/frame/bot_1m1s_a.png",
	name = "synced_f_wolf.name",
	desc = "synced_f_wolf.desc",
	minimap_color = { 0.9, 0.9, 0.8 },
	slot_type = "garage",
	visibility_range = 20,
	size = "Unit",
	health_points = 550,
	slots = { storage = 4 },
	start_disconnected = true,
	power = -5,
	movement_speed = 4,
	race = "synced",
	flags = "AnimateRoot",
	components = {{ "c_integrated_capacitor", "hidden" }, { "synced_c_blightfuel", "hidden" }, { "c_blight_extractor", "hidden" }},
	trigger_channels = "bot",
	production_recipe = CreateProductionRecipe({ circuit_board = 10, hdframe = 5, optic_cable = 2, synced_i_artifact = 5 }, { c_robotics_factory = 100 }, 1 ),
	visual = "synced_v_wolf",
}

data.visuals[ "synced_v_wolf" ] = {
	name = "synced_v_wolf.name",
	mesh = "StaticMesh'/Game/Meshes/RobotUnits/Bot_1M1S_A.Bot_1M1S_A'",
	-- mesh = "Resynced/wolf.glb",
	light_radius = 5,
	light_color = bot_light_color,
	sockets = {
		{ "Medium1","Medium" },
		-- { "s1","Medium" },
		{ "Small1", "Small" },
		{ "", "Small" },
		{ "", "Internal" },
		{ "", "Internal" },
		{ "", "Internal" },
		{ "", "Internal" }
	},
	-- mesh_sockets = {
		-- s1 = { 40, 0, 100 },
	-- },
	-- scale = {0.6,0.6,0.6},
	move_effect = "fx_move_bot",
	destroy_effect = "fx_digital"
}

---------------------------------------------------------------------------------------------------
-- TECHS ------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

data.tech_categories[ #data.tech_categories + 1 ] = {
	name = "synced_category.name",
	discovery_tech = "syncedt_discovery",
	initial_tech = "syncedt_init",
	sub_categories = { "Resynced" },
	texture = "Resynced/textures/synced_logo.png"
}

data.techs.syncedt_discovery = {
	name = "syncedt_discovery.name",
	texture = "Resynced/textures/synced_artifact.png",
	category = "Story"
}

data.techs.syncedt_init = {
	name = "syncedt_init.name",
	texture = "Resynced/textures/synced_artifact.png",
	desc = "syncedt_init.desc",
	uplink_recipe = CreateUplinkRecipe({ virus_research_data = 1, blight_extraction = 5, alien_artifact = 1 }, 300 ),
	progress_count = 10,
	require_tech = { "syncedt_discovery" },
	unlocks = { "synced_i_artifact" },
	category = "Story"
}

data.techs.syncedt1 = {
	order = 1,
	name = "syncedt1.name",
	desc = "syncedt1.desc",
	texture = "Main/textures/tech/uplink.png",
	uplink_recipe = CreateUplinkRecipe({ synced_i_artifact = 5 }, 500 ),
	progress_count = 20,
	category = "Resynced",
	require_tech = { "t_assembly", "syncedt_init" },
	unlocks = { "synced_f_wolf", "synced_c_nanobot_firewall" },
	talkinghead = "syncedt1.talkinghead"
}

function MapMsg.OnItemPickup( faction, item_id ) -- Used to unlock resynced tech
	if item_id == "alien_datacube" then -- Wait to see for alien_artifact later on
		faction:Unlock( "syncedt_discovery" )
		faction:Unlock( "alien_artifact" ) -- May be teporary ...
	end
end