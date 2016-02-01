if (SERVER) then
	AddCSLuaFile("shared.lua")
elseif (CLIENT) then
	SWEP.PrintName 		= "RPG"
	SWEP.IconLetter 	= ";"
	SWEP.Slot 			= 0
	SWEP.ViewModelFlip	= false
	SWEP.DrawAmmo		= false

	killicon.AddFont("weapon_sh_rpg", "HalfLife2", SWEP.IconLetter, Color(200, 200, 200, 255))
end

SWEP.Base 					= "weapon_sh_base"
SWEP.Spawnable 				= true
SWEP.AdminSpawnable 		= true
SWEP.HoldType 				= "rpg"	
SWEP.Primary.ClipSize 		= 1
SWEP.Primary.Delay 			= 0.5
SWEP.Primary.Automatic 		= true
SWEP.Primary.DefaultClip 	= 0
SWEP.Primary.Ammo			= "rpg_round"
SWEP.ViewModel				= "models/weapons/v_rpg.mdl"
SWEP.WorldModel				= "models/weapons/w_rocket_launcher.mdl"
SWEP.Primary.Sound			= Sound( "weapons/rpg/rocketfire1.wav" )
SWEP.Primary.Damage			= 10
SWEP.Primary.Cone			= 0.01
SWEP.Secondary.Ammo			= "none"
SWEP.FreeFloatHair			= 1
SWEP.ModelRunAnglePreset	= 5
SWEP.FireSelect				= 0
SWEP.IronSightsPos 			= Vector (-10, 0, 0)
SWEP.IronSightsAng 			= Vector (0, 0, 0)


function SWEP:RunAnglePreset()
self.RunArmAngle  = Angle( -10, -10, -10 )
self.RunArmOffset = Vector( 5, -5, 0 )
end
	
function SWEP:CSShootBullet()

	local tr = self.Owner:GetEyeTrace()
	local ent = ents.Create( "sent_rocket" )

	local v = self.Owner:GetShootPos()
		v = v + self.Owner:GetForward() * (!short and 1 or 2)
		v = v + self.Owner:GetRight() * 3
		v = v + self.Owner:GetUp() * (!short and 1 or -3)
	if SERVER then
	ent:SetPos( v )
	ent:SetOwner( self.Owner )
	ent:SetAngles(self.Owner:EyeAngles())
	ent.RocketOwner = self.Owner
	ent:Spawn()
 
	local phys = ent:GetPhysicsObject()
	phys:ApplyForceCenter( self.Owner:GetAimVector() * 10000000 + Vector(0,0,200) )
	--phys:SetVelocity( phys:GetVelocity() + self.Owner:GetVelocity() )
	phys:EnableGravity(false)
	end
	self.Owner:RemoveAmmo( 0, self.Primary.Ammo )
	
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK ) 		// View model animation
	self.Owner:MuzzleFlash()								// Crappy muzzle light
	self.Owner:SetAnimation( PLAYER_ATTACK1 )				// 3rd Person Animation
	
	if ( self.Owner:IsNPC() ) then return end
		
end

function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	draw.SimpleText( self.IconLetter, "HalfLife2", x + wide*0.5, y + tall*0.1, Color( 255, 220, 0, 255 ), TEXT_ALIGN_CENTER )
end