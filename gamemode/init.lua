--[[-------------------------------------------------------

Fight to Survive: Stronghold by RoaringCow, TehBigA is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.

This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons,
444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

---------------------------------------------------------]]

include( "glon.lua" ) -- This is manually added to prevent a Linux issue because Garry...
AddCSLuaFile( "glon.lua" )


include( "resources.lua" )
--include( "sqlx.lua" )

include( "shared.lua" )
include( "entity_extension.lua" )
include( "player_extension.lua" )
include( "player.lua" )
include( "teams.lua" )
include( "loadout.lua" )
include( "spawnmenu.lua" )
include( "playersounds.lua" )
include( "voting.lua" )
include( "gbux.lua" )
--include( "treelights.lua" )

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "entity_extension.lua" )
AddCSLuaFile( "player_extension.lua" )
AddCSLuaFile( "spawnmenu.lua" )
AddCSLuaFile( "playersounds.lua" )

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_skin.lua" )
AddCSLuaFile( "cl_gbux.lua" )
AddCSLuaFile( "cl_hud.lua" )
AddCSLuaFile( "cl_teams.lua" )
AddCSLuaFile( "cl_spawnmenu.lua" )
AddCSLuaFile( "cl_panels.lua" )
AddCSLuaFile( "cl_screeneffects.lua" )
AddCSLuaFile( "cl_hats.lua" )

--AddCSLuaFile( "WHM.lua" )
--AddCSLuaFile( "Types/WHM_weather_snow.lua" )
util.AddNetworkString( "sh_items" )
util.AddNetworkString( "sh_item" )
util.AddNetworkString( "sh_licenses" )
util.AddNetworkString( "sh_license" )
util.AddNetworkString( "sh_loadouts" )
util.AddNetworkString( "sh_loadout" )
util.AddNetworkString( "sh_statistics" )
util.AddNetworkString( "sh_maplist" )

include( "vgui/vgui_manifest.lua" )
AddCSLuaFile( "vgui/vgui_manifest.lua" )

cvars.AddChangeCallback( "mp_fraglimit", function(_,_,new) SetGlobalInt("mp_fraglimit",tonumber(new)) end )
cvars.AddChangeCallback( "mp_timelimit",
	function(_,_,new)
		if GAMEMODE.GameOver then return end
		new = tonumber( new )
		if new > 0 then
			GAMEMODE:StartCountDown( (new*60)-(CurTime()-(GAMEMODE.LastGameReset or 0)), "Timelimit is up in", "", "" )
		else
			GAMEMODE:CancelCountDown()
		end
	end )

-- Breakable Entities Info | Most of this is from FTS 1
local BreakableEntities = { "prop_physics", "prop_magnet", "gmod_turret", "gmod_thruster", "gmod_wheel", "gmod_spawner", "prop_vehicle_jeep", "prop_vehicle_airboat", "prop_vehicle_jeep_old", "sent_spawnpoint", "gmod_cameraprop", "sent_turret_base", "sent_turret_mount", "sent_turret_mountable", "sent_weaponcrate" }
local DefaultHealths = { prop_physics=1000, prop_dynamic=1000, prop_magnet=1000, prop_vehicle_jeep=1500, prop_vehicle_jeep_old=1500, prop_vehicle_airboat=1500, sent_spawnpoint=20, sent_turret_base=50, sent_turret_mount=50, sent_turret_mountable=50, sent_weaponcrate=250 }
local PropBuildingSound = Sound( "ambient/energy/electric_loop.wav" )
GM.BuildingProps = {}

-- Adverst Info
GM.Adverts = {}    -- Loaded from file
GM.AdvertTime = 30 -- In Seconds
GM.CurrentAdvert = 1

