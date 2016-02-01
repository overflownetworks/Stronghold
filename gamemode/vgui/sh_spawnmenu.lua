--[[-------------------------------------------------------

Fight to Survive: Stronghold by RoaringCow, TehBigA is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.

This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons,
444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

---------------------------------------------------------]]
local SPAWNLIST, CONTEXTMENU = 200, 260
local PANEL = {}

function PANEL:Init()
	self.SpawnLists = vgui.Create( "DListView", self )
	self.SpawnLists:AddColumn( "Spawn Lists" )
	local column = self.SpawnLists:AddColumn( "Num" )
	column:SetFixedWidth( 30 )
	for k, v in pairs(GAMEMODE.SpawnLists) do
		self.SpawnLists:AddLine( k, #v )
	end
	self.SpawnLists:SortByColumn( 1, false )
	function self.SpawnLists.OnRowSelected( _, id, line )
		self:OnListSelected( line:GetColumnText(1) )
	end

	self.SpawnIcons = vgui.Create( "DPropertySheet", self )

	self.IconList = vgui.Create( "DPanelList", self )
	self.IconList:EnableVerticalScrollbar( true )
	self.IconList:EnableHorizontal( true )
	self.IconList:SetPadding( 4 )
	self.SpawnIcons:AddSheet( "Props", self.IconList, "gui/silkicons/box" )

	--self.ContextTabs = vgui.Create( "DPropertySheet", self )

	self:OnListSelected( "All" )
end

function PANEL:OnListSelected( list )
	if !GAMEMODE.SpawnLists[list] then return end

	self.IconList:Clear()

	for _, v in ipairs(GAMEMODE.SpawnLists[list]) do
		local icon = vgui.Create( "SpawnIcon", self )
		icon:SetSize( 64, 64 )
		icon:SetModel( v )
		icon.Model = string.lower( v )
		function icon:DoClick()
			RunConsoleCommand( "propspawn_model", string.lower(v) )
			RunConsoleCommand( "gmod_toolmode", "propspawn" )
			RunConsoleCommand( "gmod_tool" )
			surface.PlaySound( "ui/buttonclickrelease.wav" )
		end
		self.IconList:AddItem( icon )
	end
end

function PANEL:Open()
	RestoreCursorPosition()
	self.m_bHangOpen = false

	if self:IsVisible() then return end

	CloseDermaMenus()

	self:SetKeyboardInputEnabled( false )
	self:SetMouseInputEnabled( true )

	self:SetVisible( true )
	self:MakePopup()
end

function PANEL:Close( bSkipAnim )
	if self.m_bHangOpen then
		self.m_bHangOpen = false
		return
	end

	RememberCursorPosition()

	CloseDermaMenus()

	self:SetKeyboardInputEnabled( false )
	self:SetMouseInputEnabled( false )

	self:SetVisible( false )
end

function PANEL:Paint(w,h)
	local skin = self:GetSkin()
	surface.SetDrawColor(skin.bg_color)
	surface.DrawRect(0,0, w, h)
end

function PANEL:Think()
	local w, h = ScrW()*0.80, ScrH()*0.80
	if self:GetWide() != w or self:GetTall() != h then
		self:SetPos( ScrW()*0.10, ScrH()*0.10 )
		self:SetSize( w, h )
	end
end

function PANEL:PerformLayout()
	local w, h = ScrW()*0.80, ScrH()*0.80

	self.SpawnLists:SetPos( 5, 5 )
	self.SpawnLists:SetSize( SPAWNLIST-10, h-10 )

	self.SpawnIcons:SetPos( SPAWNLIST+15, 5 )
	self.SpawnIcons:SetSize( w-SPAWNLIST-20 --[[CONTEXTMENU-30]], h-10 )

	--self.ContextTabs:SetPos( w-CONTEXTMENU+5, 5 )
	--self.ContextTabs:SetSize( CONTEXTMENU-10, h-10 )
end

vgui.Register( "sh_spawnmenu", PANEL, "EditablePanel" )
