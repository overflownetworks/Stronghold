if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.HoldType 		= "shotgun"
elseif (CLIENT) then
	SWEP.PrintName 		= "M3 SUPER 90"
	SWEP.IconLetter 	= "k"
	SWEP.Slot 			= 1
	killicon.AddFont("weapon_sh_pumpshotgun2", "CSKillIcons", SWEP.IconLetter, Color(200, 200, 200, 255))
end
SWEP.MuzzleAttachment		= "1" 
SWEP.Base 					= "weapon_sh_base"
SWEP.Spawnable 				= true
SWEP.AdminSpawnable 		= true
SWEP.ViewModel 				= "models/weapons/v_shot_m3super90.mdl"
SWEP.WorldModel 			= "models/weapons/w_shot_m3super90.mdl"
SWEP.Primary.Sound 			= Sound("Weapon_M3.Single")
SWEP.Primary.Recoil 		= 5
SWEP.Primary.Damage 		= 7
SWEP.Primary.NumShots 		= 9
SWEP.Primary.Cone 			= 0.05
SWEP.Primary.ClipSize 		= 8
SWEP.Primary.Delay 			= 0.75
SWEP.Primary.DefaultClip 	= 8
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= "buckshot"
SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.RMod					= 0
SWEP.Zoom					= 0
SWEP.FireSelect				= 0
SWEP.IronCycleSpeed			= 1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"
SWEP.IronSightsPos 		= Vector (5.7431, -1.6786, 3.3682)
SWEP.IronSightsAng 		= Vector (0.0634, -0.0235, 0)
SWEP.RunArmAngle  = Angle( -10, 50, 6 )
SWEP.RunArmOffset = Vector( 1, -0.1, -5 )