if (SERVER) then
	AddCSLuaFile("shared.lua")

elseif (CLIENT) then
	SWEP.PrintName 			= "MAC 11 .380"
	SWEP.IconLetter 		= "l"

	killicon.AddFont("weapon_sh_mac10-380", "CSKillIcons", SWEP.IconLetter, Color(200, 200, 200, 255))
end

SWEP.Base 					= "weapon_sh_base_pistol"
SWEP.Spawnable 				= true
SWEP.AdminSpawnable 		= true
SWEP.ViewModel 				= "models/weapons/v_smg_mac10.mdl"
SWEP.WorldModel 			= "models/weapons/w_smg_mac10.mdl"
SWEP.Primary.Sound 			= Sound("Weapon_MAC10.Single")
SWEP.Primary.Recoil 		= 0.25
SWEP.Primary.Damage 		= 8
SWEP.Primary.NumShots 		= 1
SWEP.Primary.Cone 			= 0.006
SWEP.Primary.ClipSize 		= 30
SWEP.Primary.Delay 			= 0.050
SWEP.Primary.DefaultClip 	= 30
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "smg1"
SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"
SWEP.FireSelect				= 1
SWEP.FreeFloatHair			= 0
SWEP.ModelRunAnglePreset	= 2
SWEP.RMod 					= 1
SWEP.RRise					= -0.001
SWEP.RSlide					= 0.0142
SWEP.Mac10					= true
SWEP.IronSightsPos = Vector (6.97, 0.1, 2.9021)
SWEP.IronSightsAng = Vector (0.7379, 5.25, 7.5801)
SWEP.HoldType				= "smg"
 

