if (SERVER) then
	AddCSLuaFile("shared.lua")

elseif (CLIENT) then
	SWEP.PrintName 			= "D.EAGLE .44"
	SWEP.IconLetter 		= "f"

	killicon.AddFont("weapon_sh_deagle", "CSKillIcons", SWEP.IconLetter, Color(200, 200, 200, 255))
end
 
SWEP.MuzzleAttachment		= "1" 
SWEP.Base 					= "weapon_sh_base_pistol"
SWEP.Spawnable 				= true
SWEP.AdminSpawnable 		= true
SWEP.ViewModel 				= "models/weapons/v_pist_deagle.mdl"
SWEP.WorldModel 			= "models/weapons/w_pist_deagle.mdl"
SWEP.Primary.Sound 			= Sound("Weapon_Deagle.Single")
SWEP.Primary.Damage 		= 65
SWEP.Primary.NumShots 		= 1
SWEP.Primary.ClipSize 		= 7
SWEP.Primary.Delay 			= 0.1
SWEP.Primary.DefaultClip 	= 7
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= "pistol"
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"
SWEP.IronSightsPos 			= Vector (5.1465, 0.0193, 2.6677)
SWEP.IronSightsAng 			= Vector (0.2603, 0.0006, 0)

