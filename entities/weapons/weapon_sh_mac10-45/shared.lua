if (SERVER) then
	AddCSLuaFile("shared.lua")

elseif (CLIENT) then
	SWEP.PrintName 			= "MAC 10 .45"
	SWEP.IconLetter 		= "l"

	killicon.AddFont("weapon_sh_mac10-45", "CSKillIcons", SWEP.IconLetter, Color(200, 200, 200, 255))
end

SWEP.Base 					= "weapon_sh_mac11-380"
SWEP.Primary.Recoil 		= 0.35
SWEP.Primary.Damage 		= 13
SWEP.Primary.Delay 			= 0.052 


