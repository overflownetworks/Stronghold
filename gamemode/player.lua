--[[-------------------------------------------------------

Fight to Survive: Stronghold by RoaringCow, TehBigA is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.

This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 
444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

---------------------------------------------------------]]
local CONVARS = GM.ConVars

local function PlayerCountInSphere( pos, radius, ignore )
	local count = 0
	for _, v in ipairs(ents.FindInSphere(pos,radius)) do
		if v != ignore and v:GetClass() == "prop_physics" then count = count + 1 end
	end
	return count
end

function GM:ReadyForInfo( ply )
	local filename = "Stronghold/PlayerInfo/"..string.gsub( ply:SteamID(), ":", "_" )..".txt"

	local raw = file.Read( filename ) or ""
	local tbl = glon.decode( raw ) or {}
		
	ply.Statistics = tbl.Statistics or { name = ply:GetName() }
	ply.Items = tbl.Items or {
		["buckshot"] = { type=3, count=1000 },
		["ar2"] = { type=3, count=1000 },
		["smg1"] = { type=3, count=1000 },
		["pistol"] = { type=3, count=1000 },
		["money"] = { type=0, count=100 }
	}
	ply.Loadouts = tbl.Loadouts or {}
	ply.Licenses = tbl.Licenses
	
	-- Fix  Licenses table --
	ply.Licenses = ply.Licenses or { [1]={weapon_sh_mp5a4=-1}, [2]={weapon_sh_p228=-1}, [5]={} }
	if !ply.Licenses[1] then ply.Licenses[1] = {} end
	if !ply.Licenses[2] then ply.Licenses[2] = {} end
	if !ply.Licenses[5] then ply.Licenses[5] = {} end
	if !ply.Licenses[1]["weapon_sh_mp5a4"] then ply.Licenses[1]["weapon_sh_mp5a4"] = -1 end
	if !ply.Licenses[2]["weapon_sh_p228"] then ply.Licenses[2]["weapon_sh_p228"] = -1 end
	-------------------------
	
	ply.Money = ply.Items["money"] and ply.Items["money"].count or 0
	ply.Items["money"] = nil
	
	SH_SendClientItems( ply )
	SH_SendClientLoadouts( ply )
	
	-- Call donator helper function
	--[[if ply:IsDonator() then
		self:GiveDonatorLicenses( ply )
	end]]

	SH_SendClientLicenses( ply )

	ply:SetInitialized( INITSTATE_OK )
	ply:ConCommand( "sh_loadout" )
	ply:ConCommand( "sh_help" )
end

concommand.Add( "sh_readyforinfo",
	function( ply )
		ply:SetInitialized( INITSTATE_WAITING )
		GAMEMODE:ReadyForInfo( ply )
	end )

function GM:PlayerInitialSpawn( ply )
	--[[for _, ply in pairs( ents.FindByClass( "Player" ) ) do
		ply:SetBloodColor(-1)
	end]]
	
	if ply:IsBot() then
		ply:SetInitialized( INITSTATE_OK )
	end
	
	ply:SetTeam( TEAM_UNASSIGNED )
	timer.Simple( 1,
		function( ply )
			if !IsValid( ply ) then return end
			SendTeamsToClient( ply )
			
			umsg.Start( "sh_advert", ply )
				umsg.Short( (GAMEMODE.Adverts[GAMEMODE.CurrentAdvert] and GAMEMODE.Adverts[GAMEMODE.CurrentAdvert].color) or 1 )
				local str = (GAMEMODE.Adverts[GAMEMODE.CurrentAdvert] and GAMEMODE.Adverts[GAMEMODE.CurrentAdvert].text) or ""
				for k, v in pairs(GAMEMODE.KeyReplacements) do str = string.gsub( str, k, tostring(v()) ) end
				umsg.String( str )
			umsg.End()

			local timelimit = GAMEMODE.ConVars.TimeLimit:GetFloat()
			if timelimit > 0 then GAMEMODE:StartCountDown( (timelimit*60)-(CurTime()-GAMEMODE.LastGameReset), "Timelimit is up in", "", "", ply ) end
		end, ply )
		
	-- Give back spawnpoints and ammocrates
	local steamid = ply:SteamID()
	for _, v in ipairs(ents.FindByClass("sent_spawnpoint")) do
		if v.SteamID == steamid then
			v:SetPlayer( ply )
			v.Owner = ply
			v.PlayerLeft = 0
			
			if !ply.SpawnPoint then ply.SpawnPoint = {} end
			table.insert( ply.SpawnPoint, spawnpoint )
		
			ply:AddCount( "spawnpoints", spawnpoint )
		end
	end
	ply:CheckSpawnpoints()
	ply:SetLastSpawn( CurTime() )
