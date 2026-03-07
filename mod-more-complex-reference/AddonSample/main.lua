local package = ...

-- To append an addon settings : ResyncedAddons.mod_sample = {} or ResyncedAddons[ "mod_sample" ] = {}
-- name = <String>, id = <String>, tooltip = <String>,
-- To add a button : { id = <String>, type = "button", text = <String>, tooltip = <String>, value = <Boolean> }
-- To add a slider : { id = <String>, type = "slider", tooltip = <String>, min = <Integer>, max = <Integer>, value = <Boolean>, step = <Integer> }
-- To add a choice list : { id = <String>, type = "combo", texts = { "Value1", "Value2", "Value3" }, value = <Integer> }, ( value start to 1 to 3 here, and set the default text from 'texts' )
-- To add a separator : { type = "separator" },

-- You can use both setup to happend your settings to Resynced
-- ResyncedAddonOrder[ #ResyncedAddonOrder + 1 ] = "mod_sample"
-- ResyncedAddons.mod_sample = {
	-- name = "Mod Sample", id = "mod_sample", tooltip = "A test mod to show you how to happend option to your mod in Resynced",
	-- options = {
		-- { id = "enabled", type = "button", text = "Button", tooltip = "Button exemple", value = false },
		-- { id = "combo", type = "combo", text = "Slider", texts = { "Desynced", "Resynced", "Synced?" }, tooltip = "Combo exemple", value = 2 },
		-- { type = "separator" },
		-- { id = "slider", type = "slider", tooltip = "Slider exemple", min = 1, max = 10, value = 2, step = 1 },
	-- }
-- }

-- Used to create an external addon : ResyncedAddonSetup( @param id = <String>,  @param data = <Table> )
ResyncedAddonSetup( "mod_sample", { name = "Mod Sample", id = "mod_sample", tooltip = "A test mod to show you how to happend option to your mod in Resynced",
	options = {
		{ id = "enabled", type = "button", text = "Button", tooltip = "Button exemple", value = false },
		{ id = "combo", type = "combo", text = "Combo choice", texts = { "Desynced", "Resynced", "Synced?" }, tooltip = "Combo exemple", value = 2 },
		{ type = "separator" },
		{ id = "slider", type = "slider", tooltip = "Slider exemple", min = 1, max = 10, value = 2, step = 1, text = "Slider value" },
		{ id = "hidden", type = "hidden", value = false }, -- This one is necessary and must ALWAYS be set ( for hide and show function in option )
	}
})

function package:post_init()
	if GetOptionValue( "mod_sample" ) then -- Default key to check for button is "enabled" for toggle the addon
		print( GetOptionValue( "mod_sample", "combo" ), GetOptionValue( "mod_sample", "slider" ), GetOptionValue( "mod_sample", "hidden" ) )
		--[[
			Your code here ...
			GetOptionValue( <mod_id>, <option_id> default "enabled" )
		]]
	end
end