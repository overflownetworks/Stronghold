if (SERVER) then
	AddCSLuaFile("shared.lua")

elseif (CLIENT) then
	SWEP.PrintName 			= "HK G3SG1"
	SWEP.IconLetter 		= "i"

	killicon.AddFont("weapon_sh_g3sg1", "CSKillIcons", SWEP.IconLetter,Color(200, 200, 200, 255) )
end


SWEP.MuzzleEffect			= "sniper"
SWEP.MuzzleAttachment		= "1" 
SWEP.ShellEjectAttachment	= "2" 
SWEP.Base 					= "weapon_sh_base"
SWEP.Spawnable 				= true
SWEP.AdminSpawnable 		= true
SWEP.ViewModel 				= "models/weapons/v_snip_g3sg1.mdl"
SWEP.WorldModel 			= "models/weapons/w_snip_g3sg1.mdl"
SWEP.Primary.Sound 			= Sound("Weapon_G3SG1.Single")
SWEP.Primary.Damage 		= 30
SWEP.Primary.NumShots 		= 1
SWEP.Primary.ClipSize 		= 20
SWEP.Primary.Delay 			= 0.1
SWEP.Primary.DefaultClip 	= 20
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "ar2"
SWEP.IronSightZoom			= 4
SWEP.UseScope				= true
SWEP.DrawParabolicSights	= false
SWEP.Sniper					= true