end

function GM:IsSpawnpointSuitable( ply, spawn, force )
	local pos = spawn:GetPos()
	local dist = (ply:GetPos() - pos):Length()
	
	local blockables = ents.FindInBox( pos + Vector(-32,-32,0), pos + Vector(32,32,72) )
	local count = 0
	for _, v in ipairs(blockables) do
		if IsValid( v ) then
			local class = v:GetClass()
			if class == "player" and v:Alive() then
				count = count + 1
				if force then
					v:GodDisable()
					v:Kill()
				end
			elseif class == "prop_physics" or class == "sent_weaponcrate" then
				v:Remove()
			end
		end
	end

	return force == true or (count == 0 and dist > 1000)
end

local SND_WARPIN = { "items/battery_pickup.wav" } -- Sound("weapons/physcannon/energy_disintegrate4.wav"), Sound("weapons/physcannon/energy_disintegrate5.wav") }
function GM:PlayerSpawn( ply )
	if ply:GetInitialized() != INITSTATE_OK then
		GAMEMODE:PlayerSpawnAsSpectator( ply )
		ply:SetTeam( 50 )
		
		timer.Simple( 30, ply.FailedInitialize, ply )
		
		return
	end
	
	local team = ply:Team()
	if (team == TEAM_SPECTATOR or team == TEAM_UNASSIGNED) and !ply:IsBot() then
		GAMEMODE:PlayerSpawnAsSpectator( ply )
		if team == TEAM_UNASSIGNED then
			ply:ConCommand( "sh_loadout" )
			ply:ConCommand( "sh_help" )
			ply:SetTeam( 50 )
		end
		return
	end

	if self.GameOver then
		ply:SetVelocity( Vector(0,0,0) )
		ply:Lock()
		ply:Freeze( true )
		umsg.Start( "sh_gameover", ply )
		  umsg.Short( self.GameOverTeam )
		  umsg.Short( self.GameOverWinner )
		umsg.End()
	end
	
	ply:Extinguish()

	ply:UnSpectate()
	hook.Call( "PlayerLoadout", GAMEMODE, ply )
	hook.Call( "PlayerSetModel", GAMEMODE, ply )

	ply.spawnpos = ply:GetPos()
	ply.spawnang = ply:GetAngles()
	ply.ents = {}
	GAMEMODE:SetPlayerSpeed( ply, 150, 300 )
	
	umsg.Start( "sh_spawned", ply )
	umsg.End()
	
	local spawnprot = CONVARS.ImmuneTime:GetInt()
	if spawnprot > 0 then
		ply.IsGod = true
		ply:GodEnable()
		--ply:SetMaterial( "models/dog/eyeglass" )
		ply:SetColor( 255, 255, 255, 200 )
		timer.Create( "SpawnProt_"..ply:EntIndex(), spawnprot, 1, function( ply )
			if IsValid(ply) then
				ply.IsGod = false
				ply:GodDisable()
				ply:SetMaterial( "" )
				ply:SetColor( 255, 255, 255, 255 )
				umsg.Start( "sh_spawnprotection", ply )
				  umsg.Bool( false )
				umsg.End()
			end
		end, ply )
		umsg.Start( "sh_spawnprotection", ply )
		  umsg.Bool( true )
		umsg.End()
	end
	
	ply:SetLastSpawn( CurTime() )
	ply:CheckSpawnpoints()
	
	ply:SetViewOffset( Vector(0,0,59) )
	ply:SetViewOffsetDucked( Vector(0,0,40) )
	
	--[[ply:EmitSound( table.Random(SND_WARPIN), math.Rand(65,75), 100 )
	local ed = EffectData()
	ed:SetEntity( ply )
	util.Effect( "spawneffect", ed )]]
	
	-- Death effects cleanup
	if IsValid( ply.DroppedWeapon ) then
		ply.DroppedWeapon:Dissolve()
	end
