local ASCENDANT_TIERS_TECH_ID<const> = "tech_ascendant_tiers_start"

local layout<const> =
[[
	<VerticalList child_padding=8 fill=true>
		<Text style=header text="Ascendant Tiers"/>
		<Text text="Manual unlock helper for advanced saves."/>
		<Box bg=popup_additional_bg padding=8 fill=true>
			<VerticalList child_padding=6 fill=true>
				<Text id=status wrap=true/>
				<Button id=unlock_btn on_click={on_unlock_click}/>
			</VerticalList>
		</Box>
	</VerticalList>
]]

AscendantTiersOptions = AscendantTiersOptions or {}
if not UI.IsRegistered("AscendantTiersOptions") then
	UI.Register("AscendantTiersOptions", layout, AscendantTiersOptions)
end

function AscendantTiersOptions:refresh_state()
	if Map.IsFrontEnd() then
		self.status.text = "Open this in an active save to unlock the tech."
		self.unlock_btn.text = "Unlock unavailable in main menu"
		self.unlock_btn.disabled = true
		return
	end

	local faction = Game.GetLocalPlayerFaction()
	if not faction then
		self.status.text = "No local faction available."
		self.unlock_btn.text = "Unlock unavailable"
		self.unlock_btn.disabled = true
		return
	end

	local unlocked = faction:IsUnlocked(ASCENDANT_TIERS_TECH_ID)
	self.status.text = unlocked
		and "Ascendant Tiers is already unlocked for this faction."
		or "If this save started before installing the mod, press the button once."
	self.unlock_btn.text = unlocked
		and "Ascendant Tiers already unlocked"
		or "Unlock Ascendant Tiers tech"
	self.unlock_btn.disabled = unlocked
end

function AscendantTiersOptions:construct()
	self:refresh_state()
end

function AscendantTiersOptions:on_unlock_click()
	if Map.IsFrontEnd() then
		return
	end
	Action.SendForLocalFaction("UnlockAscendantTiersTech")
	self:refresh_state()
end

return UI.New("AscendantTiersOptions")
