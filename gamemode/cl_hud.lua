--[[-------------------------------------------------------

Fight to Survive: Stronghold by RoaringCow, TehBigA is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.

This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons,
444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

---------------------------------------------------------]]
local CONVARS = GM.ConVars
local GBux = GBux -- Speeds up slightly

surface.CreateFont( "DeathCamera", {
	font = "coolvetica",
	size = 48,
	weight = 700,
	antialias = true,
	additive = false,
})

surface.CreateFont("TabLarge", {
	font = "Tahoma",
	size = 13,
	weight = 700,
	shadow = true,
})

surface.CreateFont("Trebuchet19", {
	font = "Trebuchet MS",
	size = 19,
	weight = 900,
})

surface.CreateFont("DefaultBold", {
	font = "Tahoma",
	size = 13,
	weight = 1000,
})

surface.CreateFont("UiBold", {
	font = "Tahoma",
	size = 12,
	weight = 1000,
})




local TEX_GRADIENT_TOP = surface.GetTextureID( "vgui/gradient-u" )
local TEX_GRADIENT_BOTTOM = surface.GetTextureID( "vgui/gradient-d" )
local TEX_GRADIENT_RIGHT = surface.GetTextureID( "vgui/gradient-r" )
local TEX_GRADIENT_LEFT = surface.GetTextureID( "vgui/gradient-l" )
local TEX_GRADIENT_BOTTOMLEFT = surface.GetTextureID( "vgui/gradient-bl" )
local TEX_GRADIENT_BOTTOMRIGHT = surface.GetTextureID( "vgui/gradient-br" )

local TEX_HUDICONS = {}
--TEX_HUDICONS["health"] = surface.GetTextureID( "hudicons/health" )
TEX_HUDICONS["health2"] = surface.GetTextureID( "hudicons/health2" )
TEX_HUDICONS["shield"] = surface.GetTextureID( "hudicons/shield" )
TEX_HUDICONS["weapon_sh_c4"] = surface.GetTextureID( "hudicons/c4" )
TEX_HUDICONS["weapon_sh_flash"] = surface.GetTextureID( "hudicons/fnade" )
TEX_HUDICONS["weapon_sh_grenade"] = surface.GetTextureID( "hudicons/henade" )
TEX_HUDICONS["weapon_sh_smoke"] = surface.GetTextureID( "hudicons/snade" )

local TEX_STANCE_AIMING = surface.GetTextureID( "stance/aiming" )
local TEX_STANCE_AIMING_CROUCHED = surface.GetTextureID( "stance/aiming_crouched" )
local TEX_STANCE_RELAXED = surface.GetTextureID( "stance/relaxed" )
local TEX_STANCE_RELAXED_CROUCHED = surface.GetTextureID( "stance/relaxed_crouched" )

local TEX_FIREMODE_AUTO = surface.GetTextureID( "firemode/automatic" )
local TEX_FIREMODE_SEMIAUTO = surface.GetTextureID( "firemode/semiautomatic" )

local TEX_HITDETECTION = surface.GetTextureID( "hitdetection2" )

local HIT_COLOR_RED = GetConVarNumber("sh_hitred")
local HIT_COLOR_GREEN = GetConVarNumber("sh_hitgreen")
local HIT_COLOR_BLUE = GetConVarNumber("sh_hitblue")

local HitTime = 0
local HitTimeDuration = 0.10

--[[local SND_HITDETECTION = {
	Sound( "physics/body/body_medium_impact_hard2.wav" ),
	Sound( "physics/body/body_medium_impact_hard4.wav" ),
	Sound( "physics/body/body_medium_impact_hard6.wav" )
}]]

local SND_HITDETECTION = {
	Sound( "hit1.wav" ),
	Sound( "hit2.wav" ),
	Sound( "hit3.wav" )
}

-- Advert Stuff
local ADVERT_FADE_TIME = 2.00
GM.CurAdvertColor = 1 -- Using a color index for cached colors above
GM.CurAdvertMsg = ""
GM.LastAdvertColor = 1 -- ^
GM.LastAdvertMsg = ""
GM.LastAdvertChange = 0