end

function GM:PlayerSetModel( ply )
	local cl_playermodel = string.lower( ply:GetInfo("cl_playermodel") )
	local modelname = self.ValidPlayerModels[cl_playermodel] or self.DefaultPlayerModel
	util.PrecacheModel( modelname )

	if !table.HasValue( self.ValidPlayerModels, modelname ) --[[or (!ply:IsDonator() and table.HasValue( self.DonatorPlayerModels, modelname ))]] then
		modelname = self.DefaultPlayerModel
	end
	
	ply:SetModel( modelname )
end

function GM:PlayerLoadout( ply )
	if ply:Alive() then
		ply:AddItem( "pistol", ply:GetAmmoCount("pistol") )
		ply:AddItem( "smg1", ply:GetAmmoCount("smg1") )
		ply:AddItem( "buckshot", ply:GetAmmoCount("buckshot") )
		ply:AddItem( "ar2", ply:GetAmmoCount("ar2") )
		ply:AddItem( "rpg_round", ply:GetAmmoCount("rpg_round") )
		if ply:GetSpawnedLoadoutExplosive() and ply:GetSpawnedLoadoutExplosive() ~= NULL then
			if IsValid( ply:GetWeapon(ply:GetSpawnedLoadoutExplosive()) ) then
				ply:AddItem( ply:GetSpawnedLoadoutExplosive(), ply:GetAmmoCount("grenade") )
			end
		end

	end
	
	ply:StripWeapons()
	ply:RemoveAllAmmo()

	local pistol = math.Clamp( ply:GetItemCount("pistol"), 0, 100 )
	local smg1 = math.Clamp( ply:GetItemCount("smg1"), 0, 200 )
	local buckshot = math.Clamp( ply:GetItemCount("buckshot"), 0, 60 )
	local ar2 = math.Clamp( ply:GetItemCount("ar2"), 0, 200 )
	local rpg_round = math.Clamp( ply:GetItemCount("rpg_round"), 0, --[[ply:IsGold() and 6 || ply:IsPlatinum() and 4 ||]] 2 )
	
	ply:GiveAmmo( pistol,   "pistol",   true )
	ply:GiveAmmo( smg1,     "smg1",     true )
	ply:GiveAmmo( buckshot, "buckshot", true )
	ply:GiveAmmo( ar2,      "ar2",      true )
	ply:GiveAmmo( rpg_round,      "rpg_round",      true )
	
	ply:AddItem( "pistol", pistol*-1, 4 )
	ply:AddItem( "smg1", smg1*-1, 4 )
	ply:AddItem( "buckshot", buckshot*-1, 4 )
	ply:AddItem( "ar2", ar2*-1, 4 )
	ply:AddItem( "rpg_round", rpg_round*-1, 4 )
	
	local getprimary, getsecondary = ply:GetLoadoutPrimary(), ply:GetLoadoutSecondary()
	local primarytime, secondarytime = ply:GetLicenseTimeLeft( 1, getprimary ), ply:GetLicenseTimeLeft( 2, getsecondary )
	
	local primary = ""
	local secondary = ""
	local explosive, explosive_ammo = ply:GetLoadoutExplosive() or "", 0
	
	if getprimary != "" then
		if primarytime == -1 or primarytime > 0 then
			primary = getprimary
		else
			primary = "weapon_sh_mp5a4"
			ply:SendMessage( "Your primary weapon's license has run out!" )
		end
	end
	
	if getsecondary != "" then
		if secondarytime == -1 or secondarytime > 0 then
			secondary = getsecondary
		else
			secondary = "weapon_sh_p228"
			ply:SendMessage( "Your secondary weapon's license has run out!" )
		end
	end
	
	if primary == "" then
		ply:SendMessage( "No primary weapon selected, equipping default." )
		primary = "weapon_sh_mp5a4"
		ply:SetLoadoutPrimary( primary )
	end
	
	if secondary == "" then
		ply:SendMessage( "No secondary weapon selected, equipping default." )
		secondary = "weapon_sh_p228"
		ply:SetLoadoutSecondary( secondary )
	end
	
	if explosive == "" then
		--ply:SendMessage( "No explosive selected, equipping default." )
		explosive = "weapon_sh_grenade"
		ply:SetLoadoutExplosive( explosive )
	end

	local explosive_ammo = ply:GetItemCount( explosive )
	local explosive_max = self.Explosives[explosive].ammo
	--[[if ply:IsGold() and explosive != "weapon_sh_c4" then
		explosive_max = math.floor( explosive_max * 1.5 )
	elseif ply:IsPlatinum() and explosive != "weapon_sh_c4" then
		explosive_max = explosive_max * 2
	end]]
	if explosive_ammo > 0 then
		ply:Give( explosive )
		if explosive_ammo > 1 then
			local given_amt = math.min( explosive_ammo, explosive_max )
			ply:AddItem( explosive, given_amt*-1, 3 )
			ply:GiveAmmo( given_amt-1, "grenade", true )
		else
			ply:AddItem( explosive, -1, 3 )
		end
	end

	ply:Give( secondary )
	ply:SelectWeapon( secondary )

	ply:Give( primary )
	ply:SelectWeapon( primary )
	
	ply:Give( "weapon_sh_doormod" )
	ply:Give( "weapon_sh_tool" )
	
	SH_SendClientItems( ply )
	
	ply:SetSpawnedLoadoutPrimary( primary )
	ply:SetSpawnedLoadoutSecondary( secondary )
	ply:SetSpawnedLoadoutExplosive( explosive )
