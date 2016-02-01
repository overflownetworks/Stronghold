ENT.Type = "anim"

ENT.PrintName		= "SMOKE GRENADE"
ENT.Author			= "RoaringCow"

local SmokeSnd = Sound( "BaseSmokeEffect.Sound" )
function ENT:Initialize()
	if SERVER then
		self:SetModel( "models/weapons/w_eq_smokegrenade.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:DrawShadow( false )
		
		self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
		
		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:Wake()
		end
		
		timer.Simple( 3,
			function( ent )
				self:EmitSound( SmokeSnd )
			end, self )
	elseif CLIENT then
		self.SmokeTimer = 0
		local vOffset = self:LocalToWorld( Vector(0, 0, self:OBBMins().z) )
		self.Emitter = ParticleEmitter( vOffset )
		self.Bubbles = {}
	end
	
	self.Created = CurTime()
	self.Duration = 3
	self.Smoked = false
end

local BounceSnd = Sound( "SmokeGrenade.Bounce" )
function ENT:PhysicsCollide( data,phys )
	if data.Speed > 50 then
		self:EmitSound( BounceSnd )
	end
	local impulse = -data.Speed * data.HitNormal * .4 + (data.OurOldVelocity * -.6)
	phys:ApplyForceCenter( impulse )
end