-- Cached colors
local CachedColors = {}
CachedColors[1] =  Color( 255, 255, 255, 255 ) -- White
CachedColors[2] =  Color( 127, 127, 127, 255 ) -- Grey
CachedColors[3] =  Color( 255,   0,   0, 255 ) -- Red
CachedColors[4] =  Color(   0, 255,   0, 255 ) -- Green
CachedColors[5] =  Color(   0,   0, 255, 255 ) -- Blue
CachedColors[6] =  Color( 255, 255,   0, 255 ) -- Yellow
CachedColors[7] =  Color( 255, 128,   0, 255 ) -- Orange
CachedColors[8] =  Color(   0, 128, 255, 255 ) -- Teal
CachedColors[9] =  Color(   0, 255, 255, 255 ) -- Aqua
CachedColors[10] = Color( 255,   0, 255, 255 ) -- Violet

local function ColorBlend( scale, c1, c2 )
	scale = math.Clamp( scale, 0, 1 )
	local scale2 = -(scale-1)
	return Color( math.Clamp(math.floor(c1.r*scale2+c2.r*scale),0,255), math.Clamp(math.floor(c1.g*scale2+c2.g*scale),0,255), math.Clamp(math.floor(c1.b*scale2+c2.b*scale),0,255), math.Clamp(math.floor(c1.a*scale2+c2.a*scale),0,255) )
end

local function DrawBar( x, y, w, h, scale, right, color, col_scale )
	local bx, by = x+1, y+1
	local bh, bw = h-2, math.Round( (w-2) * scale )
	local bw_extra = math.Round( (w-2) - bw )

	surface.SetDrawColor( 0, 0, 0, 100 )
	surface.DrawRect( x, y, w, h )

	surface.SetDrawColor( color.r*col_scale, color.g*col_scale, color.b*col_scale, 120 )
	surface.DrawRect( (right and bx+bw_extra or bx), by, bw, bh )

	surface.SetDrawColor( 0, 0, 0, 150 )
	surface.SetTexture( TEX_GRADIENT_BOTTOM )
	surface.DrawTexturedRect( (right and bx+bw_extra or bx), by+bh*0.35, bw, bh*0.65 )

	surface.SetDrawColor( 255, 255, 255, 2 )
	surface.SetTexture( TEX_GRADIENT_TOP )
	surface.DrawTexturedRect( (right and bx+bw_extra or bx), by, bw, bh*0.65 )
end

function GM:HUDDrawTargetID()
end

local BlockedHUDElements = { "CHudHealth", "CHudBattery", "CHudAmmo" }
function GM:HUDShouldDraw( element )
	return !table.HasValue( BlockedHUDElements, element )
end

function GM:HUDPaint()
	self.BaseClass:HUDPaint()

	local sscale = ScrH() / 900 -- For scaling meters


	local initstate = LocalPlayer():GetInitialized()
	if initstate == INITSTATE_OK then
		self:DrawKillCam( sscale )
		GBux.HUDPaint()
		if CONVARS.HUDEnabled and CONVARS.HUDEnabled:GetBool() then self:DrawBasic( sscale ) end
		--self:DrawHitDetection()
		self:DrawAdvertBar( sscale )
	else
		self:DrawWaitingInfo( initstate )
	end

	local delta = CurTime() - HitTime
	if delta > HitTimeDuration or GetConVarNumber("sh_hitindicator") == 0 then return end
	surface.SetTexture( TEX_HITDETECTION )
	surface.SetDrawColor( GetConVarNumber("sh_hitred"), GetConVarNumber("sh_hitgreen"), GetConVarNumber("sh_hitblue"), ((-delta/HitTimeDuration)+1)*255 )
	surface.DrawTexturedRect( ScrW()*0.50-math.Clamp(16+(delta*300),16,32), ScrH()*0.50-math.Clamp(16+(delta*300),16,32), math.Clamp(32+(delta*600),32,64), math.Clamp(32+(delta*600),32,64) )
end

