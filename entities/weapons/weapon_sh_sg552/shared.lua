if (SERVER) then
	AddCSLuaFile("shared.lua")
	AddCSLuaFile("cl_init.lua")

elseif (CLIENT) then
	SWEP.PrintName 			= "SIG SG-552"
	SWEP.ViewModelFOV		= 60
	SWEP.IconLetter 		= "A"

	killicon.AddFont("weapon_sh_sg552", "CSKillIcons", SWEP.IconLetter, Color(200, 200, 200, 255))
end


SWEP.MuzzleAttachment		= "1" 
SWEP.Base 					= "weapon_sh_base"
SWEP.Spawnable 				= true
SWEP.AdminSpawnable 		= true
SWEP.ViewModel 				= "models/weapons/v_rif_sg552.mdl"
SWEP.WorldModel 			= "models/weapons/w_rif_sg552.mdl"
SWEP.Primary.Sound 			= Sound("Weapon_SG552.Single")
SWEP.Primary.Damage 		= 22
SWEP.Primary.NumShots 		= 1
SWEP.Primary.Recoil			= 1
SWEP.Primary.ClipSize 		= 30
SWEP.Primary.Delay 			= 0.08
SWEP.Primary.DefaultClip 	= 30
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "ar2"
SWEP.IronSightZoom			= 2 -- How much the player's FOV should zoom in ironsight mode. 
SWEP.UseScope				= true -- Use a scope instead of iron sights.
SWEP.DrawParabolicSights	= true -- Set to true to draw a cool parabolic sight (helps with aiming over long distances)
SWEP.Acog					= true
SWEP.Sniper					= true
SWEP.MSniper				= true