GM.KeyReplacements = {}
GM.KeyReplacements["{HOSTNAME}"] = function() return GetHostName() end
GM.KeyReplacements["{TIMELIMIT}"] = function() local t = (GetConVarNumber( "mp_timelimit" )*60) return Format("%01d:%02d",math.floor(t/60),math.floor(t%60)) end
GM.KeyReplacements["{TIMELEFT}"] = function() local t = (GetConVarNumber( "mp_timelimit" )*60) - (CurTime()-(GAMEMODE.LastGameReset or 0)) return Format("%01d:%02d",math.floor(t/60),math.floor(t%60)) end
GM.KeyReplacements["{FRAGLIMIT}"] = function() return GetConVarNumber( "mp_fraglimit" ) end
GM.KeyReplacements["{SERVERTIME}"] = function() return os.date("%H:%M:%S %z") end
GM.KeyReplacements["{CURRENTMAP}"] = function() return game.GetMap() end
GM.KeyReplacements["{NEXTMAP}"] = function() return game.GetMapNext() end

-- Ragdoll Info
GM.Ragdolls = {}

function GM.Reinitialize( ply )
	if !IsValid( ply ) or ply:IsSuperAdmin() then
		Msg( "Reinitializing gamemode...\n" )
		GAMEMODE:Initialize()
		GAMEMODE:InitPostEntity()
		for _, v in ipairs(player.GetAll()) do
			v:ConCommand( "gamemode_reinitialize_cl" )
		end
	end
end
concommand.Add( "gamemode_reinitialize", GM.Reinitialize )

function GM:Initialize()
	self:InitConVars()
	self:LoadAdverts()
	self:LoadMapList()
end

local CFGPATH = "sh_adverts.txt"
function GM:LoadAdverts( ply )
	if IsValid( ply ) and !ply:IsAdmin() then return end

	self.Adverts = {}
	self.CurrentAdvert = 1

	if file.Exists( CFGPATH, "DATA" ) then
		local data = file.Read( CFGPATH, "DATA" )
		local tbl = string.Explode( "\n", data )
		for _, v in ipairs(tbl) do
			local sep = string.find( v, ";" )
			if sep and string.Left( v, 2 ) != "//" then
				table.insert( self.Adverts, {color=tonumber(string.Left(v,sep-1)),text=string.sub(v,sep+1)} )
			end
		end
	else
		file.Write( CFGPATH, [[// Keys:
//   {HOSTNAME}
//   {TIMELIMIT}
//   {TIMELEFT}
//   {FRAGLIMIT}
//   {SERVERTIME}
//   {CURRENTMAP}
//   {NEXTMAP}
//
// Colors:
//   1  = White
//   2  = Grey
//   3  = Red
//   4  = Green
//   5  = Blue
//   6  = Yellow
//   7  = Orange
//   8  = Teal
//   9  = Aqua
//   10 = Violet
//
// Console Command 'sh_reloadadverts' reloads this file into the advert system.

1;If you experience performance issues, try turning off effects in the options menu.
4;Hold right click with the toolgun and move your mouse to switch tool modes.
7;It's a good idea to create more than one spawnpoint.
9;Spawn protection will protect you for 4 seconds unless you shoot or ironsight.
3;Money farming is considered cheating.]] )
		self.Adverts[1] = { color=1, text="This is in white." }
		self.Adverts[2] = { color=3, text="This is in red!" }
	end
end
concommand.Add( "sh_reloadadverts", function() GAMEMODE:LoadAdverts() end )

local function AdvertTimer()
	if #GAMEMODE.Adverts == 0 then return end

	for _, v in ipairs(player.GetHumans()) do
		if IsValid( v ) then
			umsg.Start( "sh_advert", v )
				umsg.Short( (GAMEMODE.Adverts[GAMEMODE.CurrentAdvert] and GAMEMODE.Adverts[GAMEMODE.CurrentAdvert].color) or 1 )
				local str = (GAMEMODE.Adverts[GAMEMODE.CurrentAdvert] and GAMEMODE.Adverts[GAMEMODE.CurrentAdvert].text) or ""
				for k, v in pairs(GAMEMODE.KeyReplacements) do str = string.gsub( str, k, tostring( GAMEMODE.KeyReplacements[k]() ) ) end
				umsg.String( str )
			umsg.End()
		end
	end

	GAMEMODE.CurrentAdvert = GAMEMODE.CurrentAdvert + 1
	if GAMEMODE.CurrentAdvert > #GAMEMODE.Adverts then GAMEMODE.CurrentAdvert = 1 end