function GM:DrawWaitingInfo( state )
	local str
	if state == INITSTATE_WAITING then
		str = "Receiving information"
	else
		str = "Requesting information"
	end

	surface.SetFont( "DeathCamera" )
	local tw, th = surface.GetTextSize( str )

	local x, y, w, h = 0, math.floor(ScrH()*0.50-th*0.50-10), ScrW(), th+20
	surface.SetDrawColor( 0, 0, 0, 220 )
	surface.DrawRect( 0, 0, ScrW(), ScrH() )
	surface.DrawRect( x, y, w, h )
	surface.SetDrawColor( 200, 200, 200, 120 )
	surface.DrawRect( x, y+1, w, 1 )
	surface.DrawRect( x, y+h-2, w, 1 )

	surface.SetTextColor( 255, 255, 255, 255 )
	surface.SetTextPos( ScrW()*0.50-tw*0.50, y+15 )
	surface.DrawText( str )
end

function GM:DrawAdvertBar( sscale )
if GetConVarNumber( "sh_hudenabled" ) == 0 then
return end
	local w, h = ScrW(), 20
	local scale = math.Clamp( (CurTime() - self.LastAdvertChange) / ADVERT_FADE_TIME, 0, 1 )
	local scale_flash = math.Clamp( (CurTime() - self.LastAdvertChange) / 0.80, 0, 1 )
	local scale_flash_r = (-scale_flash+1)
	local lscale = -scale+1

	surface.SetDrawColor( 20, 20, 20, 120 )
	surface.DrawRect( 0, 0, ScrW(), 20 )
	surface.SetDrawColor( 200, 200, 200, 120 )
	surface.DrawLine( 0, 20, ScrW(), 20 )
	surface.SetDrawColor( 0, 0, 0, 120 )
	surface.DrawLine( 0, 21, ScrW(), 21 )
	draw.RoundedBox( 4, 2, 2, w-4, 16, Color(scale_flash_r*255,scale_flash_r*255,scale_flash_r*255,200+55*scale_flash_r) )

	-- Ticker
	surface.SetFont( "gbux_default" ) -- This font looks nice, keep it BUT REMEMBER IF GBUX FILE DOESN'T LOAD THE FONT COULD BE MISSING!!!
	surface.SetTextColor( 255, 255, 255, 220 )
	surface.SetTextPos( 5, 4 )
	surface.DrawText( "STRONGHOLD - F1:Help | F2:Teams | F3:Loadout | F4:Options" )

	surface.SetFont( "Trebuchet19" )
	if scale > 0 then
		local c = CachedColors[self.CurAdvertColor or 1] or CachedColors[1]
		local tw, _ = surface.GetTextSize( self.CurAdvertMsg )
		surface.SetTextPos( w*0.50-tw*0.50, 1 )
		surface.SetTextColor( c.r, c.g, c.b, c.a*scale )
		surface.DrawText( self.CurAdvertMsg )
	end
	if lscale > 0 then
		local c = CachedColors[self.LastAdvertColor or 1] or CachedColors[1]
		local tw, _ = surface.GetTextSize( self.LastAdvertMsg )
		surface.SetTextPos( w*0.50-tw*0.50, 1 )
		surface.SetTextColor( c.r, c.g, c.b, c.a*lscale )
		surface.DrawText( self.LastAdvertMsg )
	end

	-- Timer
	if self.CountDownEnd != -1 and self.CountDownTitle != "" and self.CountDownEnd-CurTime() <= 600 then
		local timeleft = math.max( 0, self.CountDownEnd-CurTime() )
		local countdown = Format( "%02d.%02d", math.floor(timeleft/60), math.floor(timeleft%60) )

		surface.SetTextColor( 255, 255, 255, 220 )

		surface.SetFont( "gbux_defaultbold" )
		local tw, _ = surface.GetTextSize( countdown )
		surface.SetTextPos( w-tw-5, 4 )
		surface.DrawText( countdown )

		surface.SetFont( "Trebuchet19" )
		local tw2, _ = surface.GetTextSize( self.CountDownTitle.." - " )
		surface.SetTextPos( w-tw-tw2-8, 1 )
		surface.DrawText( self.CountDownTitle.." - " )
	end
end

