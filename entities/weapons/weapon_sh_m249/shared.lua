if (SERVER) then
	AddCSLuaFile("shared.lua")

elseif (CLIENT) then
	SWEP.PrintName 			= "M249 SAW"
	SWEP.IconLetter 		= "z"
	SWEP.ViewModelFlip		= false

	killicon.AddFont("weapon_sh_m249", "CSKillIcons", SWEP.IconLetter,Color(200, 200, 200, 255))
end

SWEP.MuzzleEffect			= "rifle"
SWEP.Base 					= "weapon_sh_base"
SWEP.Spawnable 				= false
SWEP.AdminSpawnable 		= false
SWEP.ViewModel 				= "models/weapons/v_mach_m249para.mdl"
SWEP.WorldModel 			= "models/weapons/w_mach_m249para.mdl"
SWEP.Primary.Sound 			= Sound("Weapon_M249.Single")
SWEP.Primary.Recoil 		= 0.3
SWEP.Primary.Damage 		= 22
SWEP.Primary.NumShots 		= 1
SWEP.Primary.Cone 			= 0.007
SWEP.Primary.ClipSize 		= 200
SWEP.Primary.Delay 			= 0.05
SWEP.Primary.DefaultClip 	= 30
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "ar2"
SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"
SWEP.IronSightsPos 			= Vector (-4.4153, 0.1, 2.1305)
SWEP.IronSightsAng 			= Vector (0, 0.15, 0)
SWEP.ModelRunAnglePreset	= 1
SWEP.RKick					= 10
SWEP.RRise					= 0
SWEP.RSlide					= 0
SWEP.NoCrossHair			= true
