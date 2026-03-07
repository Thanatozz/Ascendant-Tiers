if not GetOptionValue( "resynced", "infinite_resource_node" ) then return end

local OrgGetResourceHarvestItemAmount = GetResourceHarvestItemAmount
function GetResourceHarvestItemAmount( e )
	
	local res_left = e:GetRegisterNum( FRAMEREG_GOTO )
	local res_type = e:GetRegisterId( FRAMEREG_GOTO )
	local option = GetOptionValue( "resynced", "selected_node_type" )
	
	-- Small protection for any unregistered / valid resources
	for _, v in pairs({ "node_metal", "node_crystal", "node_silica", "node_laterite", "node_blightcrystal", "node_obsidian" }) do
		if string.find( e.def.id, v ) then break end
		if _ == 6 then return OrgGetResourceHarvestItemAmount( e ) end
	end
	
	local node_cap = GetOptionValue( "resynced", string.sub( e.def.id, 11 ))
	local selector = option == 1 and res_left <= node_cap or e.extra_data.rich ~= nil
	
	return selector and node_cap or OrgGetResourceHarvestItemAmount( e )
end