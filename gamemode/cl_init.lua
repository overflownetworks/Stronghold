--[[-------------------------------------------------------

Fight to Survive: Stronghold by RoaringCow, TehBigA is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.

This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 
444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

---------------------------------------------------------]]

include( "glon.lua" ) -- This is manually added to prevent a Linux issue because Garry...
require( "datastream" )

--[[-------------------------------------------------------
  
  STRONGHOLD
  
---------------------------------------------------------]]

include( "shared.lua" )
include( "entity_extension.lua" )
include( "player_extension.lua" )
include( "spawnmenu.lua" )
include( "playersounds.lua" )

include( "cl_skin.lua" )
include( "cl_gbux.lua" )
include( "cl_hud.lua" )
include( "cl_teams.lua" )
include( "cl_spawnmenu.lua" )
include( "cl_panels.lua" )
include( "cl_screeneffects.lua" )
include( "cl_hats.lua" )

--include( "WHM.lua" )
--include( "Types/WHM_weather_snow.lua" )

include( "vgui/vgui_manifest.lua" )

-- Here we can add missing localization, Example: #worldspawn fix
language.Add( "worldspawn", "Gravity" )
language.Add( "env_explosion", "Explosion" )

-- Variables
-- Local client's info
GM.KillCam = {
	Active = false,
	StopTime = 0,
	Pos = Vector( 0, 0, 0 ),
	Killer = nil,
	LastKilled = 0
}

GM.Ragdolls = {}

function GM:Initialize()
	self:InitConVars()
	self:OptionsInit()
	self:TeamInit()
	self:LoadoutInit()
	self:HelpInit()
end

function GM:InitPostEntity()
	timer.Create(
		"sh_readyforinfo",
		5,
		0,
		function()
			if LocalPlayer():GetInitialized() == INITSTATE_ASKING then
				RunConsoleCommand( "sh_readyforinfo" )
			else
				timer.Remove( "sh_readyforinfo" )
			end
		end
	)
end

function GM.Reinitialize()
	Msg( "Reinitializing gamemode...\n" )
	GAMEMODE:Initialize()
	--GAMEMODE:InitPostEntity()
end
concommand.Add( "gamemode_reinitialize_cl", GM.Reinitialize )

function GM:Think()
	local curtime = CurTime()
	
	-- Ragdolls
		for i, tbl in ipairs(GAMEMODE.Ragdolls) do
			if IsValid( tbl.ent ) then
				local scale = math.Clamp( (curtime - tbl.time), 0, 1 ) * -1 + 1
				local alpha = 255 * scale
				tbl.ent:SetColor( alpha, alpha, alpha, alpha )
				if scale == 0 then
					table.remove( GAMEMODE.Ragdolls, i )
				end
			end
		end
	-- End Ragdolls

	-- Weapon switch
		local ply = LocalPlayer()
		local wep = ply:GetActiveWeapon()
		if ply.LastWeapon != wep then
			self:PlayerSwitchWeapon( ply, wep )
			ply.LastWeapon = wep
		end
	-- End Weapon switch

	if self.CountDownEnd != -1 and curtime >= self.CountDownEnd then
		local lua_to_run = self.CountDownLua
		self.CountDownEnd = -1
		self.CountDownTitle = ""
		self.CountDownLua = ""
		if lua_to_run and lua_to_run != "" then
			RunString( lua_to_run )
		end
	end
	
	self:ScreenEffectsThink()
	self:HatEffectsThink()
end

-- Various spawning functions
function GM:LimitHit( name )
	Msg( "You have hit the ".. name .." limit!\n" )
	chat.AddText( Color(200,50,50,255), Localize("#SBoxLimit_"..name) )
	surface.PlaySound( "buttons/button10.wav" )
end

function GM:OnUndo( name, strCustomString )
	Msg( name.." undone\n" )
	if !strCustomString then
		chat.AddText( Color(200,200,50,255), "#Undone_"..name )
	else	
		chat.AddText( Color(200,200,50,255), strCustomString )
	end
	surface.PlaySound( "buttons/button15.wav" )
end

-- Killcam stuff
GM.KillCam = {
	Active = false,
	StopTime = 0,
	Pos = Vector( 0, 0, 0 ),
	Killer = nil,
	LastKilled = 0
}

function LocalPlayer_Killed( um )
	GAMEMODE.KillCam.Killer = um:ReadEntity()
	GAMEMODE.KillCam.LastKilled = CurTime()
	GAMEMODE.KillCam.Active = true
