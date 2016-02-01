AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:SpawnFunction( ply, tr )
	if !tr.Hit then return end
	local SpawnPos = tr.HitPos
	local ent = ents.Create( "sent_spawnpoint" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	ent.Owner = ply
	if !ply.SpawnPoint then ply.SpawnPoint = {} end
	ply.SpawnPoint[self:EntIndex()] = self
	return ent
end

function ENT:Initialize()
	self.Created = CurTime()
	self:SetModel( "models/props_combine/combine_mine01.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
		phys:EnableDrag(true)
		phys:EnableMotion(true)
	end
	self.Blocked = false
	
	self.SteamID = nil
	self.PlayerLeft = 0
	self.LastTeamUpdate = 0
end

function ENT:Use()
return false
end

function ENT:OnRemove()
	local ply = self.Owner
	if !IsValid( ply ) or !ply.SpawnPoint then return end

	ply.SpawnPoint[self:EntIndex()] = nil
end

function ENT:Think()
	local ply = self.Owner
	if !IsValid( ply ) and self.SteamID != nil then
		if self.PlayerLeft == 0 then
			self.PlayerLeft = CurTime()
		elseif CurTime() - self.PlayerLeft > 1 then
			self:Remove()
		end
		return
	elseif self.SteamID == nil then
		self.SteamID = ply:SteamID()
		return
	end
	
	local hp = self:Health()
	local hpmax = self:GetMaxHealth()
	local c = 255 * (hp / hpmax)
	self:SetHealth(math.Clamp(hp + 0.25,1,hpmax))
	self:SetColor(c, c, c, 255)
	
	--[[local pos, up = self:LocalToWorld( self:OBBCenter() ), self:GetAngles():Up()
	local tr = util.TraceLine( {start=pos,endpos=pos+60*up,filter=self} )
	if tr.Hit and !self.Blocked then
		self.Blocked = true
		ply.SpawnPoint[self:EntIndex()] = nil
	elseif !tr.Hit and self.Blocked then
		self.Blocked = false
		ply.SpawnPoint[self:EntIndex()] = self
	end]]
	
	if CurTime() - self.LastTeamUpdate > 5 then
		self:SetTeam( ply:Team() )
		self.LastTeamUpdate = CurTime()
	end
end
