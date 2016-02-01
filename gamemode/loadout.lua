--[[-------------------------------------------------------

Fight to Survive: Stronghold by RoaringCow, TehBigA is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.

This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons,
444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

---------------------------------------------------------]]
function SH_SendClientLoadouts( ply )
	if !IsValid( ply ) then return end

	local loadouts = ply:GetLoadouts()
	if !loadouts then return end

	net.Start("sh_loadouts")
		net.WriteTable(loadouts)
	net.Send(ply)
end

function SH_SendClientLoadout( ply, name )
	if !IsValid( ply ) then return end

	local loadout = ply:GetLoadout( name )
	if !loadout then return end

	net.Start("sh_loadout")
		net.WriteTable({[name]=loadout})
	net.Send(ply)
end

concommand.Add( "sh_removeloadout",
	function( ply, cmd, args )
		ply:RemoveLoadout( args[1] )
	end )

concommand.Add( "sh_editloadout",
	function( ply, cmd, args )
		ply:EditLoadout( args[1], args[2], args[3], args[4] )
		ply:SetLoadout( args[1] )
	end )

local function SH_SetLoadout( ply, cmd, args )
	ply:SetLoadout( args[1] )
end
concommand.Add( "sh_setloadout", SH_SetLoadout )

local function SH_SetPrimary( ply, cmd, args )
	if !GAMEMODE.PrimaryWeapons[args[1]] then return end
	ply:SetLoadoutPrimary( args[1] )
end
concommand.Add( "sh_setprimary", SH_SetPrimary )

local function SH_SetSecondary( ply, cmd, args )
	if !GAMEMODE.SecondaryWeapons[args[1]] then return end
	ply:SetLoadoutSecondary( args[1] )
end
concommand.Add( "sh_setsecondary", SH_SetSecondary )

local function SH_SetExplosive( ply, cmd, args )
	if !GAMEMODE.Explosives[args[1]] then return end
	ply:SetLoadoutExplosive( args[1] )
end
concommand.Add( "sh_setexplosive", SH_SetExplosive )

local function SH_EquipHat( ply, cmd, args )
	if !GAMEMODE.ValidHats[args[1]] then args[1] = "" end
	if !ply:IsDonator() and GAMEMODE.DonatorHats[args[1]] then args[1] = "" end
	ply:EnableHat( args[1] )
end
concommand.Add( "sh_equiphat", SH_EquipHat )

local function SH_ClosedLoadoutMenu( ply, cmd, args )
	if ply:GetInitialized() != INITSTATE_OK then return end
	if ply:GetObserverMode() != OBS_MODE_NONE then -- Just now setting first loadout
		ply:Spawn()
	elseif ply.WeaponLoadout then
		ply.WeaponLoadout = false
		hook.Call( "PlayerLoadout", GAMEMODE, ply )
	end
end
concommand.Add( "sh_closedloadoutmenu", SH_ClosedLoadoutMenu )