end
usermessage.Hook( "sh_killed", LocalPlayer_Killed )

function LocalPlayer_Spawned( um )
	GAMEMODE.KillCam.Killer = nil
	GAMEMODE.KillCam.Active = false
end
usermessage.Hook( "sh_spawned", LocalPlayer_Spawned )

-- Overly complex camera calculations
local WalkTimer = 0
local VelSmooth = 0
local LastStrafeRoll = 0
local BreathSmooth = 0
local BreathTimer = 0
local LastCalcView = 0
local LastOrigin = nil
local ZSmoothOn = false -- Experimental
function GM:CalcView( ply, origin, angles, fov )
	if self.GameOver then
		return self.BaseClass:CalcView( ply, origin, angles, fov )
	end

	local deltatime = CurTime() - LastCalcView
	LastCalcView = CurTime()

	-- Experimental ZSmooth
	LastOrigin = LastOrigin or origin
	local dist = math.abs( origin.z - LastOrigin.z )
	if dist >= 1.5 then
		ZSmoothOn = true
	end
	if ZSmoothOn then
		local newz = math.Approach( LastOrigin.z, origin.z, dist*15*deltatime )
		if math.abs( newz - origin.z ) < 0.10 or !ply:IsOnGround() then
			ZSmoothOn = false
		else
			origin.z = newz
		end
	end
	LastOrigin = origin

	if !ply:Alive() and IsValid( GAMEMODE.KillCam.Killer ) and GAMEMODE.KillCam.Killer != ply then
		if GAMEMODE.KillCam.Active then
			GAMEMODE.KillCam.StopTime = CurTime()
			GAMEMODE.KillCam.Pos = GAMEMODE.KillCam.Killer:LocalToWorld(GAMEMODE.KillCam.Killer:OBBCenter())+Vector(0,0,16)
		end
		origin = ply:EyePos()
		angles = (GAMEMODE.KillCam.Pos-ply:EyePos()):Angle()
		fov = math.Max( 25, fov-((GAMEMODE.KillCam.StopTime-GAMEMODE.KillCam.LastKilled) * 10) )
		local tr = util.TraceLine( {start=origin,endpos=GAMEMODE.KillCam.Pos,filter=ply} )
		if tr.Entity != GAMEMODE.KillCam.Killer and tr.HitWorld then GAMEMODE.KillCam.Active = false end
		return self.BaseClass:CalcView( ply, origin, angles, fov )
	elseif !ply:Alive() or IsValid( ply:GetVehicle() ) then
		return self.BaseClass:CalcView( ply, origin, angles, fov )
	end

	local vel = (ply:OnGround() and ply:GetVelocity() or Vector(1,1,1))
	local speed = vel:Length()
	local onground = 1
	local ang = ply:EyeAngles()
	local bob = Vector( 10, 10, 10 )	

	VelSmooth = (math.Clamp(VelSmooth * 0.9 + speed * 0.07, 0, 700 ))
	WalkTimer = (ply:OnGround() and (WalkTimer + VelSmooth * FrameTime() * 0.04) or (WalkTimer + VelSmooth * FrameTime() * 0.001))
	
	BreathSmooth = math.Clamp( BreathSmooth * 0.9 + bob:Length() * 0.07, 0, 700 )
	BreathTimer = BreathTimer + BreathSmooth * FrameTime() * 0.04

	-- Roll on strafe (smoothed)
	LastStrafeRoll = (LastStrafeRoll * 3) + (ang:Right():DotProduct( vel ) * 0.0001 * VelSmooth * 0.3 ) // 0.3
	LastStrafeRoll = LastStrafeRoll * 0.18 // Change this
	angles.roll = angles.roll + LastStrafeRoll
	
	if ply:GetGroundEntity() != NULL then	
		angles.roll = angles.roll + math.sin( BreathTimer*0 ) * BreathSmooth * 0.00000003 * BreathSmooth
		angles.pitch = angles.pitch + math.cos( BreathTimer*3.5 ) * BreathSmooth*0.001 *ply:GetFOV()*0.006* BreathSmooth
		angles.yaw = angles.yaw + math.cos( BreathTimer*5 ) * BreathSmooth*0.0005 *ply:GetFOV()*0.006* BreathSmooth
	end
		
	local shakespeed = 0
	local shakespeed2 = 0
	local violencescale = 0 
	local violencescale2 = 0 

	if running then 
	shakespeed = 1.5
	shakespeed2 = 6
	violencescale = 0.01
	violencescale2 = 0.1
	end
	
	if !running then
	shakespeed = 1.2
	shakespeed2 = 2.2
	violencescale = 0.5
	violencescale2 = 0.2
	end


	if ply:GetGroundEntity() != NULL then	
			angles.roll = angles.roll + math.sin( WalkTimer*shakespeed ) * VelSmooth * (0.00003*violencescale2) * VelSmooth
			angles.pitch = angles.pitch + math.cos( WalkTimer*shakespeed2 ) * VelSmooth * (0.000012*violencescale) * VelSmooth
			angles.yaw = angles.yaw + math.cos( WalkTimer*shakespeed ) * VelSmooth * (0.000003*violencescale) * VelSmooth
	end


	local RUNPOS = math.Clamp(ply:GetAimVector().z*30, -20,50)
	local NEGRUNPOS = math.Clamp(ply:GetAimVector().z*-30, -20,0)
	local ret = self.BaseClass:CalcView( ply, origin, angles, fov )
	local running = ply:KeyDown(IN_SPEED) and ply:KeyDown(IN_FORWARD|IN_BACK|IN_MOVELEFT|IN_MOVERIGHT) 	
	local scale = ((running and 3 or 1) * 0.01)
	local wep = ply:GetActiveWeapon()

	if ret.vm_angles and !running then
		ret.vm_angles.roll = ret.vm_angles.roll + math.sin( BreathTimer*0 ) * BreathSmooth * 0.00000003 * BreathSmooth
		ret.vm_angles.pitch = ret.vm_angles.pitch + math.cos( BreathTimer*3.5 ) * BreathSmooth*-0.001 *ply:GetFOV()*0.006* BreathSmooth
		ret.vm_angles.yaw = ret.vm_angles.yaw + math.cos( BreathTimer*5 ) * BreathSmooth*0.0005 *ply:GetFOV()*0.006* BreathSmooth

	elseif ret.vm_angles and running then
	
		if	IsValid( wep ) and wep.ModelRunAnglePreset == 1 then
			ret.vm_angles.roll = ret.vm_angles.roll + math.sin( WalkTimer*2.2 ) * 0.02 * VelSmooth - NEGRUNPOS
			ret.vm_angles.pitch = ret.vm_angles.pitch + math.cos( WalkTimer*1 ) * 0.006 * VelSmooth
			ret.vm_angles.yaw = ret.vm_angles.yaw + math.cos( WalkTimer*.99 ) * 0.05 * VelSmooth
		
		elseif IsValid( wep ) and wep.ModelRunAnglePreset == 0  then
	
			ret.vm_angles.roll = ret.vm_angles.roll + math.sin( WalkTimer*2.2 ) * 0.02 * VelSmooth - RUNPOS
			ret.vm_angles.pitch = ret.vm_angles.pitch + math.cos( WalkTimer*1 ) * 0.006 * VelSmooth
			ret.vm_angles.yaw = ret.vm_angles.yaw + math.cos( WalkTimer*.99 ) * 0.05 * VelSmooth
			
		elseif IsValid( wep ) and wep.ModelRunAnglePreset == 2 then
	
			ret.vm_angles.roll = ret.vm_angles.roll + math.sin( WalkTimer*2.2 ) * 0.02 * VelSmooth - RUNPOS
			ret.vm_angles.pitch = ret.vm_angles.pitch + math.cos( WalkTimer*1 ) * 0.006 * VelSmooth
			ret.vm_angles.yaw = ret.vm_angles.yaw + math.cos( WalkTimer*.99 ) * 0.05 * VelSmooth
		end
	end
	
	local left = ply:GetRight() * -1
	local up = ang:Up()
	
	--Tool
	if IsValid( wep ) 
	and wep.ModelRunAnglePreset == 5 
	and !running then
	
	ret.vm_origin = ret.vm_origin + (math.sin( WalkTimer*1.8 ) * VelSmooth * 0.0025) * left + ((math.cos( WalkTimer*3.6 ) * VelSmooth * 1) * 0.001) * up
	end
	
	if IsValid( wep ) 
	and wep.ModelRunAnglePreset == 5 
	and running then
	
	ret.vm_origin = ret.vm_origin + (math.sin( WalkTimer*1 ) * VelSmooth * 0.005) * left + ((math.cos( WalkTimer*2 ) * VelSmooth * 0.001)) * up
	end
	
	--Weapons
	if ret.vm_origin 
	and wep.ModelRunAnglePreset != 5 
	and !running 
	and !ply:KeyDown(IN_ATTACK2) 
	or ply:KeyDown(IN_USE) and ply:KeyDown(IN_ATTACK2) and wep.ModelRunAnglePreset != 5 and !running 
	and !wep:GetIronsights() then
	
		ret.vm_origin = ret.vm_origin + (math.sin( WalkTimer*1.8 ) * VelSmooth * 0.0025) * left + ((math.cos( WalkTimer*3.6 ) * VelSmooth * 1) * 0.001) * up
	end
	
	if ret.vm_origin 
	and wep.ModelRunAnglePreset != 5
	and !running 
	and wep:GetIronsights() then
	
		ret.vm_origin = ret.vm_origin + (math.sin( WalkTimer*1.8 ) * VelSmooth * 0.0002) * left + ((math.cos( WalkTimer*3.6 ) * VelSmooth * 1) * 0.0001) * up
	end
	
	if ret.vm_origin 
	and wep.ModelRunAnglePreset != 5 
	and running and IsValid( wep ) 
	and wep.ModelRunAnglePreset == 3 then
	
		ret.vm_origin = ret.vm_origin + (math.sin( WalkTimer*1 ) * VelSmooth * 0.005) * left + ((math.cos( WalkTimer*2 ) * VelSmooth * 0.001)) * up
	end


	return ret
