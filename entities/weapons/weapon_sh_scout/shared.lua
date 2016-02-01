if (SERVER) then
	AddCSLuaFile("shared.lua")

elseif (CLIENT) then
	SWEP.PrintName 			= "STEYR SCOUT SNIPER"
	SWEP.ViewModelFOV		= 60
	SWEP.IconLetter 		= "n"

	killicon.AddFont("weapon_sh_scout", "CSKillIcons", SWEP.IconLetter, Color(200, 200, 200, 255))
end

SWEP.MuzzleAttachment		= "1" 
SWEP.Base					= "weapon_sh_base"
SWEP.Spawnable 				= true
SWEP.AdminSpawnable 		= true
SWEP.ViewModel 				= "models/weapons/v_snip_scout.mdl"
SWEP.WorldModel 			= "models/weapons/w_snip_scout.mdl"
SWEP.Primary.Sound 			= Sound("Weapon_SCOUT.Single")
SWEP.Primary.Damage 		= math.Rand (15,25)
SWEP.Primary.Recoil 		= 1
SWEP.Primary.NumShots 		= 1
SWEP.Primary.ClipSize 		= 10
SWEP.Primary.Delay 			= 1.2
SWEP.Primary.DefaultClip 	= 10
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= "ar2"
SWEP.IronSightZoom			= 30
SWEP.UseScope				= true
SWEP.DrawParabolicSights	= false 
SWEP.FireSelect 			= 0
SWEP.Sniper					= true