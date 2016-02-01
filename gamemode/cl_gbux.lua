--[[-------------------------------------------------------

Fight to Survive: Stronghold by RoaringCow, TehBigA is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.

This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 
444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

---------------------------------------------------------]]
local CONVARS = GM.ConVars

local UTIL_FormatMoney = UTIL_FormatMoney
local UTIL_PRound = UTIL_PRound

surface.CreateFont( "Default", 14, 700, true, false, "gbux_bigbold" )
surface.CreateFont( "Default", 12, 700, true, false, "gbux_defaultbold" )
surface.CreateFont( "Default", 12, 500, true, false, "gbux_default" )

GBux = {}
GBux.money = 0
GBux.multiplier = 0
GBux.kills = 0
GBux.deaths = 0

local TEX_GRADIENT = surface.GetTextureID( "gui/gradient_down" )
function GBux.HUDPaint()
if GetConVarNumber( "sh_hudenabled" ) == 0 then
return end
	local x, y, w, h = CONVARS.GBux_Offset:GetInt(), 21, 150, 80
	local ply = LocalPlayer()

	-- Background
	surface.SetDrawColor( 20, 20, 20, 120 )
	surface.DrawRect( x, y, w, h )
	
	surface.SetDrawColor( 0, 0, 0, 120 )
	surface.DrawRect( x, y, 1, h-1 )
	surface.DrawRect( x, y+h-1, w, 1 )
	surface.DrawRect( x+w-1, y, 1, h-1 )
	
	surface.SetDrawColor( 200, 200, 200, 120 )
	surface.DrawRect( x+1, y, 1, h-2 )
	surface.DrawRect( x+1, y+h-2, w-2, 1 )
	surface.DrawRect( x+w-2, y, 1, h-2 )
	
	surface.SetDrawColor( 0, 0, 0, 120 )
	surface.SetTexture( TEX_GRADIENT )
	surface.DrawTexturedRect( x+1, y, w-2, h*0.50 )
	
	surface.SetFont( "gbux_bigbold" )
	surface.SetTextColor( 255, 255, 255, 220 )
	
	local tw, th = surface.GetTextSize( "GBux" )
	surface.SetTextPos( x+w*0.50-tw*0.50, y+3 )
	surface.DrawText( "GBux" )
	
	-- Lables
	surface.SetFont( "gbux_defaultbold" )
	
	surface.SetTextPos( x+8, y+22 )
	surface.DrawText( "Money:" )
	
	surface.SetTextPos( x+8, y+34 )
	surface.DrawText( "Multiplier:" )
	
	surface.SetTextPos( x+8, y+46 )
	surface.DrawText( "Kills:" )
	
	surface.SetTextPos( x+8, y+58 )
	surface.DrawText( "Deaths:" )
	
	-- Amounts
	surface.SetFont( "gbux_default" )
	
	local money = UTIL_PRound( ply:GetMoney(), 2 )
	surface.SetTextPos( x+74, y+22 )
	surface.DrawText( UTIL_FormatMoney(money) )
	
	surface.SetTextPos( x+80, y+34 )
	surface.DrawText( ply:GetMultiplier() )
	
	surface.SetTextPos( x+80, y+46 )
	surface.DrawText( ply:Frags() )
	
	surface.SetTextPos( x+80, y+58 )
	surface.DrawText( ply:Deaths() )
end

local function RecieveInfo( um )
	GBux.money = um:ReadFloat()
	GBux.multiplier = um:ReadShort()
	GBux.kills = um:ReadShort()
	GBux.deaths = um:ReadShort()
end
usermessage.Hook( "gbux_recieveinfo", RecieveInfo )