end

local LastDuckRelease = 0
local LastDuckState = false
function GM:CreateMove( cmd )
	local ducking = cmd:GetButtons() & IN_DUCK == IN_DUCK
	if ducking and RealTime() - LastDuckRelease <= 0.30 then
		cmd:SetButtons( cmd:GetButtons() - IN_DUCK )
	elseif !ducking and LastDuckState then
		LastDuckRelease = RealTime()
	end
	LastDuckState = ducking
end

local SND_CHANNELCHANGE = Sound( "buttons/lightswitch2.wav" )
function GM:PlayerBindPress( ply, bind, pressed ) 
	if string.find( string.lower(bind), "+menu_context" ) != nil or string.find( string.lower(bind), "noclip" ) != nil then
		ply:EmitSound( SND_CHANNELCHANGE, 70, 100 )
		RunConsoleCommand( "sh_voice_channel", self.ConVars.VoiceChannel:GetInt() == 0 and 1 or 0 )
	end
end

local function RecieveAdvert( um )
	GAMEMODE.LastAdvertColor = GAMEMODE.CurAdvertColor
	GAMEMODE.LastAdvertMsg = GAMEMODE.CurAdvertMsg
	GAMEMODE.CurAdvertColor = um:ReadShort()
	GAMEMODE.CurAdvertMsg = um:ReadString()
	GAMEMODE.LastAdvertChange = CurTime()
	--surface.PlaySound( "advert.wav" )
