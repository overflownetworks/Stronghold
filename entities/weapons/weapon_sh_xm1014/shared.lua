if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.HoldType = "ar2"
elseif (CLIENT) then
	SWEP.PrintName 		= "M4 SUPER 90"
	SWEP.IconLetter 		= "B"

	killicon.AddFont("weapon_sh_xm1014", "CSKillIcons", SWEP.IconLetter, Color(200, 200, 200, 255))
end

SWEP.MuzzleEffect			= "grenade"
SWEP.ShellEffect			= "rg_shelleject_shotgun" 
SWEP.MuzzleAttachment		= "1" 
SWEP.ShellEjectAttachment	= "2" 
SWEP.Base 					= "weapon_sh_pumpshotgun"
SWEP.Spawnable 				= false
SWEP.AdminSpawnable 		= false
SWEP.ViewModel 				= "models/weapons/v_shot_xm1014.mdl"
SWEP.WorldModel 			= "models/weapons/w_shot_xm1014.mdl"
SWEP.Primary.Sound 			= Sound("Weapon_XM1014.Single")
SWEP.Primary.ClipSize 		= 8
SWEP.Primary.Delay 			= 0.2
SWEP.Primary.DefaultClip 	= 8
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= "buckshot"
SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"
SWEP.IronSightsPos 			= Vector (5.1536, -3.817, 2.1621)
SWEP.IronSightsAng 			= Vector (-0.1466, 0.7799, 0)