end
timer.Create( "SH_Adverts", GM.AdvertTime, 0, AdvertTimer )

--[[function GM:Shutdown()
	for _, v in ipairs(player.GetHumans()) do
		GBux.PlayerDisconnected( GBux.PlayerDisconnected( ply ) )
	end
end]]

local HealthRegenLast = 0
local HealthRegenDelay = 0.15
local DataSaveLast = 0
local DataSaveDelay = 300
local GBuxSendLast = 0
local GBuxSendDelay = 1
local RagdollTime = 5 -- Time not including 1 second fade
local RagdollMax = 5
local PropBuildTime = 10
local PropBuildLast = 0
function GM:Think()
	if lprof then lprof.PushScope( "SH - Think" ) end
	local curtime = CurTime()
		for _, ply in ipairs(player.GetAll()) do
			if curtime - ply:GetLastSpawn() > 4 and ply.IsGod and ply:GetCount( "spawnpoints" ) == 0 or ply:GetCount( "spawnpoints" ) > 0 and curtime - ply:GetLastSpawn() > 0.1 and ply.IsGod then
				if ply:GetCount( "spawnpoints" ) > 0 then
					ply:SendMessage( "Spawn protection disabled for Mobile Spawn Points.")
				end
				ply.IsGod = false
				ply:GodDisable()
				ply:SetMaterial( "" )
				ply:SetColor( Color(255, 255, 255, 255) )
				umsg.Start( "sh_spawnprotection", ply )
				  umsg.Bool( false )
				umsg.End()
				return
			end
		end
	-- Ragdolls
		local instant_fade_count = #GAMEMODE.Ragdolls - RagdollMax
		for i, tbl in ipairs(GAMEMODE.Ragdolls) do
			local deltatime = curtime - tbl.time

			if instant_fade_count > 0 and deltatime < (RagdollTime-1) then
				tbl.time = curtime - RagdollTime + 1
			end
			instant_fade_count = instant_fade_count - 1

			if deltatime >= RagdollTime then
				if IsValid( tbl.ent ) then tbl.ent:Remove() end
				table.remove( GAMEMODE.Ragdolls, i )
			elseif deltatime >= (RagdollTime-1) and !tbl.fading then
				tbl.fading = true
				local rf = RecipientFilter()
				rf:AddAllPlayers()
				umsg.Start( "sh_faderagdoll", rf )
					umsg.Entity( tbl.ent )
				umsg.End()
			end
		end
	-- End Ragdolls

	-- Building Props
	for ent, time in pairs(GAMEMODE.BuildingProps) do
			if !IsValid( ent ) then
				GAMEMODE.BuildingProps[ent] = nil
			else
				local hp = ent:Health()
				local hpmax = ent:GetMaxHealth()
				hp = hp + ((curtime-PropBuildLast) / ent.BuildTime) * hpmax
				local scale = hp / hpmax

				if scale >= 1 then
					GAMEMODE.BuildingProps[ent] = nil
					ent:SetHealth( ent:GetMaxHealth() )
					ent:SetColor( Color(255, 255, 255, 255) )
					if ent.BuildSound then ent.BuildSound:Stop() ent.BuildSound = nil end
					ent:BuildingSolidify()
				else
					ent:SetHealth( hp )
					ent:SetColor( Color( 255, 255, 255, 55 + 200 * scale) )
				end
			end
		end
		PropBuildLast = curtime
	-- Building Props End

	-- Weapon switch
		for _, v in ipairs(player.GetAll()) do
			local wep = v:GetActiveWeapon()
			if v.LastWeapon != wep then
				self:PlayerSwitchWeapon( v, wep )
				v.LastWeapon = wep
			end
		end
	-- End Weapon switch

	-- Data Save
		if curtime - DataSaveLast >= DataSaveDelay then
			if lprof then lprof.PushScope( "SH - Save Data" ) end

			for _, v in ipairs(player.GetHumans()) do
				v:SaveData()
			end
			DataSaveLast = curtime

			if lprof then lprof.PopScope() end
		end
	-- End Data Save

	-- GBux Send
		for _, v in ipairs(player.GetHumans()) do
			v:SetLastKill( v:GetLastKill() or 0 )
			if curtime - v:GetLastKill() >= 60 then
				v:AddMultiplier( -1 )
				v:SetLastKill( curtime )
			end
		end

		if curtime - GBuxSendLast >= GBuxSendDelay then
			for _, v in ipairs(player.GetHumans()) do
				v:AddMoney( GAMEMODE.ConVars.GBuxMPM:GetFloat() / 60 * GBuxSendDelay * v:GetMultiplier() )
				v:SendMoneyAndMultiplier()
			end
			GBuxSendLast = curtime
		end
	-- End GBux Send

	-- Counter
		if self.CountDownEnd != -1 and curtime >= self.CountDownEnd then
			local lua_to_run = self.CountDownLua
			self.CountDownEnd = -1
			self.CountDownTitle = ""
			self.CountDownLua = ""
			if lua_to_run and lua_to_run != "" then
				RunString( lua_to_run )
			end
		end
	-- End Counter

	if self.GameOver then
		local timelimit = GAMEMODE.ConVars.TimeLimit:GetFloat()
		local votingenabled = GAMEMODE.ConVars.VoteEnabled:GetBool()

		local timepassed = (CurTime() - self.LastGameReset) / 60
		if timelimit > 0 then
			if votingenabled then
				if timepassed >= timelimit + ((GAMEMODE.ConVars.VoteDelay:GetInt()+GAMEMODE.ConVars.VoteTime:GetInt())/60) + 0.50 then
					game.ConsoleCommand("changelevel "..GAMEMODE:GetNextMap(false).."\n")
					for _, v in ipairs(player.GetHumans()) do v:SaveData() end
				end
			else
				if timepassed >= timelimit + 0.50 then
					game.ConsoleCommand("changelevel "..GAMEMODE:GetNextMap(false).."\n")
					for _, v in ipairs(player.GetHumans()) do v:SaveData() end
				end
			end
		end
		return
	end

	-- Regen
		if curtime - HealthRegenLast >= HealthRegenDelay then
			for _, v in ipairs(player.GetAll()) do
				if v:Alive() and v:Health() < 100 and (v:GetNextHealthRegen() or 0) < CurTime() then
					v:SetHealth( v:Health()+1 )
				end
			end
			HealthRegenLast = curtime
		end
	-- End Regen

	-- Endgame
		local gameover, team_index, winner = self:IsGameOver()
		if gameover then
			self.GameOver = true
			self.GameOverTeam = team_index
			self.GameOverWinner = winner
			self:OnGameOver( team_index, winner )
		end
	-- End Endgame

	if lprof then lprof.PopScope() end
