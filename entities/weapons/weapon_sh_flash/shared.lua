local GRENADE_COOK_TIME = 2

if SERVER then
	AddCSLuaFile ("shared.lua")
	SWEP.Weight 			= 5
	SWEP.AutoSwitchTo 		= false
	SWEP.AutoSwitchFrom 	= false
end

if CLIENT then
	SWEP.PrintName 			= "FLASH GRENADE"
	SWEP.DrawAmmo 			= true
	SWEP.DrawCrosshair 		= false
	SWEP.ViewModelFOV		= 65
	SWEP.ViewModelFlip		= true
	SWEP.CSMuzzleFlashes	= false

	SWEP.IconLetter 		= "P"
	killicon.AddFont( "weapon_sh_flash", "CSKillIcons", SWEP.IconLetter, Color(200, 200, 200, 255))
end

SWEP.Instructions 			= "Stun grenades are used to confuse, disorient, \nor distract a potential threat. \nA stun grenade can seriously degrade the \ncombat effectiveness of affected personnel \nfor up to a minute. \n\nLeft click to throw your grenade on a long distance \nRight click to throw your grenade on a short distance"

SWEP.Base 					= "weapon_sh_grenade"

SWEP.Contact 				= ""
SWEP.Purpose 				= ""

SWEP.Spawnable 				= false
SWEP.AdminSpawnable 		= false

SWEP.ViewModel 				= "models/weapons/v_eq_flashbang.mdl"
SWEP.WorldModel 			= "models/weapons/w_eq_flashbang.mdl"

SWEP.Primary.ClipSize 		= -1
SWEP.Primary.DefaultClip 	= 1
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "grenade"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= true
SWEP.Secondary.Ammo 		= "none"

SWEP.GrenadeClass			= "sent_flashgrenade"
SWEP.Cookable				= true
SWEP.CookableDamage			= true


