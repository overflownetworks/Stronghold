if (SERVER) then
	AddCSLuaFile("shared.lua")

elseif (CLIENT) then
	SWEP.PrintName 			= "M4A2"
	SWEP.IconLetter 		= "w"
	SWEP.ViewModelFlip		= true	
	SWEP.ViewModelFOV		= 60

	killicon.AddFont("weapon_sh_m4a2", "CSKillIcons", SWEP.IconLetter, Color(200, 200, 200, 255))
end

SWEP.MuzzleEffect			= "rifle" 
SWEP.MuzzleAttachment		= "1" 
SWEP.ShellEjectAttachment	= "none"
SWEP.Base 					= "weapon_sh_base"
SWEP.Spawnable 				= true
SWEP.AdminSpawnable 		= true
SWEP.ViewModel 				= "models/weapons/v_rif_m4a1.mdl"
SWEP.WorldModel 			= "models/weapons/w_rif_m4a1.mdl"
SWEP.Primary.Sound 			= Sound("Weapon_M4A1.Single")
SWEP.Primary.Damage 		= 22
SWEP.Primary.Recoil 		= 0.3
SWEP.Primary.NumShots 		= 1
SWEP.Primary.Cone 			= 0.005
SWEP.Primary.ClipSize 		= 30
SWEP.Primary.Delay 			= 0.075
SWEP.Primary.DefaultClip 	= 30
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "ar2"
SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"
SWEP.Recoil 				= 2
SWEP.RMod					= 1
SWEP.SlideLocks				= 0
SWEP.FireSelect				= 1
SWEP.Look					= 1
SWEP.CycleSpeed				= 1
SWEP.IronCycleSpeed			= 0
SWEP.RKick					= 10
SWEP.RRise					= 0.05
SWEP.RSlide					= 0.005
SWEP.LastAmmoCount 			= 0
SWEP.FreeFloatHair			= 0
SWEP.IronsightCorrection 	= 0
SWEP.IronSightsPos = Vector (6.065, 0.1, 0.85)
SWEP.IronSightsAng = Vector (3.1, 1.45, 2.7)