end

function LicenceTimeCheck()
	for _, ply in ipairs(player.GetAll()) do
		local ostime = os.time()
		local primaries = ply:GetLicenses( 1 )
		local secondaries = ply:GetLicenses( 2 )
		local hats = ply:GetLicenses( 5 )

		if primaries then
			for class, time_when_over in pairs(primaries) do
				if time_when_over != -1 and time_when_over - ostime <= 0 then
					ply:RemoveLicense( 1, class )
				end
			end
		end

		if secondaries then
			for class, time_when_over in pairs(secondaries) do
				if time_when_over != -1 and time_when_over - ostime <= 0 then
					ply:RemoveLicense( 2, class )
				end
			end
		end

		if hats then
			for class, time_when_over in pairs(hats) do
				if time_when_over != -1 and time_when_over - ostime <= 0 then
					ply:RemoveLicense( 5, class )
				end
			end
		end

		SH_SendClientLicenses( ply )
	end
end
timer.Create( "LicenceTimeCheck", 60, 0, LicenceTimeCheck )

function GM:Tick()
	for _, v in ipairs(player.GetAll()) do
		v:SetBloodColor(-1)
	end
	for _, v in ipairs(ents.FindByClass("prop_ragdoll")) do
		v:SetBloodColor(-1)
	end

	for _, v in ipairs(ents.GetAll()) do
		if v.IsOnFire and v.Extinguish and v:IsOnFire() then
			local mat = v:GetMaterialType()
			if mat != MAT_WOOD then
				v:Extinguish()
			end
		end
	end
