--[[-------------------------------------------------------

Fight to Survive: Stronghold by RoaringCow, TehBigA is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.

This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 
444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

---------------------------------------------------------]]
local PANEL = {}

function PANEL:Init()
	self.Donate = vgui.Create( "HTML", self )
	self.Donate:OpenURL( "http://riotservers.net/info/donate.php" )
	self.Controls = vgui.Create( "DHTMLControls", self )
	self.Controls:SetHTML( self.Donate )
end

function PANEL:PerformLayout()
	local w, h = self:GetWide(), self:GetTall()
	self.Controls:SetSize( w, 32 )
		self.Donate:SetSize( w, h-32 )
		self.Donate:SetPos( 0, 32 )
end

vgui.Register( "sh_donatepanel", PANEL, "Panel" )