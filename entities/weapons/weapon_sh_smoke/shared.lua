if (SERVER) then
  
	AddCSLuaFile ("shared.lua")
	SWEP.Weight 			= 5
	SWEP.AutoSwitchTo 		= false
	SWEP.AutoSwitchFrom 	= false
end

if (CLIENT) then

	SWEP.PrintName 			= "SMOKE GRENADE"
	SWEP.DrawAmmo 			= true
	SWEP.DrawCrosshair 		= false
	SWEP.ViewModelFOV		= 65
	SWEP.ViewModelFlip		= true
	SWEP.CSMuzzleFlashes	= false

	SWEP.IconLetter 			= "Q"
	killicon.AddFont("weapon_sh_smoke", "CSKillIcons", SWEP.IconLetter, Color(200, 200, 200, 255))
end


SWEP.Base 					= "weapon_sh_grenade"

SWEP.Contact 				= ""
SWEP.Purpose 				= ""

SWEP.Spawnable 				= false
SWEP.AdminSpawnable 			= false

SWEP.ViewModel 				= "models/weapons/v_eq_smokegrenade.mdl"
SWEP.WorldModel 				= "models/weapons/w_eq_smokegrenade.mdl"

SWEP.Primary.ClipSize 			= -1
SWEP.Primary.DefaultClip 		= 1
SWEP.Primary.Automatic 			= true
SWEP.Primary.Ammo 			= "grenade"

SWEP.Secondary.ClipSize 		= -1
SWEP.Secondary.DefaultClip 		= -1
SWEP.Secondary.Automatic 		= true
SWEP.Secondary.Ammo 			= "none"

SWEP.GrenadeClass				= "sent_smokegrenade"
SWEP.Cookable					= false