end

function GM:DoPlayerDeath( ply, attacker, dmginfo )
	-- Retrieve ammo
	ply:AddItem( "pistol", ply:GetAmmoCount("pistol") )
	ply:AddItem( "smg1", ply:GetAmmoCount("smg1") )
	ply:AddItem( "buckshot", ply:GetAmmoCount("buckshot") )
	ply:AddItem( "ar2", ply:GetAmmoCount("ar2") )
	ply:AddItem( "rpg_round", ply:GetAmmoCount("rpg_round") )
	
	if ply:GetSpawnedLoadoutExplosive() and IsValid( ply:GetWeapon(ply:GetSpawnedLoadoutExplosive()) ) then
		ply:AddItem( ply:GetSpawnedLoadoutExplosive(), ply:GetAmmoCount("grenade") )
	end
	
	SH_SendClientItems( ply )

	-- Death effects
	local wep = ply:GetActiveWeapon()
	if IsValid( wep ) and (!wep.Primed or wep.Primed == 0) then
		local wepfx = ents.Create( "prop_physics" )
		
		local model = wep.WorldModel or string.gsub(wep:GetModel(),"v_","w_")
		local pos, ang
		local attachid = ply:LookupAttachment( "anim_attachment_RH" )
		if attachid != 0 then
			local posang = ply:GetAttachment( attachid )
			pos = posang.Pos
			ang = posang.Ang
		else
			pos = wep:GetPos()+Vector(0,0,45)+10*ply:GetForward()
			ang = wep:GetAngles()
		end
		
		if model == "models/weapons/w_rocket_launcher.mdl" then
			ang:RotateAroundAxis( ang:Up(), 180 )
		end
		
		wepfx:SetModel( model )
		wepfx:SetPos( pos )
		wepfx:SetAngles( ang )
		
		wepfx:Spawn()
		wepfx:SetCollisionGroup( COLLISION_GROUP_WEAPON )
		wepfx:SetVelocity( ply:GetVelocity() )
		wepfx:SetHealth( 1000 )
		wepfx:SetMaxHealth( 1000 )
		
		ply.DroppedWeapon = wepfx
		timer.Simple( 30, function(wepfx) if IsValid(wepfx) then wepfx:Dissolve() end end, wepfx )

	end
	ply:CreateServerSideRagdoll()
	ply:AddDeaths( 1 ) 
	if IsValid( attacker ) and attacker:IsPlayer() and ply != attacker then
		attacker:AddFrags( 1 )
	end
