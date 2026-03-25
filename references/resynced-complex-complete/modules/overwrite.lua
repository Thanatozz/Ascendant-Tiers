--------------------------------------------------------------------------
-- Overwriting vanilla values
--------------------------------------------------------------------------

if GetOptionValue( "overwrite", "alien_artifact_recipe" ) then
	data.items.alien_artifact.production_recipe = CreateProductionRecipe({ obsidian = 5, blight_crystal = 1 }, { c_fabricator = 40 })
end

if GetOptionValue( "overwrite", "unit_chain_teleport" ) then
	data.components[ "c_unit_teleport" ].on_update = function( self, comp, cause )

		if cause & (CC_FINISH_WORK) == CC_FINISH_WORK then
			for i,v in ipairs(comp.slots) do
				local docked_entity = v.entity
				local target_entity = comp:GetRegister(1)
				-- local chain_entity = target_entity
				
				while target_entity.entity:FindComponent("c_unit_teleport"):GetRegister(1).entity do
					target_entity = target_entity.entity:FindComponent("c_unit_teleport"):GetRegister(1)
					-- print( target_entity )
				end
				
				
				if docked_entity and target_entity.entity then
					-- remove docked item, undock at destination
					Map.Defer(function() docked_entity:Place(target_entity.entity.location) Map.Run("OnEntityGoto", docked_entity) end)
				end
			end
		end
		for i,v in ipairs(comp.slots) do
			local docked_entity = v.entity
			if docked_entity then
				local target_entity = comp:GetRegister(1)
				
				while target_entity.entity:FindComponent("c_unit_teleport"):GetRegister(1).entity do
					target_entity = target_entity.entity:FindComponent("c_unit_teleport"):GetRegister(1)
					-- print( target_entity )
				end
				
				target_entity = target_entity and target_entity.entity
				
				if target_entity and target_entity:FindComponent("c_unit_teleport") and target_entity.faction:GetTrust(comp.faction) == "ALLY" then
					-- start teleporting
					-- print( comp:GetRegister(1) )
					comp:PlayEffect("fx_unit_teleport", "fx")
					return comp:SetStateStartWork(1, false) -- teleport time based on distance?
				else
					-- cant teleport, undock
					Map.Defer(function() docked_entity:Undock() end)
				end
			end
		end
		return comp:SetStateSleep()
	end
end