--[[function SWEP:Initialize()
		self:SetWeaponHoldType( "grenade" )
		self.CookTime = 0
		self.LastThrow = 0
		self.Drawn = false
end

function SWEP:Holster()
	if self.Primed == 1 then
		self.Primed = 2
		self.CookTime = CurTime() - self.Throw -- THIS GETS THE TIME BETWEEN WHEN YOU STARTED COOKING AND NOW
		self.Throw = CurTime() + 0
		self:ThrowGrenade( true )
	end
	self.Primed = 0
	self.Throw = CurTime()
	return true
end

function SWEP:Reload()
end

function SWEP:Think()
	self.BobScale = 0
	 if self.Primed == 1 and SERVER then
		if self.Cookable and CurTime() - self.Throw > GRENADE_COOK_TIME then -- LOL HELD TOO LONG
			self.Primed = 2
			
			self.CookTime = CurTime() - self.Throw -- THIS GETS THE TIME BETWEEN WHEN YOU STARTED COOKING AND NOW
			self.Throw = CurTime() + 0

			self.Weapon:SendWeaponAnim( ACT_VM_THROW )
			self.Owner:SetAnimation( PLAYER_ATTACK1 )
			self:ThrowGrenade( true )
		elseif !self.Owner:KeyDown( IN_ATTACK ) and self.PrimaryThrow then -- Far throw
			if self.Throw < CurTime() then
				self.Primed = 2
				self.CookTime = CurTime() - self.Throw -- THIS GETS THE TIME BETWEEN WHEN YOU STARTED COOKING AND NOW
				self.Throw = CurTime() + 0.05
				timer.Simple( 0.3, function()
				if !IsValid( self ) then return end
					self:ThrowGrenade( false )
				end)
			end

		elseif !self.Owner:KeyDown( IN_ATTACK2 ) and !self.PrimaryThrow then -- Short thow
			if self.Throw < CurTime() then
				self.Primed = 2
				self.Throw = CurTime() + 0.05

				timer.Simple( 0.3, function()
				if !IsValid( self ) then return end
					self:ThrowGrenade( true )
				end)
			end
		end
	end
	if self.LastThrow < CurTime() and self.Owner:GetAmmoCount( self.Primary.Ammo ) < 2 and !self.Drawn then
		if self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0 then
			self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
			self.Drawn = true
		end
	end
	if self.Owner:KeyReleased(IN_ATTACK) then
		self.Weapon:SendWeaponAnim( ACT_VM_THROW )
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
	end
end

function SWEP:ThrowGrenade( short )
	if self.Primed != 2 or !SERVER then return end

	local tr = self.Owner:GetEyeTrace()
	local ent = ents.Create( self.GrenadeClass )

	local v = self.Owner:GetShootPos()
		v = v + self.Owner:GetForward() * (!short and 1 or 2)
		v = v + self.Owner:GetRight() * 3
		v = v + self.Owner:GetUp() * (!short and 1 or -3)
	ent:SetPos( v )
	ent:SetAngles( Vector(math.random(1,100),math.random(1,100),math.random(1,100)) )
	ent.GrenadeOwner = self.Owner
	ent:Spawn()
	
	if self.Cookable then
		ent:SetDuration( GRENADE_COOK_TIME - self.CookTime )
		if self.CookableDamage and self.CookTime > GRENADE_COOK_TIME then
			local dmginfo = DamageInfo()
			dmginfo:SetDamage( 10 )
			dmginfo:SetAttacker( self.Owner )
			dmginfo:SetInflictor( self )
			self.Owner:TakeDamageInfo( dmginfo )
			self.Owner:SetDSP( 31 )
		end
	end
	
	if self.Owner:KeyDown( IN_FORWARD ) then
		self.Force = (!short and self.ThrowForce+200 or self.ThrowForce + 100)
	elseif self.Owner:KeyDown( IN_BACK ) then
		self.Force = (!short and self.ThrowForce-200 or self.ThrowForce - 100)
	else
		self.Force = (!short and self.ThrowForce or self.ThrowForce - 1500)
	end
	
	--if not self.Owner then return end self.Owner:ViewPunch(Vector(math.Rand(-0.1, -0.5), math.Rand(0.1, 0.5), math.Rand(-0.1, -0.5)))
 
	local phys = ent:GetPhysicsObject()
	phys:ApplyForceCenter( self.Owner:GetAimVector() * self.Force *1.2 + Vector(0,0,200) )
	phys:SetVelocity( phys:GetVelocity() + self.Owner:GetVelocity() )
	phys:AddAngleVelocity( Vector(math.random(-500,500),math.random(-500,500),math.random(-500,500)) )
	self.Owner:RemoveAmmo( 1, self.Primary.Ammo )

	
	if self.Owner:GetAmmoCount( self.Primary.Ammo ) == 0 then
		self.Owner:ConCommand( "lastinv" )
		self.Weapon:Remove()
	end
	self.LastThrow = CurTime() + 0.6
end

function SWEP:PrimaryAttack()
	if self.Throw < CurTime() and self.Primed == 0 and self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then
		self.Weapon:SendWeaponAnim( ACT_VM_PULLPIN )
		self.Primed = 1
		self.Throw = CurTime() + 0.05
		self.PrimaryThrow = true
	end
end

function SWEP:SecondaryAttack()
	if self.Throw < CurTime() and self.Primed == 0 and self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then
		self.Weapon:SendWeaponAnim( ACT_VM_PULLPIN )
		self.Primed = 1
		self.Throw = CurTime() + 0.05
		self.PrimaryThrow = false
	end
end

function SWEP:Deploy()
	self.Throw = CurTime() + 0.1
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	return true
end

function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
	draw.SimpleText( self.IconLetter, "CSSelectIcons", x + wide / 2, y + tall * 0.2, Color(255, 210, 0, 255), TEXT_ALIGN_CENTER )
	-- Draw a CS:S select icon
	self:PrintWeaponInfo( x + wide + 20, y + tall * 0.95, alpha )
	-- Print weapon information
end]]