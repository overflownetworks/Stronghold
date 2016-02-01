if (SERVER) then
	AddCSLuaFile("shared.lua")

elseif (CLIENT) then
	SWEP.PrintName 			= "HK MP-5A5"
	SWEP.IconLetter 		= "x"

	killicon.AddFont("weapon_sh_mp5a4", "CSKillIcons", SWEP.IconLetter, Color(200, 200, 200, 255))
end

SWEP.ShellEffect			= "rg_shelleject"
SWEP.MuzzleEffect			= "pistol" 
SWEP.Base 					= "weapon_sh_base"
SWEP.Spawnable 				= true
SWEP.AdminSpawnable 		= true
SWEP.ViewModel 				= "models/weapons/v_smg_mp5.mdl"
SWEP.WorldModel 			= "models/weapons/w_smg_mp5.mdl"
SWEP.Primary.Sound 			= Sound("Weapon_MP5Navy.Single")
SWEP.Primary.Recoil 		= 0.3
SWEP.Primary.Damage 		= 12
SWEP.Primary.NumShots 		= 1
SWEP.Primary.Cone 			= 0.003
SWEP.Primary.ClipSize 		= 30
SWEP.Primary.Delay 			= 0.075
SWEP.Primary.DefaultClip 	= 30
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "smg1"
SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.SMG					= true
SWEP.Secondary.Ammo 		= "none"
SWEP.RMod					= 1
SWEP.RKick					= 10
SWEP.RRise					= 0.01
SWEP.IronSightsPos 			= Vector (4.7456, 0.1, 1.7982)
SWEP.IronSightsAng 			= Vector (1.1947, -0.0424, 0)