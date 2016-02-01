--[[-------------------------------------------------------

Fight to Survive: Stronghold by RoaringCow, TehBigA is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.

This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 
444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

---------------------------------------------------------]]

require( "datastream" )

-- There is an inconsistency in the DMultiChoice derma file on the Linux side compared to Windows
-- This fixes it:
DMultiChoice.SetTextOld = DMultiChoice.SetText
function DMultiChoice.SetText( self, text )
	DMultiChoice.SetTextOld( self, text or "" )
end

-- Options menu
GM.OptionsFrame = nil

function GM:OptionsInit()
	self.OptionsFrame = vgui.Create( "sh_optionsmenu" )
	self.OptionsFrame:SetSize( 400, 600 )
	self.OptionsFrame:SetVisible( false )
	self.OptionsFrame:SetSkin( "stronghold" )
	
	self.OptionsFrame:AddOption( "HUD (Heads Up Display)", "CheckBox", "Show HUD", "sh_hudenabled" )
	self.OptionsFrame:AddOption( "HUD (Heads Up Display)", "CheckBox", "Hit Indicator", "sh_hitindicator" )
	self.OptionsFrame:AddOption( "HUD (Heads Up Display)", "CheckBox", "Hit Sound", "sh_hitsound" )
	
	self.OptionsFrame:AddOption( "Hit Indicator Color", "NumSlider", "Red", "sh_hitred", 0, 255, 3 )
	self.OptionsFrame:AddOption( "Hit Indicator Color", "NumSlider", "Green", "sh_hitgreen", 0, 255, 3 )
	self.OptionsFrame:AddOption( "Hit Indicator Color", "NumSlider", "Blue", "sh_hitblue", 0, 255, 3 )
	
	self.OptionsFrame:AddOption( "Voice Chat", "CheckBox", "Enabled", "voice_enable" )
	self.OptionsFrame:AddOption( "Voice Chat", "NumSlider", "Scale", "voice_scale", 0, 2, 2 )
	local channel = self.OptionsFrame:AddOption( "Voice Chat", "CheckBox", "Talk to team (Uncheck for public)" )
	function channel:OnChange( b ) RunConsoleCommand( "sh_voice_channel", b and 1 or 0 ) end
	self.OptionsFrame:AddOption( "Voice Chat", "CheckBox", "Always Hear Public", "sh_voice_alwayshearpublic" )
	self.OptionsFrame:AddOption( "Voice Chat", "CheckBox", "Always Hear Team", "sh_voice_alwayshearteam" )
	
	self.OptionsFrame:AddOption( "Effects", "CheckBox", "Muzzle Effects", "sh_fx_muzzleeffects" )
	self.OptionsFrame:AddOption( "Effects", "CheckBox", "Detailed Explosions", "sh_fx_explosiveeffects" )
	self.OptionsFrame:AddOption( "Effects", "CheckBox", "Detailed Bullet Impact Effects", "sh_fx_detailedimpacteffects" )
	self.OptionsFrame:AddOption( "Effects", "CheckBox", "Lingering Dust(From Bullet Impacts)", "sh_fx_smokeyimpacteffects" )
	self.OptionsFrame:AddOption( "Effects", "CheckBox", "Repair Tool Light", "sh_fx_dynamicweldlight" )

	self.OptionsFrame:AddOption( "Screen Effects", "CheckBox", "Show Hurt Blur", "sh_pp_hurtblur" )
	self.OptionsFrame:AddOption( "Screen Effects", "CheckBox", "Show Blood Splatter", "sh_pp_bloodsplat" )
	self.OptionsFrame:AddOption( "Screen Effects", "CheckBox", "Show Spawn Protection", "sh_pp_spawnprot" )
	self.OptionsFrame:AddOption( "Screen Effects", "CheckBox", "Show Vignette (Cheap texture)", "sh_pp_vignette" )
	self.OptionsFrame:AddOption( "Screen Effects", "NumSlider", "Vignette Opacity", "sh_pp_vignette_opacity", 1, 100, 0 )

	self.OptionsFrame:AddOption( "Tool Gun", "CheckBox", "Alternate Inputs", "sh_tool_altinput" )
	self.OptionsFrame:AddOption( "Tool Gun", "CheckBox", "Move Crosshair in Radial Menu", "sh_tool_radialshowmouse" )
	
	local radiallabel = vgui.Create( "DLabel" ) radiallabel:SetText( "Alternate Radial Input" ) 
	local radialmode = vgui.Create( "sh_multichoice" )
	radialmode.Stretch = true
	self.OptionsFrame:AddOption( "Tool Gun", "AddItem", radiallabel, radialmode )
	radialmode:AddChoice( "Normal" )
	radialmode:AddChoice( "Left <-> Right" )
	radialmode:AddChoice( "Up <-> Down" )
	radialmode:SetConVar( "sh_tool_radialmode" )
	
	self.OptionsFrame:AddOption( "Tool Gun", "NumSlider", "Alternate Radial Input Speed", "sh_tool_radialmode_speed", 0, 1, 2 )
	
	self.OptionsFrame:AddOption( "Prop Spawn Tool", "NumSlider", "Snap Degrees", "propspawn_snapdegrees", 1, 360, 0 )
	self.OptionsFrame:AddOption( "Prop Spawn Tool", "NumSlider", "Sensitivity", "propspawn_sensitivity", 0, 1, 3 )
	
	self.OptionsFrame:AddOption( "Repair Tool", "CheckBox", "Show Health Bar", "sh_repair_healthbar" )
	self.OptionsFrame:AddOption( "Repair Tool", "CheckBox", "Show actual numbers", "sh_repair_healthnum" )
	
	self.OptionsFrame:AddOption( "Miscellaneous", "NumSlider", "GBux offset from left side of screen", "sh_gbuxoffset", 0, ScrW()-150, 0 )