end
local LastKiller = false
local LastKilled = false
function GM:PlayerDeath( ply, inflictor, killer )

	self.BaseClass:PlayerDeath( ply, inflictor, killer )
	
	umsg.Start( "sh_killed", ply )
		umsg.Entity( killer )
	umsg.End()
	
	ply:AddStatistic( "deaths", 1 )
	ply:SetMultiplier( 0 )
	
	local livedfor = CurTime() - (tonumber( ply:GetLastSpawn() ) or 0)
	if livedfor > ply:GetStatistic( "longestalive", 0 ) then
		ply:SetStatistic( "longestalive", livedfor )
	end
	
	if IsValid( killer ) and killer:IsPlayer() and ply != killer and LastKiller != killer or IsValid( killer ) and killer:IsPlayer() and ply != killer and LastKilled != ply then
		killer:AddStatistic( "kills", 1 )
		if killer:Alive() then
			killer:SetLastKill( CurTime() )
			killer:AddMultiplier( 1 )
			LastKiller = killer
			LastKilled = ply
			print(killer)
			
			local amt = CONVARS.GBuxMPK:GetFloat()
			killer:AddMoney( amt )
			killer:AddStatistic( "gbuxmoneyearned", amt )
			
			if killer:GetMultiplier() > killer:GetStatistic( "gbuxhighestmul", 0 ) then
				killer:SetStatistic( "gbuxhighestmul", killer:GetMultiplier() )
			end
		end
	end
	
	timer.Remove( "Suicide_"..ply:EntIndex() )
	ply.Suiciding = false
	
	ply:SetDSP( 0 )
	return true
end

function GM:PlayerDeathThink( ply )

	if (  ply.NextSpawnTime && ply.NextSpawnTime > CurTime() - 4 ) then return end

	if ( ply:KeyPressed( IN_ATTACK ) || ply:KeyPressed( IN_ATTACK2 ) || ply:KeyPressed( IN_JUMP ) ) then
	
		ply:Spawn()
		
	end
	
end

function GM:CanPlayerSuicide( ply )
	if !ply.Suiciding and ply:Alive() and ply:Team() != TEAM_SPECTATOR and ply:Team() != TEAM_UNASSIGNED then
		ply.Suiciding = true
		ply:SendMessage( "Suiciding in 3 seconds...", "Stronghold", false )
		timer.Create( "Suicide_"..ply:EntIndex(), 3, 1, function(ply) if IsValid(ply) then ply:Kill() ply.Suiciding = false end end, ply )
	end
	return false
end

function GM:PlayerCanPickupWeapon(ply, wep)
	if ply:HasWeapon("weapon_sh_tool") then return end
	return true
end

function GM:PlayerConnect( name, address ) 
    for _, ply in ipairs(player.GetAll()) do
		local ostime = os.time()
		local primaries = ply:GetLicenses( 1 )
		local secondaries = ply:GetLicenses( 2 )
		local hats = ply:GetLicenses( 5 )
		
		for class, time_when_over in pairs(primaries) do
			if time_when_over != -1 and time_when_over - ostime <= 0 then
				ply:RemoveLicense( 1, class )
			end
		end
		
		for class, time_when_over in pairs(secondaries) do
			if time_when_over != -1 and time_when_over - ostime <= 0 then
				ply:RemoveLicense( 2, class )
			end
		end
		
		for class, time_when_over in pairs(hats) do
			if time_when_over != -1 and time_when_over - ostime <= 0 then
				ply:RemoveLicense( 5, class )
			end
		end
		
		SH_SendClientLicenses( ply )
	end
end