end
usermessage.Hook( "sh_advert", RecieveAdvert )

local function RecieveGameOver()
	GAMEMODE.GameOver = true
	LocalPlayer():SendMessage( "Game over!" )
end
usermessage.Hook( "sh_gameover", RecieveGameOver )

local function RecieveMapList( _, _, _, decoded )
	GAMEMODE.MapList = decoded
	for k, v in pairs(GAMEMODE.MapList) do
		if file.Exists( "../materials/maps/"..v.map..".vmt" ) then
			GAMEMODE.MapList[k].texture = surface.GetTextureID( "maps/"..v.map )
		end
	end
end
datastream.Hook( "sh_maplist", RecieveMapList )

local function RecieveWinningMap( um )
	GAMEMODE.WinningMap = um:ReadString()
	LocalPlayer():SendMessage( "Map '"..GAMEMODE.WinningMap.."' has won the vote!" )
end
usermessage.Hook( "sh_winningmap", RecieveWinningMap )

function GM:EnableVotingSystem()
	g_MapVotingPanel:SetEnabled( true )
	GAMEMODE.HelpFrame.Sections:SetActiveTab( GAMEMODE.HelpFrame.Sections.Items[3].Tab )
	GAMEMODE.HelpFrame:Open()
	LocalPlayer():SendMessage( "Voting has begun!" )
end

local function RecieveFadeRagdoll( um )
	local ragdoll = um:ReadEntity()
	if IsValid( ragdoll ) then
		table.insert( GAMEMODE.Ragdolls, {ent=ragdoll,time=CurTime()} )
	end
end
usermessage.Hook( "sh_faderagdoll", RecieveFadeRagdoll )
