if (SERVER) then
	AddCSLuaFile("shared.lua")

elseif (CLIENT) then
	SWEP.PrintName 			= "AK-47"
	SWEP.IconLetter 		= "b"

	killicon.AddFont("weapon_sh_ak47", "CSKillIcons", SWEP.IconLetter, Color(200, 200, 200, 255))
end

SWEP.MuzzleAttachment		= "1" 
SWEP.ShellEjectAttachment	= "2" 
SWEP.Base 					= "weapon_sh_base"
SWEP.Spawnable 				= true
SWEP.AdminSpawnable 		= true
SWEP.ViewModel 				= "models/weapons/v_rif_ak47.mdl"
SWEP.WorldModel 			= "models/weapons/w_rif_ak47.mdl"
SWEP.Primary.Sound 			= Sound("Weapon_AK47.Single")
SWEP.Primary.Damage 		= 25
SWEP.Primary.Recoil 		= 0.4
SWEP.Primary.NumShots 		= 1
SWEP.Primary.Cone 			= 0.005
SWEP.Primary.ClipSize 		= 30
SWEP.Primary.Delay 			= 0.1
SWEP.Primary.DefaultClip 	= 30
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "ar2"
SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"
SWEP.RMod					= 1
SWEP.RKick					= 10
SWEP.RRise					= 0.02
SWEP.IronSightsPos 			= Vector (6.0776, 0.1, 2.0964)
SWEP.IronSightsAng 			= Vector (2.56, -0.0459, 0)




