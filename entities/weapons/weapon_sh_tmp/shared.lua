if (SERVER) then
	AddCSLuaFile("shared.lua")

elseif (CLIENT) then
	SWEP.DrawAmmo			= true
	SWEP.PrintName 			= "STEYR TMP"
	SWEP.IconLetter 		= "d"

	killicon.AddFont("weapon_sh_tmp", "CSKillIcons", SWEP.IconLetter, Color(200, 200, 200, 255))
end

SWEP.HoldType				= "smg"
SWEP.MuzzleEffect			= "silenced"
SWEP.ShellEffect			= "rg_shelleject" 
SWEP.MuzzleAttachment		= "1" 
SWEP.ShellEjectAttachment	= "2" 
SWEP.Base 					= "weapon_sh_base_pistol"
SWEP.Spawnable 				= true
SWEP.AdminSpawnable 		= true
SWEP.ViewModel 				= "models/weapons/v_smg_tmp.mdl"
SWEP.WorldModel 			= "models/weapons/w_smg_tmp.mdl"
SWEP.Primary.Sound 			= Sound("Weapon_TMP.Single")
SWEP.Primary.Recoil 		= 0.25
SWEP.Primary.Damage 		= 10
SWEP.Primary.NumShots 		= 1
SWEP.Primary.Cone 			= 0.008
SWEP.Primary.ClipSize 		= 30
SWEP.Primary.Delay 			= 0.045
SWEP.Primary.DefaultClip 	= 30
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "smg1"
SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"
SWEP.ModelRunAnglePreset	= 2
SWEP.FireSelect				= 1
SWEP.RMod					= 1
SWEP.RRise					= -0.001
SWEP.SlideLocks				= 0
SWEP.FreeFloatHair			= 0
SWEP.SMG					= true
SWEP.IronSightsPos = Vector (5.234, 0.1, 2.5)
SWEP.IronSightsAng = Vector (0.6531, -0.0248, 0)