end

function GM:IsGameOver()
	-- Otherwise check the timelimit
	local timelimit = GAMEMODE.ConVars.TimeLimit:GetFloat()
	if timelimit > 0 and (CurTime()-self.LastGameReset)/60 >= timelimit then
		return true, 0, nil
	end

	-- Not over
	return false, 0, nil
end

-- If winner is 0 then it was a timelimit end
function GM:OnGameOver( team_index, winner )
	local rf = RecipientFilter()
	rf:AddAllPlayers()
	umsg.Start( "sh_gameover", rf )
	  umsg.Short( team_index )
	  umsg.Short( winner )
	umsg.End()

	GAMEMODE.FreezePlayers( true )

	-- Start vote timer
	if GAMEMODE.ConVars.VoteEnabled:GetBool() then
		GAMEMODE:SendMapList()
		GAMEMODE:StartCountDown( GAMEMODE.ConVars.VoteDelay:GetInt(), "Voting will begin in", "GAMEMODE:EnableVotingSystem()", "GAMEMODE:EnableVotingSystem()" )
	else
		GAMEMODE:StartCountDown( GAMEMODE.ConVars.VoteDelay:GetInt()*2, "Map change in", [[game.ConsoleCommand("changelevel "..GAMEMODE:GetNextMap().."\n")]], "" )
		for _, v in ipairs(player.GetHumans()) do v:SaveData() end
	end
end

function GM:GetFallDamage( ply, vel )
	return (vel-480)*(100/(1024-580))
end

function GM:GetDefaultHealth( ent )
	return IsValid( ent ) and (DefaultHealths[ent:GetClass()] or 100) or 100
end

function GM:SetEntHealth( ent )
	local newhp = (DefaultHealths[ent:GetClass()] or 100)

	if getmodelproperties then
		local surfaceprop, _ = getmodelproperties( ent:GetModel() )
		if string.find( string.lower(surfaceprop), "wood" ) then newhp = newhp/4 end
	elseif string.find( ent:GetModel(), "wood" ) then
		newhp = newhp/4
	end

	ent:SetMaxHealth( newhp )

	if ent:GetClass() == "prop_physics" then
		ent:SetHealth( 1 )
		GAMEMODE.BuildingProps[ent] = CurTime()

		ent.BuildSound = CreateSound( ent, PropBuildingSound )
		ent.BuildSound:PlayEx( 0.25, 100 )
		ent:CallOnRemove( "StopBuildSound",
			function( ent )
				if ent and ent.BuildSound then ent.BuildSound:Stop() ent.BuildSound = nil end
			end
		)
	else
		ent:SetHealth( newhp )
	end
end