end

concommand.Add( "sh_options",
	function()
		if ValidPanel( GAMEMODE.OptionsFrame ) then
			GAMEMODE.OptionsFrame:Open()
		end
	end )

GM.TeamFrame = nil

function GM:TeamInit()
	self.TeamFrame = vgui.Create( "sh_teammenu" )
	self.TeamFrame:SetSize( 750, 550 )
	self.TeamFrame:SetVisible( false )
	self.TeamFrame:SetSkin( "stronghold" )
end

concommand.Add( "sh_teams",
	function()
		if ValidPanel( GAMEMODE.TeamFrame ) then
			GAMEMODE.TeamFrame:Open()
		end
	end )

GM.HelpFrame = nil

function GM:LoadoutInit()
	self.LoadoutFrame = vgui.Create( "sh_loadoutmenu" )
	self.LoadoutFrame:SetSize( 750, 550 )
	self.LoadoutFrame:SetVisible( false )
	self.LoadoutFrame:SetSkin( "stronghold" )
end

concommand.Add( "sh_loadout",
	function()
		if ValidPanel( GAMEMODE.LoadoutFrame ) then
			GAMEMODE.LoadoutFrame:Open()
		end
	end )
	
function GM:HelpInit()
	self.HelpFrame = vgui.Create( "sh_helpmenu" )
	self.HelpFrame:SetSize( 750, 550 )
	self.HelpFrame:SetVisible( false )
	self.HelpFrame:SetSkin( "stronghold" )
end

concommand.Add( "sh_help",
	function()
		if ValidPanel( GAMEMODE.HelpFrame ) then
			GAMEMODE.HelpFrame:Open()
		end
	end )
	
-- ----------------------------------------------------------------------------------------------------

local PANEL = {}

function PANEL:Init()
	self.TextEntry:SetEditable( false )
end

function PANEL:ChooseOption( value, index )
	if self.Menu then
		self.Menu:Remove()
		self.Menu = nil
	end

	self:SetText( value )
	--self.TextEntry:ConVarChanged( value )
	
	if self.m_strConVar and self.m_strConVar != "" then
		RunConsoleCommand( self.m_strConVar, index )
	end

	self:OnSelect( index, value, self.Data[index] )
end

function PANEL:SetConVar( convar )
	self.m_strConVar = convar
	local index = GetConVarNumber( convar )
	self:ChooseOption( self:GetOptionText(index), index )
end

vgui.Register( "sh_multichoice", PANEL, "DMultiChoice" )