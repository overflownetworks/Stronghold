if (SERVER) then
	AddCSLuaFile("shared.lua")

elseif (CLIENT) then
	SWEP.DrawAmmo			= true
	SWEP.PrintName 			= "FN P90"
	SWEP.IconLetter 		= "m"

	killicon.AddFont("weapon_sh_p90", "CSKillIcons", SWEP.IconLetter,Color(200, 200, 200, 255))
end

SWEP.MuzzleEffect			= "pistol"
SWEP.ShellEffect			= "rg_shelleject_rifle" 
SWEP.MuzzleAttachment		= "1" 
SWEP.ShellEjectAttachment	= "2" 
SWEP.Base 					= "weapon_sh_base"
SWEP.Spawnable 				= true
SWEP.AdminSpawnable 		= true
SWEP.ViewModel 				= "models/weapons/v_smg_p90.mdl"
SWEP.WorldModel 			= "models/weapons/w_smg_p90.mdl"
SWEP.Primary.Sound 			= Sound("Weapon_P90.Single")
SWEP.Primary.Recoil 		= 0.3
SWEP.Primary.Damage 		= 12
SWEP.Primary.NumShots 		= 1
SWEP.Primary.Cone 			= 0.008
SWEP.Primary.ClipSize 		= 50
SWEP.Primary.Delay 			= 0.066
SWEP.Primary.DefaultClip 	= 50
SWEP.Primary.Automatic 		= true
SWEP.SMG					= true
SWEP.Primary.Ammo 			= "smg1"
SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"
SWEP.FreeFloatHair			= 1
SWEP.IronSightsPos 			= Vector (2.9144, 0.1, 2.0236)
SWEP.IronSightsAng 			= Vector (0.1712, -0.0541, -0.0716)