function GM:PlayerDisconnected( ply )
	local index = ply:Team()
	if index > 50 then
		CCLeaveTeam( ply, {true} )
	end
	--[[ply:SaveLicenses()
	ply:SaveLoadouts()
	ply:SaveStatistics()
	ply:SaveMoney()
	ply:SaveItems()]]
	ply:SaveData()
end

-- sv_alltalk 1 overrides this hook
function GM:PlayerCanHearPlayersVoice( ply, other )
	local channel = ply:GetInfoNum( "sh_voice_channel", 1 )
	local channel_other = other:GetInfoNum( "sh_voice_channel", 1 )
	local alwayspublic = ply:GetInfoNum( "sh_voice_alwayshearpublic", 0 )
	local alwaysteam = ply:GetInfoNum( "sh_voice_alwayshearteam", 0 )
	
	if (channel == 1 and channel_other == 1 and ply:Team() == other:Team()) or channel == 0 and channel_other == 0 then
		return true
	elseif channel_other == 0 and channel == 1 and alwayspublic == 1 then
		return true
	elseif channel_other == 1 and channel == 0 and alwaysteam == 1 and ply:Team() == other:Team() then
		return true
	end
	
	return false
end

-- ---------------------------------------------------------------------------------------------------- --
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! DO NOT FUCKING TOUCH THIS !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! --
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! THIS WAS A BITCH TO TRACK DOWN !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! --
-- !!!!!! GARRY FIX YOUR DOUBLE GM:ScalePlayerDamage CALL THAT ALSO ADDS ORIGINAL DAMAGE BACK ON !!!!!! --
-- ---------------------------------------------------------------------------------------------------- --

function GM:ScalePlayerDamage( ply, hitgroup, dmginfo, dont_ignore )
	local original = dmginfo:GetDamage()
	
	if hitgroup == HITGROUP_HEAD then
		dmginfo:ScaleDamage( 10 )
	end

	if hitgroup == HITGROUP_CHEST or
			hitgroup == HITGROUP_STOMACH or
			hitgroup == HITGROUP_GENERIC or
			hitgroup == HITGROUP_CHEST			then
		dmginfo:ScaleDamage( 4 )
	end

	-- ALL FOUR LIMBS DAMNIT
	if hitgroup == HITGROUP_LEFTARM or
			hitgroup == HITGROUP_RIGHTARM or
			hitgroup == HITGROUP_LEFTLEG or
			hitgroup == HITGROUP_RIGHTLEG or
			hitgroup == HITGROUP_GEAR then
		dmginfo:ScaleDamage( 3 )
	end
	
	-- WHY ORIGINAL ADDED?!
	dmginfo:SetDamage( dmginfo:GetDamage()-original )
end

function GM:PlayerHurt( ply, attacker, healthleft, healthtaken )
	ply:SetNextHealthRegen( CurTime()+5 )
	ply:AddStatistic( "dmgtaken", math.floor(healthtaken) )
	if IsValid( attacker ) and attacker:IsPlayer() then
		attacker:AddStatistic( "dmginflicted", math.floor(healthtaken) )
		umsg.Start( "sh_hitdetection", attacker )
		umsg.End()
	end
end

function GM:PlayerTraceAttack( ply, dmginfo, dir, trace )
	if SERVER then
		local wep = ply:GetActiveWeapon()
		if IsValid( wep ) and wep.ScaleByDistance then
			local dist = (trace.HitPos-trace.StartPos):Length()
		end
		-- FFFFFUCK YOU DAMAGE
		--GAMEMODE:ScalePlayerDamage( ply, trace.HitGroup, dmginfo, true )
	end
	return false
end

function GM:PlayerUse( ply, ent )
	return true
end

-- ---------------------------------------------------------------------------------------------------- --
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! --
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! --
-- ---------------------------------------------------------------------------------------------------- --

function GM.FreezePlayers( freeze )
	for _, v in ipairs(player.GetHumans()) do
		if freeze then
			v:SetVelocity( Vector(0,0,0) )
			v:Lock()
			v:Freeze( true )
		else
			v:UnLock()
			v:Freeze( false )
		end
	end
end