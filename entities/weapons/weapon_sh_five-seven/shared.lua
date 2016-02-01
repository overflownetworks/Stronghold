if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.HoldType			= "pistol"
elseif (CLIENT) then
	SWEP.PrintName 			= "FN FIVE-SEVEN"
	SWEP.IconLetter 		= "u"

	killicon.AddFont("weapon_sh_five-seven", "CSKillIcons", SWEP.IconLetter, Color(200, 200, 200, 255))
end

SWEP.EjectDelay				= 0.05
SWEP.Base 					= "weapon_sh_base_pistol"
SWEP.Spawnable 				= true
SWEP.AdminSpawnable 		= true
SWEP.ViewModel 				= "models/weapons/v_pist_fiveseven.mdl"
SWEP.WorldModel 			= "models/weapons/w_pist_fiveseven.mdl"
SWEP.Primary.Sound 			= Sound("Weapon_FiveSeven.Single")
SWEP.Primary.Recoil 		= 0.2
SWEP.Primary.Damage 		= 10
SWEP.Primary.NumShots 		= 1
SWEP.Primary.ClipSize 		= 20
SWEP.Primary.Delay 			= 0.05
SWEP.Primary.DefaultClip 	= 20
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= "pistol"
SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"
SWEP.IronSightsPos 			= Vector (4.5282, -0.1, 3.3248)
SWEP.IronSightsAng 			= Vector (-0.4139, -0.0182, 0)