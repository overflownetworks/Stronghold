if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.HoldType 		= "ar2"
elseif (CLIENT) then
	SWEP.PrintName 		= "GALIL SAR"
	SWEP.IconLetter 		= "v"
	SWEP.ViewModelFlip	= false

	killicon.AddFont("weapon_sh_galil", "CSKillIcons", SWEP.IconLetter, Color(200, 200, 200, 255))
end


SWEP.Base 					= "weapon_sh_base"
SWEP.Spawnable 				= true
SWEP.AdminSpawnable 		= true
SWEP.ViewModel 				= "models/weapons/v_rif_galil.mdl"
SWEP.WorldModel 			= "models/weapons/w_rif_galil.mdl"
SWEP.Primary.Sound 			= Sound("Weapon_Galil.Single")
SWEP.Primary.Recoil 		= 0.65
SWEP.Primary.Damage 		= 22
SWEP.Primary.NumShots 		= 1
SWEP.Primary.Cone 			= 0.003
SWEP.Primary.ClipSize 		= 35
SWEP.Primary.Delay 			= 0.08
SWEP.Primary.DefaultClip 	= 35
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "ar2"
SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"
SWEP.RMod					= 1
SWEP.RRise					= 0.0
SWEP.IronSightsPos 			= Vector(-5.15,0.1,2.37)
SWEP.IronSightsAng 			= Vector(-.4,0,0)
SWEP.ModelRunAnglePreset	= 1