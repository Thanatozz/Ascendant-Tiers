if not GetOptionValue( "resynced", "custom_ui" ) then return end

local ResourceBar = {}
UI.Register( "ResyncedResourceBar", [[
	<HorizontalList dock=top-left child_align=top >
		<Box bg=popup_additional_bg padding=4 fill=true min_height=40 min_width=10 >
			<Wrap id=rlist child_padding=4 wrapsize=0 />
		</Box>
		<Canvas valign=center id=hide_rbar tooltip=synced.ui.resourcebar >
			<Image image=popup_small_pointer valign=center />
			<Image image=icon_pointer valign=center width=6 height=12 color=green />
		</Canvas>
	</HorizontalList>
]], ResourceBar )

function ResourceBar:construct()
	local sw, sh = Game.GetScreenResolution()
	self.rlist.wrapsize = sw - 268 - 8 -- 268 = action bar size / 8 = 4*2 padding
	self.hide_rbar.on_click = function( button )
		self.rlist.hidden = not self.rlist.hidden
		button.children[ 2 ].color = self.rlist.hidden and "ui_light" or "green"
	end
	
	UI.AddLayout([[
		<ShortcutBar dock=top-left margin_top=80 margin_left=4 />
	]])
end

function ResourceBar:update()
	
	local faction = Game.GetLocalPlayerFaction()
	local items = faction.all_items
	
	for k, v in pairs( items ) do -- Create
		local def = data.all[ k ]
		if v > 0 and not data.components[ k ] and not data.all[ k ].convert_to and not WidgetChildExist( self.rlist, def.id ) then
			self.rlist:Add([[
				<Box width=32 height=32 >
					<Canvas>
						<Image image=item_default width=32 height=32 />
						<Image id=flash width=32 height=32 opacity=0 />
						<Image image={icon} width=32 height=32 />
						<Text style=res size=9 text={numtext} dock=bottom />
					</Canvas>
				</Box>
				]], {
				icon = def and def.texture,
				numtext = MakeNumString( v ),
				amount = v,
				id = def.id,
				tag = def.tag,
				tooltip = DefinitionTooltip( def ),
				on_click = function( wid ) ResyncedOpenMainWindow("Faction", { show_item_id = wid.id }) end
			})
		end
	end
	
	local sorting_order = { resource = 0, simple_material = 1, advanced_material = 2, hitech_material = 3, research = 4 }
	
	for _, v in pairs( self.rlist.children ) do -- Update
		local id = v.id
		local def = data.all[ id ]
		
		if v.amount ~= items[ id ] then
			v:TweenFromTo( "sx", 1.15, 1, 300, "InOutBounce" )
			v:TweenFromTo( "sy", 1.15, 1, 300, "InOutBounce" )
			if items[ id ] > v.amount then v.flash.color = "green"
			elseif items[ id ] < v.amount then v.flash.color = "red" end
			v.flash:TweenFromTo( "opacity", 0.2, 0, 300, "InOutBounce" )
		end
		
		v.amount = items[ id ]
		v.children[ 1 ].children[ 4 ].text = MakeNumString( items[ id ] )
		
		-- if v.amount == 0 then v:RemoveFromParent() end
	end
	
	self.rlist:SortChildren( function( a, b )
		return sorting_order[ a.tag ] < sorting_order[ b.tag ] or ( sorting_order[ a.tag ] == sorting_order[ b.tag ] and a.amount < b.amount ) or ( sorting_order[ a.tag ] == sorting_order[ b.tag ] and a.amount == b.amount and a.id > b.id )
	end )
end