if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.HoldType 		= "pistol"
elseif (CLIENT) then
	SWEP.PrintName 		= "SIG-SAUER P228"
	SWEP.IconLetter 	= "y"

	killicon.AddFont("weapon_sh_p228", "CSKillIcons", SWEP.IconLetter, Color(200, 200, 200, 255))
end

SWEP.EjectDelay				= 0.05
SWEP.Base 					= "weapon_sh_base_pistol"
SWEP.Spawnable 				= true
SWEP.AdminSpawnable 		= true
SWEP.ViewModel 				= "models/weapons/v_pist_p228.mdl"
SWEP.WorldModel 			= "models/weapons/w_pist_p228.mdl"
SWEP.Primary.Sound 			= Sound("Weapon_P228.Single")
SWEP.Primary.Damage 		= 12
SWEP.Primary.NumShots 		= 1
SWEP.Primary.ClipSize 		= 12
SWEP.Primary.Delay 			= 0.05
SWEP.Primary.DefaultClip 	= 12
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= "pistol"
SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"
SWEP.IronSightsPos 			= Vector (4.7648, -0.0028, 2.9876)
SWEP.IronSightsAng 			= Vector (-0.6967, 0.0241, -0.0391)


	