function GM:EntityTakeDamage( ent, dmginfo )
	local inflictor = dmginfo:GetInflictor()
	local attacker = dmginfo:GetAttacker()

	if attacker:IsPlayer() and attacker.IsGod then
		dmginfo:ScaleDamage( 0 )
		return
	end

	if ent:IsPlayer() then return end

	if GAMEMODE.BuildingProps[ent] then
		GAMEMODE.BuildingProps[ent] = nil
		ent:SetHealth( ent:Health() - 500 )
		if ent.BuildSound then ent.BuildSound:Stop() ent.BuildSound = nil end
		ent:BuildingSolidify()
	end

	local class = ent:GetClass()
	local amount = dmginfo:GetDamage()
	if IsValid( inflictor ) then
		if inflictor:GetClass() == "sent_turret_mountable" or inflictor:GetClass() == "gmod_turret" or !table.HasValue( BreakableEntities, class ) then return end

		if inflictor:GetClass() == "sent_c4" or inflictor:GetClass() == "sent_rocket" then
			dmginfo:SetDamage( math.min( 2500, amount ))
		else
			dmginfo:SetDamage( math.min( 5, amount ))
		end
	else
		dmginfo:SetDamage( math.min( 5, amount ))
	end

	if ent:GetMaxHealth() == 0 then
		--[[local newhp = (DefaultHealths[class] or 100)
		if getmodelproperties then
			local surfaceprop, _ = getmodelproperties( ent:GetModel() )
			if string.find( string.lower(surfaceprop), "wood" ) then newhp = newhp/4 end
		elseif string.find( ent:GetModel(), "wood" ) then
			newhp = newhp/4
		end
		ent:SetHealth( newhp )
		ent:SetMaxHealth( newhp )]]--

		self:SetEntHealth( ent )
	end
	local hp, max = ent:Health(), ent:GetMaxHealth()

	hp = hp - dmginfo:GetDamage()
	local c = 255 * (hp / max)
	ent:SetColor( Color(c, c, c, 255) )
	if hp <= 0 then
		local pos = ent:LocalToWorld( ent:OBBCenter() )
		local gibs = ent:PrecacheGibs()
		if gibs > 0 then
			ent:Fire( "Break", "", 0 )
		else
			ent:Remove()
		end

		if gibs == 0 then
			if class == "prop_physics" then
				util.ScreenShake( pos, 5, 5, 1.5, 250 )
				local ed = EffectData()
					ed:SetStart( pos )
					ed:SetOrigin( pos )
					ed:SetScale( 1 )
				util.Effect( "HelicopterMegaBomb", ed )
				sound.Play( "ambient/explosions/explode_7.wav", pos, 100, 100, 1 )
			else
				local ed = EffectData()
					ed:SetStart( pos )
					ed:SetOrigin( pos )
					ed:SetScale( 1 )
				util.Effect( "cball_explode", ed )
				util.Effect( "ImpactJeep", ed )
				sound.Play( "physics/metal/metal_box_break1.wav", pos, 100, 100, 1 )
			end
		end
		if attacker:IsPlayer() then
			attacker:AddStatistic( "propsdestroyed", 1 )
		end
		return
	end

	ent:SetHealth( hp )
	--dmginfo:ScaleDamage( 1 )
end

function GM:KeyPress( ply, key )
	if key == IN_JUMP then
		ply:AddStatistic( "jumps", 1 )
	elseif key == IN_DUCK then
		ply:AddStatistic( "crouches", 1 )
	end
end

function GM:ShowHelp( ply )
	if ply:GetInitialized() != INITSTATE_OK then return end
	ply:ConCommand( "sh_help" )
end

function GM:ShowTeam( ply )
	if ply:GetInitialized() != INITSTATE_OK then return end
	ply:ConCommand( "sh_teams" )
end

function GM:ShowSpare1( ply )
	if ply:GetInitialized() != INITSTATE_OK then return end
	ply:ConCommand( "sh_loadout" )
end

function GM:ShowSpare2( ply )
	ply:ConCommand( "sh_options" )
end

local function ForceSave( ply )
	if !IsValid( ply ) or ply:IsAdmin() then
		for _, v in ipairs(player.GetHumans()) do
			v:SaveData()
		end
		MsgAll( "All player data saved.\n" )
	end
end
concommand.Add( "sh_forcesave", ForceSave )