function GM:DrawBasic( sscale )
	local ply = LocalPlayer()

	local wep = ply:GetActiveWeapon()
	local doammo = (IsValid( wep ) and wep:Clip1() != -1 and wep.Primary.ClipSize != -1)

	local nadeclass = ply:GetLoadoutExplosive()
	local donade
	for _, v in ipairs(ply:GetWeapons()) do if v:GetClass() == nadeclass then donade = true end end

	local sw, sh = ScrW(), ScrH()
	local w, h = 256, 72 --math.floor( 256*sscale ), math.floor( 72*sscale )
	local h_actual = h*2
	local color = team.GetColor( ply:Team() )

	-- Draw the background
	surface.SetDrawColor( 0, 0, 0, 100 )
	surface.DrawRect( 0, ScrH()-h, w, h )

	surface.SetDrawColor( color.r*0.50, color.g*0.50, color.b*0.50, 100 )
	surface.SetTexture( TEX_GRADIENT_BOTTOMLEFT )
	surface.DrawTexturedRect( 0, ScrH()-h, w, h_actual )

	surface.SetDrawColor( 200, 200, 200, 200 )
	surface.SetTexture( TEX_GRADIENT_LEFT )
	surface.DrawTexturedRect( 0, ScrH()-h+1, w, 1 )
	surface.SetTexture( TEX_GRADIENT_BOTTOM )
	surface.DrawTexturedRect( w-1, ScrH()-h+1, 1, h-1 )

	-- Left side
	if !ply.LastHurt or !ply.LastHeal then ply.LastHurt = 0 ply.LastHeal = 0 end
	local hp, ar, armax = math.max(ply:Health(),0), ply:GetCount( "props" ), GetConVarNumber("sbox_maxprops")
	local lasthurt = math.Clamp( (CurTime()-ply.LastHurt) / 0.60, 0, 1 )
	local lastheal = math.Clamp( (CurTime()-ply.LastHeal) / 0.30, 0, 1 )
	local hpcolor = (lasthurt < 1 and ColorBlend( lasthurt, Color(255,0,0,255), color )) or (lastheal < 1 and ColorBlend( lastheal, Color(0,255,0,255), color )) or color

	--if ply:IsGold() then armax = armax + 10 elseif ply:IsPlatinum() then armax = armax + 20 end
	local x, y = 0, sh-h
	local bar = 27
	DrawBar( x+5, y+7, w-12, bar, (hp/100), false, hpcolor, 1 )
	DrawBar( x+5, y+bar+12, w-12, bar, -(ar/armax)+1, false, color, 0.60 )

	surface.SetTexture( TEX_GRADIENT_BOTTOM )
	for i=1, armax do
		surface.SetDrawColor( 0, 0, 0, 120*(-i/armax+1) )
		surface.DrawTexturedRect( x+5+((w-12)/armax)*i, y+38, 1, bar )
	end

	surface.SetFont( "TabLarge" )
	surface.SetTextColor( 255, 255, 255, 255 )

	local tw, th = surface.GetTextSize( hp )
	local hp_x, hp_y = w-18-tw, y+7+bar*0.50-th*0.50
	surface.SetTextPos( hp_x, hp_y )
	surface.DrawText( hp )

	local tw, th = surface.GetTextSize( armax-ar )
	local ar_x, ar_y = w-18-tw, y+39+bar*0.50-th*0.50
	surface.SetTextPos( ar_x, ar_y )
	surface.DrawText( armax-ar )

	-- Voice Channel
	surface.SetTexture( TEX_GRADIENT_LEFT )
	surface.SetDrawColor( 0, 0, 0, 100 )
	surface.DrawTexturedRect( 0, ScrH()-h-20, 150, 20 )
	surface.SetDrawColor( 200, 200, 200, 200 )
	surface.DrawTexturedRect( 0, ScrH()-h-19, 150, 1 )

	local tw, th = surface.GetTextSize( "Voice Channel: " )
	surface.SetTextPos( 5, ScrH()-h-9-th*0.50 )
	surface.DrawText( "Voice Channel: " )

	local voicechannel = self.ConVars.VoiceChannel:GetInt()
	surface.SetTextColor( voicechannel == 1 and color or Color(250,250,0,255) )
	surface.DrawText( voicechannel == 0 and "Public" or "Team" )

	surface.SetTextColor( 255, 255, 255, 255 )

	-- Right side
	if doammo or donade then
		local firemode_extend = 0
		if doammo and IsValid( wep ) and wep.FireSelect == 1 then firemode_extend = 37 end

		local h = math.max( (doammo and 36 or 0) + (donade and 36 or 0), 39 )

		surface.SetDrawColor( 0, 0, 0, 100 )
		surface.DrawRect( ScrW()-w-firemode_extend, ScrH()-h, w+firemode_extend, h )

		surface.SetDrawColor( color.r*0.50, color.g*0.50, color.b*0.50, 100 )
		surface.SetTexture( TEX_GRADIENT_BOTTOMRIGHT )
		surface.DrawTexturedRect( ScrW()-w-firemode_extend, ScrH()-h, w+firemode_extend, h_actual )

		surface.SetDrawColor( 200, 200, 200, 200 )
		surface.SetTexture( TEX_GRADIENT_RIGHT )
		surface.DrawTexturedRect( ScrW()-w-firemode_extend, ScrH()-h+1, w+firemode_extend, 1 )
		surface.SetTexture( TEX_GRADIENT_BOTTOM )
		surface.DrawTexturedRect( ScrW()-w+1-firemode_extend, ScrH()-h+1, 1, h-1 )
	end

	local x, y = sw-w, sh-h
	local bar = 27

	if donade and TEX_HUDICONS[nadeclass] then
		surface.SetTexture( TEX_HUDICONS[nadeclass] )
		surface.SetDrawColor( 255, 255, 255, 255 )
		for i=1, (nadeclass == "weapon_sh_c4" and 1 or ply:GetAmmoCount( "grenade" )) do
			surface.DrawTexturedRect( sw-20*i-14, sh-34-(doammo and 32 or 0), 32, 32 )
		end
	end

	if doammo then
		local ammoflash = math.sin( RealTime() * 10 )
		local ammo = (wep:Clip1()/wep.Primary.ClipSize)
		local ammodelta = (w-12) / wep.Primary.ClipSize
		local ammocolor = (ammo < 0.25 and ColorBlend( ammoflash, Color(255,0,0,255), Color(150,150,150,100) )) or Color(150,150,150,100)
		DrawBar( x+7, y+40, w-12, bar, ammo, true, ammocolor, 1 )

		if ammodelta > 2 then
			surface.SetTexture( TEX_GRADIENT_BOTTOM )
			for i=1, wep.Primary.ClipSize do
				surface.SetDrawColor( 0, 0, 0, 120*(-i/wep.Primary.ClipSize+1) )
				surface.DrawTexturedRect( x+w-6-ammodelta*i, y+40, 1, bar )
			end
		end

		if ammo == 0 then
			surface.SetDrawColor( 255, 50, 50, 255*((ammoflash+1)*0.50) )
			surface.DrawLine( x+7, y+40, x+w-5, y+40 )
			surface.DrawLine( x+w-5, y+40, x+w-5, y+bar+40 )
			surface.DrawLine( x+7, y+bar+40, x+w-5, y+bar+40 )
			surface.DrawLine( x+7, y+40, x+7, y+bar+40 )
		end

		local str = "x "..math.ceil( ply:GetAmmoCount(wep:GetPrimaryAmmoType()) / wep.Primary.ClipSize )
		local tw, th = surface.GetTextSize( str )
		local mag_x, mag_y = sw-15-tw, y+39+bar*0.50-th*0.50
		surface.SetFont( "TabLarge" )
		surface.SetTextColor( 255, 255, 255, 255 )
		surface.SetTextPos( mag_x, mag_y )
		surface.DrawText( str )

		if IsValid( wep ) and wep.FireSelect == 1 then
			surface.SetDrawColor( 0, 0, 0, 100 )
			surface.DrawRect( x-27, y+40, 27, 27 )

			if wep.Primary.Automatic then
				surface.SetDrawColor( 0, 0, 0, 200 )
				surface.DrawRect( x-27+12, y+48, 5, 5 )
				surface.DrawRect( x-27+8, y+55, 5, 5 )
				surface.DrawRect( x-27+16, y+55, 5, 5 )

				surface.SetDrawColor( 255, 255, 255, 200 )
				surface.DrawRect( x-27+13, y+49, 3, 3 )
				surface.DrawRect( x-27+9, y+56, 3, 3 )
				surface.DrawRect( x-27+17, y+56, 3, 3 )
			else
				surface.SetDrawColor( 0, 0, 0, 200 )
				surface.DrawRect( x-27+12, y+52, 5, 5 )

				surface.SetDrawColor( 255, 255, 255, 200 )
				surface.DrawRect( x-27+13, y+53, 3, 3 )
			end
		end
	end

		--[[Firemode
		if IsValid( wep ) and wep.FireSelect == 1 then
			if wep.Primary.Automatic then
				surface.SetTexture( TEX_FIREMODE_AUTO )
			else
				surface.SetTexture( TEX_FIREMODE_SEMIAUTO )
			end
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.DrawTexturedRect( sw-54, sh-(donade and h or 36)-54, 48, 48 )
		end]]
