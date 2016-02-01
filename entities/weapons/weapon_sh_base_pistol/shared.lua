if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.Weight 		= 5
elseif (CLIENT) then
	SWEP.DrawAmmo			= true		
	SWEP.DrawCrosshair		= false		
	SWEP.ViewModelFOV		= 60			
	SWEP.ViewModelFlip		= true
	SWEP.Slot 			= 1

	-- This is the font that's used to draw the death icons
	surface.CreateFont("csd", ScreenScale(30), 500, true, true, "CSKillIcons")

	-- This is the font that's used to draw the select icons
	surface.CreateFont("csd", ScreenScale(60), 500, true, true, "CSSelectIcons")

	-- This is the font that's used to draw the firemod icons
	surface.CreateFont("HalfLife2", ScrW() / 60, 500, true, true, "Firemode")
end
SWEP.HoldType		= "pistol"
SWEP.Base					= "weapon_sh_base"
SWEP.MuzzleEffect			= "pistol" 
SWEP.ShellEffect			= "rg_shelleject" 
SWEP.MuzzleAttachment		= "1" 
SWEP.ShellEjectAttachment	= "2"
SWEP.EjectDelay				= 0
SWEP.DrawWeaponInfoBox  	= true
SWEP.Contact 				= ""
SWEP.Purpose 				= ""
SWEP.Instructions 			= ""
SWEP.Spawnable 				= false
SWEP.AdminSpawnable 		= false
SWEP.Weight 				= 5
SWEP.AutoSwitchTo 			= false
SWEP.AutoSwitchFrom 		= false
SWEP.Primary.Sound 			= Sound("Weapon_AK47.Single")
SWEP.Primary.Recoil 		= 0.5
SWEP.Primary.Damage 		= 0
SWEP.Primary.NumShots 		= 0
SWEP.Primary.Cone 			= 0.01
SWEP.Primary.ClipSize 		= 0
SWEP.Primary.Delay 			= 0
SWEP.Primary.DefaultClip 	= 0
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= "none"
SWEP.Secondary.ClipSize 	= 0
SWEP.Secondary.DefaultClip 	= 0
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"
SWEP.SlideLocks				= 1
SWEP.FireSelect				= 0
SWEP.Look					= 1
SWEP.CycleSpeed				= 1
SWEP.IronCycleSpeed			= 2
SWEP.RMod					= 0
SWEP.RKick					= 10
SWEP.ModelRunAnglePreset	= 3
SWEP.Pistol					= true
SWEP.Zoom					= 75
