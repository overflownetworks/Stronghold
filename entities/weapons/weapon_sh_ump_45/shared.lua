if (SERVER) then
	AddCSLuaFile("shared.lua")

elseif (CLIENT) then
	SWEP.PrintName 			= "HK UMP-45"
	SWEP.IconLetter 		= "q"
	SWEP.ViewModelFOV		= 55

	killicon.AddFont("weapon_sh_ump_45", "CSKillIcons", SWEP.IconLetter,Color(200, 200, 200, 255))
end

SWEP.ShellEffect			= "rg_shelleject"
SWEP.Base 					= "weapon_sh_base"
SWEP.Spawnable 				= true
SWEP.AdminSpawnable 		= true
SWEP.ViewModel 				= "models/weapons/v_smg_ump45.mdl"
SWEP.WorldModel 			= "models/weapons/w_smg_ump45.mdl"
SWEP.Primary.Sound 			= Sound("Weapon_UMP45.Single")
SWEP.Primary.Recoil 		= 0.6
SWEP.Primary.Damage 		= 15
SWEP.Primary.NumShots 		= 1
SWEP.Primary.Cone 			= 0.004
SWEP.Primary.ClipSize 		= 25
SWEP.Primary.Delay 			= 0.08
SWEP.Primary.DefaultClip 	= 25
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "smg1"
SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"
SWEP.RMod					= 1
SWEP.RKick					= 10
SWEP.RRise					= -0.01
SWEP.RSlide					= 0.001
SWEP.IronSightsPos = Vector (7.3298, 0.1, 3.3176)
SWEP.IronSightsAng = Vector (-1.361, 0.3, 1.5171)
SWEP.SMG					= true
