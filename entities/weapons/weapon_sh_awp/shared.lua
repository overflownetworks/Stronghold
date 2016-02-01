if (SERVER) then
	AddCSLuaFile("shared.lua")

elseif (CLIENT) then
	SWEP.PrintName 			= "UTG L96"
	SWEP.ViewModelFOV		= 60
	SWEP.IconLetter 		= "r"

	killicon.AddFont("weapon_sh_awp", "CSKillIcons", SWEP.IconLetter, Color(200, 200, 200, 255))
end

SWEP.MuzzleAttachment		= "1" 
SWEP.Base 					= "weapon_sh_base"
SWEP.Spawnable 				= false
SWEP.AdminSpawnable 		= false
SWEP.ViewModel 				= "models/weapons/v_snip_awp.mdl"
SWEP.WorldModel 			= "models/weapons/w_snip_awp.mdl"
SWEP.Primary.Sound 			= Sound("Weapon_AWP.Single")
SWEP.Primary.Damage 		= 96
SWEP.Primary.Recoil 		= 2
SWEP.Primary.NumShots 		= 1
SWEP.Primary.ClipSize 		= 5
SWEP.Primary.Delay 			= 1
SWEP.Primary.DefaultClip 	= 5
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= "ar2"
SWEP.IronSightZoom			= 30
SWEP.UseScope				= true 
SWEP.DrawParabolicSights	= false
SWEP.FireSelect				= 0
SWEP.Sniper					= true