end

function GM:DrawKillCam( sscale )
	local killer = GAMEMODE.KillCam.Killer
	if !IsValid( killer ) then LastDied = CurTime() + 6.1 return end

	surface.SetDrawColor( 0, 0, 0, 150 )
	surface.DrawRect( 0, ScrH()*0.65-75, ScrW(), 150 )
	if LastDied > CurTime() then
		local str = "Respawn in: "..math.floor(LastDied - CurTime(), 2).." Seconds"
		surface.SetFont( "DeathCamera" )
		local tw, th = surface.GetTextSize( str )
		surface.SetTextColor( 255, 50, 50, 255 )
		surface.SetTextPos( ScrW()/2-tw/2, ScrH()*0.61-th/2 )
		surface.DrawText( str )
	else
		local str = "Click or press Spacebar to spawn!"
		surface.SetFont( "DeathCamera" )
		local tw, th = surface.GetTextSize( str )
		surface.SetTextColor( 50, 255, 50, 255 )
		surface.SetTextPos( ScrW()/2-tw/2, ScrH()*0.61-th/2 )
		surface.DrawText( str )
	end

	local str = "You were killed by "..(killer.GetName and killer:GetName() or killer:GetClass()).."!"
	surface.SetFont( "DeathCamera" )
	local tw, th = surface.GetTextSize( str )
	surface.SetTextColor( 255, 255, 255, 255 )
	surface.SetTextPos( ScrW()/2-tw/2, ScrH()*0.65-th/2 )
	surface.DrawText( str )

	local hp, hpmax = killer:Health(), (killer:IsPlayer() and 100 or killer:GetMaxHealth())
	local scale = math.Clamp( hp/ hpmax, 0, 1 )
	local x, y, w, h = ScrW()/2-150, ScrH()*0.65+30, 300, 30
	draw.RoundedBox( 4, x, y, w, h, Color(20,20,20,150) )
	surface.SetDrawColor( 0, 0, 0, 150 )
	surface.DrawRect( x+5, y+5, w-10, h-10 )
	surface.SetDrawColor( 255*(-scale+1), 255*scale, 0, 200 )
	surface.DrawRect( x+5, y+5, (w-10)*scale, h-10 )

	surface.SetFont( "Trebuchet19" )

	local str = "HP:"
	local tw, th = surface.GetTextSize( str )
	local hp_x, hp_y = x+10, y+h/2-th/2
	surface.SetTextColor( 0, 0, 0, 255 )
	surface.SetTextPos( hp_x+1, hp_y+1 )
	surface.DrawText( str )
	surface.SetTextColor( 255, 255, 255, 255 )
	surface.SetTextPos( hp_x, hp_y )
	surface.DrawText( str )

	local tw, th = surface.GetTextSize( hp )
	local hp_x, hp_y = math.max(x+5+(w-10)*scale-tw-5,x+35), y+h/2-th/2
	surface.SetTextColor( 0, 0, 0, 255 )
	surface.SetTextPos( hp_x+1, hp_y+1 )
	surface.DrawText( hp )
	surface.SetTextColor( 255, 255, 255, 255 )
	surface.SetTextPos( hp_x, hp_y )
	surface.DrawText( hp )
end

local function RecieveHitDetection( um )
	HitTime = CurTime()
	if GetConVarNumber("sh_hitsound") == 0 then return end
	surface.PlaySound( table.Random(SND_HITDETECTION) )
	surface.PlaySound( table.Random(SND_HITDETECTION) )
	surface.PlaySound( table.Random(SND_HITDETECTION) )
end
usermessage.Hook( "sh_hitdetection", RecieveHitDetection )
