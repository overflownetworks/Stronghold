if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.HoldType			= "pistol"
elseif (CLIENT) then
	SWEP.PrintName 			= "GLOCK 18"
	SWEP.IconLetter 		= "c"

	killicon.AddFont("weapon_sh_glock18", "CSKillIcons", SWEP.IconLetter, Color(200, 200, 200, 255))
end
	

SWEP.Base 					= "weapon_sh_base_pistol"
SWEP.Spawnable 				= true
SWEP.AdminSpawnable 		= true
SWEP.ViewModel 				= "models/weapons/v_pist_glock18.mdl"
SWEP.WorldModel 			= "models/weapons/w_pist_glock18.mdl"
SWEP.Primary.Sound 			= Sound("Weapon_Glock.Single")
SWEP.Primary.Damage 		= 10
SWEP.Primary.NumShots 		= 1
SWEP.Primary.ClipSize 		= 19
SWEP.Primary.Delay 			= 0.05
SWEP.Primary.DefaultClip 	= 19
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "pistol"
SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"
SWEP.FireSelect				= 1
SWEP.IronSightsPos = Vector (4.3305, 0.1, 2.7697)
SWEP.IronSightsAng = Vector (0.7171, -0.0077, 0)