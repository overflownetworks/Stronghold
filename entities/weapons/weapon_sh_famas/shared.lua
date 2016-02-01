if (SERVER) then
	AddCSLuaFile("shared.lua")

elseif (CLIENT) then
	SWEP.PrintName 			= "FAMAS F1"
	SWEP.ViewModelFlip		= false
	SWEP.IconLetter 		= "t"

	killicon.AddFont("weapon_sh_famas", "CSKillIcons", SWEP.IconLetter, Color(200, 200, 200, 255))
end

SWEP.MuzzleEffect			= "rifle" 
SWEP.Base 					= "weapon_sh_p90"
SWEP.Spawnable 				= true
SWEP.AdminSpawnable 		= true
SWEP.ViewModel 				= "models/weapons/v_rif_famas.mdl"
SWEP.WorldModel 			= "models/weapons/w_rif_famas.mdl"
SWEP.Primary.Sound 			= Sound("Weapon_FAMAS.Single")
SWEP.Primary.Recoil 		= 0.3
SWEP.Primary.Damage 		= 22
SWEP.Primary.NumShots 		= 1
SWEP.Primary.Cone 			= 0.005
SWEP.Primary.ClipSize 		= 25
SWEP.Primary.Delay 			= 0.063
SWEP.Primary.DefaultClip 	= 25
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "ar2"
SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"
SWEP.ModelRunAnglePreset	= 1
SWEP.IronSightsPos 			= Vector (-3.1053, 0.1, 2.973)
SWEP.IronSightsAng 			= Vector (0, 0, 0)
