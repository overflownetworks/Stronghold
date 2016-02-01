ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "Weapon Crate"
ENT.Author			= "RoaringCow"

ENT.Spawnable			= false
ENT.AdminSpawnable		= false

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

ENT.OpenSnd = Sound( "AmmoCrate.Open" )
ENT.CloseSnd = Sound( "AmmoCrate.Close" )

function ENT:SpawnFunction( ply, tr )
	if !tr.Hit then return end
	local SpawnPos = tr.HitPos
	local ent = ents.Create( "sent_weaponcrate" )
	
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	ent.Owner = ply
	if !ply.WeaponCrate then ply.WeaponCrate = {} end
	ply.WeaponCrate[self:EntIndex()] = self
	
	return ent
end

function ENT:Initialize()
	self.Created = CurTime()

	self:SetModel( "models/Items/ammocrate_smg2.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_NONE )

	self.WeaponModel = ents.Create( "prop_dynamic" )
	self.WeaponModel:SetModel( "models/weapons/w_pist_glock18.mdl" )
	self.WeaponModel:SetParent( self )
	self.WeaponModel:SetLocalPos( Vector(1,-20,0) )
	self.WeaponModel:SetLocalAngles( Angle(0,180,90) )
	self.WeaponModel:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self.WeaponModel:Spawn()

	self.WeaponModel = ents.Create( "prop_dynamic" )
	self.WeaponModel:SetModel( "models/weapons/w_pist_p228.mdl" )
	self.WeaponModel:SetParent( self )
	self.WeaponModel:SetLocalPos( Vector(-12,-20,0) )
	self.WeaponModel:SetLocalAngles( Angle(0,0,90) )
	self.WeaponModel:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self.WeaponModel:Spawn()

	self.WeaponModel = ents.Create( "prop_dynamic" )
	self.WeaponModel:SetModel( "models/weapons/w_pist_deagle.mdl" )
	self.WeaponModel:SetParent( self )
	self.WeaponModel:SetLocalPos( Vector(0,-17,0) )
	self.WeaponModel:SetLocalAngles( Angle(0,20,90) )
	self.WeaponModel:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self.WeaponModel:Spawn()

	self.WeaponModel = ents.Create( "prop_dynamic" )
	self.WeaponModel:SetModel( "models/weapons/w_pist_elite_single.mdl" )
	self.WeaponModel:SetParent( self )
	self.WeaponModel:SetLocalPos( Vector(13,-12,0) )
	self.WeaponModel:SetLocalAngles( Angle(0,200,90) )
	self.WeaponModel:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self.WeaponModel:Spawn()

	self.WeaponModel = ents.Create( "prop_dynamic" )
	self.WeaponModel:SetModel( "models/weapons/w_smg_ump45.mdl" )
	self.WeaponModel:SetParent( self )
	self.WeaponModel:SetLocalPos( Vector(5,-25,5) )
	self.WeaponModel:SetLocalAngles( Angle(10,-180,0) )
	self.WeaponModel:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self.WeaponModel:Spawn()

	self.WeaponModel = ents.Create( "prop_dynamic" )
	self.WeaponModel:SetModel( "models/weapons/w_smg_p90.mdl" )
	self.WeaponModel:SetParent( self )
	self.WeaponModel:SetLocalPos( Vector(6,-22,5) )
	self.WeaponModel:SetLocalAngles( Angle(10,-180,0) )
	self.WeaponModel:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self.WeaponModel:Spawn()

	self.WeaponModel = ents.Create( "prop_dynamic" )
	self.WeaponModel:SetModel( "models/weapons/w_smg_tmp.mdl" )
	self.WeaponModel:SetParent( self )
	self.WeaponModel:SetLocalPos( Vector(15,-21,5) )
	self.WeaponModel:SetLocalAngles( Angle(10,-180,0) )
	self.WeaponModel:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self.WeaponModel:Spawn()

	self.WeaponModel = ents.Create( "prop_dynamic" )
	self.WeaponModel:SetModel( "models/weapons/w_smg_mac10.mdl" )
	self.WeaponModel:SetParent( self )
	self.WeaponModel:SetLocalPos( Vector(15,-19,5) )
	self.WeaponModel:SetLocalAngles( Angle(10,-180,0) )
	self.WeaponModel:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self.WeaponModel:Spawn()


--rifles
	self.WeaponModel = ents.Create( "prop_dynamic" )
	self.WeaponModel:SetModel( "models/weapons/w_snip_awp.mdl" )
	self.WeaponModel:SetParent( self )
	self.WeaponModel:SetLocalPos( Vector(-16,16,5) )
	self.WeaponModel:SetLocalAngles( Angle(10,-90,0) )
	self.WeaponModel:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self.WeaponModel:Spawn()

	self.WeaponModel = ents.Create( "prop_dynamic" )
	self.WeaponModel:SetModel( "models/weapons/w_snip_g3sg1.mdl" )
	self.WeaponModel:SetParent( self )
	self.WeaponModel:SetLocalPos( Vector(-11,16,5) )
	self.WeaponModel:SetLocalAngles( Angle(10,-90,0) )
	self.WeaponModel:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self.WeaponModel:Spawn()

	self.WeaponModel = ents.Create( "prop_dynamic" )
	self.WeaponModel:SetModel( "models/weapons/w_snip_sg550.mdl" )
	self.WeaponModel:SetParent( self )
	self.WeaponModel:SetLocalPos( Vector(-9,18,5) )
	self.WeaponModel:SetLocalAngles( Angle(10,-90,0) )
	self.WeaponModel:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self.WeaponModel:Spawn()

	self.WeaponModel = ents.Create( "prop_dynamic" )
	self.WeaponModel:SetModel( "models/weapons/w_rif_galil.mdl" )
	self.WeaponModel:SetParent( self )
	self.WeaponModel:SetLocalPos( Vector(-7,18,5) )
	self.WeaponModel:SetLocalAngles( Angle(10,-90,0) )
	self.WeaponModel:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self.WeaponModel:Spawn()

	self.WeaponModel = ents.Create( "prop_dynamic" )
	self.WeaponModel:SetModel( "models/weapons/w_shot_xm1014.mdl" )
	self.WeaponModel:SetParent( self )
	self.WeaponModel:SetLocalPos( Vector(-5,18,5) )
	self.WeaponModel:SetLocalAngles( Angle(10,-90,0) )
	self.WeaponModel:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self.WeaponModel:Spawn()

	self.WeaponModel = ents.Create( "prop_dynamic" )
	self.WeaponModel:SetModel( "models/weapons/w_shot_m3super90.mdl" )
	self.WeaponModel:SetParent( self )
	self.WeaponModel:SetLocalPos( Vector(-2,18,5) )
	self.WeaponModel:SetLocalAngles( Angle(10,-90,0) )
	self.WeaponModel:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self.WeaponModel:Spawn()

	self.WeaponModel = ents.Create( "prop_dynamic" )
	self.WeaponModel:SetModel( "models/weapons/w_snip_scout.mdl" )
	self.WeaponModel:SetParent( self )
	self.WeaponModel:SetLocalPos( Vector(-1,18,5) )
	self.WeaponModel:SetLocalAngles( Angle(10,-90,0) )
	self.WeaponModel:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self.WeaponModel:Spawn()

	self.WeaponModel = ents.Create( "prop_dynamic" )
	self.WeaponModel:SetModel( "models/weapons/w_smg_mp5.mdl" )
	self.WeaponModel:SetParent( self )
	self.WeaponModel:SetLocalPos( Vector(2,18,2) )
	self.WeaponModel:SetLocalAngles( Angle(10,-90,0) )
	self.WeaponModel:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self.WeaponModel:Spawn()

	self.WeaponModel = ents.Create( "prop_dynamic" )
	self.WeaponModel:SetModel( "models/weapons/w_rif_ak47.mdl" )
	self.WeaponModel:SetParent( self )
	self.WeaponModel:SetLocalPos( Vector(5,18,5) )
	self.WeaponModel:SetLocalAngles( Angle(5,-90,0) )
	self.WeaponModel:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self.WeaponModel:Spawn()

	self.WeaponModel = ents.Create( "prop_dynamic" )
	self.WeaponModel:SetModel( "models/weapons/w_rif_m4a1.mdl" )
	self.WeaponModel:SetParent( self )
	self.WeaponModel:SetLocalPos( Vector(7,18,5) )
	self.WeaponModel:SetLocalAngles( Angle(5,-90,0) )
	self.WeaponModel:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self.WeaponModel:Spawn()

	self.WeaponModel = ents.Create( "prop_dynamic" )
	self.WeaponModel:SetModel( "models/weapons/w_rif_aug.mdl" )
	self.WeaponModel:SetParent( self )
	self.WeaponModel:SetLocalPos( Vector(10,17,5) )
	self.WeaponModel:SetLocalAngles( Angle(5,-90,0) )
	self.WeaponModel:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self.WeaponModel:Spawn()

	self.WeaponModel = ents.Create( "prop_dynamic" )
	self.WeaponModel:SetModel( "models/weapons/w_rif_sg552.mdl" )
	self.WeaponModel:SetParent( self )
	self.WeaponModel:SetLocalPos( Vector(14,17,5) )
	self.WeaponModel:SetLocalAngles( Angle(5,-90,0) )
	self.WeaponModel:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self.WeaponModel:Spawn()

	local physobj = self:GetPhysicsObject()
	if IsValid( physobj ) then
		physobj:Wake()
		physobj:EnableMotion( false )
	end
	
	self.SteamID = nil
	self.PlayerLeft = 0
end

function ENT:Use( activator, caller )
	if IsValid( activator ) and activator:IsPlayer() and activator.WeaponLoadout != true then
		local trace = activator:GetEyeTrace()
		if trace.Entity != self or (trace.StartPos-trace.HitPos):Length() > 50 then return end
	
		activator.WeaponLoadout = true
		activator:ConCommand( "sh_loadout" )
		self:Open( ent )
		self.activator = activator
	end
end

function ENT:Open( ply )
	local seq = self:LookupSequence( "Open" )
	self:SetSequence(2)
	if self.Closed then
		self:EmitSound( self.OpenSnd )
	end
	self.Closed = false
end

function ENT:Close()
	if self.Closed or !IsValid( self.activator ) then return end
	local trace = self.activator:GetEyeTrace()
	if trace.Entity != self or (trace.StartPos-trace.HitPos):Length() > 50 then
		local seq = self:LookupSequence( "Close" )
		self:SetSequence(3)
		self:EmitSound( self.CloseSnd )
		self.Closed = true
		self.activator = nil
	end
end

function ENT:Think()
	self:Close()
	
	if SERVER then
		local ply = self.Owner
		if !IsValid( ply ) and self.SteamID != nil then
			if self.PlayerLeft == 0 then
				self.PlayerLeft = CurTime()
			elseif CurTime() - self.PlayerLeft > 120 then
				self:Remove()
			end
			return
		elseif self.SteamID == nil then
			self.SteamID = ply:SteamID()
		end
	end
end