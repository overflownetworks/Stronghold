if (SERVER) then
	AddCSLuaFile("shared.lua")

elseif (CLIENT) then
	SWEP.PrintName 			= "SIG SG-550 SNIPER"
	SWEP.ViewModelFOV		= 60
	SWEP.IconLetter 		= "o"

	killicon.AddFont("weapon_sh_sg550", "CSKillIcons", SWEP.IconLetter, Color(200, 200, 200, 255))
end

SWEP.MuzzleEffect			= "sniper" 
SWEP.MuzzleAttachment		= "1" 
SWEP.ShellEjectAttachment	= "2" 
SWEP.Base 					= "weapon_sh_base"
SWEP.Spawnable 				= true
SWEP.AdminSpawnable 		= true
SWEP.ViewModel 				= "models/weapons/v_snip_sg550.mdl"
SWEP.WorldModel 			= "models/weapons/w_snip_sg550.mdl"
SWEP.Primary.Sound 			= Sound("Weapon_SG550.Single")
SWEP.Primary.Damage 		= 22
SWEP.Primary.NumShots 		= 1
SWEP.Primary.ClipSize 		= 30
SWEP.Primary.Delay 			= 0.085
SWEP.Primary.DefaultClip 	= 30
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "ar2"
SWEP.IronSightZoom			= 4
SWEP.UseScope				= true
SWEP.DrawParabolicSights	= false
SWEP.Sniper					= true