if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.HoldType 		= "ar2"
elseif (CLIENT) then
	SWEP.PrintName 		= "STEYR AUG A1"
	SWEP.IconLetter 		= "e"

	killicon.AddFont("weapon_sh_aug", "CSKillIcons", SWEP.IconLetter, Color(200, 200, 200, 255))

end


SWEP.MuzzleAttachment		= "1" 
SWEP.Base 					= "weapon_sh_base"
SWEP.Spawnable 				= true
SWEP.AdminSpawnable 		= true
SWEP.ViewModel 				= "models/weapons/v_rif_aug.mdl"
SWEP.WorldModel 			= "models/weapons/w_rif_aug.mdl"
SWEP.Primary.Sound 			= Sound("Weapon_Aug.Single")
SWEP.Primary.Damage 		= 22
SWEP.Primary.NumShots 		= 1
SWEP.Primary.ClipSize 		= 30
SWEP.Primary.Delay 			= 0.08
SWEP.Primary.DefaultClip 	= 30
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "ar2"
SWEP.IronSightZoom			= 2 -- How much the player's FOV should zoom in ironsight mode. 
SWEP.UseScope				= true -- Use a scope instead of iron sights.
SWEP.DrawParabolicSights	= false -- Set to true to draw a cool parabolic sight (helps with aiming over long distances)
SWEP.Sniper					= true
SWEP.MSniper				= true