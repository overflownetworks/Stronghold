--[[-------------------------------------------------------

Fight to Survive: Stronghold by RoaringCow, TehBigA is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.

This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 
444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

---------------------------------------------------------]]
local PANEL = {}

function PANEL:Init()
end

function PANEL:PerformLayout()
	local ActiveTab = self:GetActiveTab()
	local Padding = self:GetPadding()
	if !ActiveTab then return end

	ActiveTab:InvalidateLayout( true )

	self.tabScroller:StretchToParent( Padding, 0, Padding, nil )
	self.tabScroller:SetTall( ActiveTab:GetTall() )
	self.tabScroller:InvalidateLayout( true )

	for k, v in pairs(self.Items) do
		v.Tab:GetPanel():SetVisible( false )
		v.Tab:SetZPos( 100 - k )
		v.Tab:ApplySchemeSettings()
	end

	if ActiveTab then
		local ActivePanel = ActiveTab:GetPanel()

		ActivePanel:SetVisible( true )
		ActivePanel:SetPos( 10, ActiveTab:GetTall() + 10 )

		if !ActivePanel.NoStretchX then 
			ActivePanel:SetWide( self:GetWide() - 20 )
		else
			ActivePanel:CenterHorizontal()
		end

		if !ActivePanel.NoStretchY then 
			ActivePanel:SetTall( self:GetTall() - ActiveTab:GetTall() - 20 ) 
		else
			ActivePanel:CenterVertical()
		end

		ActivePanel:InvalidateLayout()
		ActiveTab:SetZPos( 100 )
	end
	self.animFade:Run()
end

vgui.Register( "sh_paddingfix", PANEL, "DPropertySheet" )