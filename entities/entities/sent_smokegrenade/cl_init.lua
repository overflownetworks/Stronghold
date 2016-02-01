include( "shared.lua" )

function ENT:Think()
	self:NextThink( 0 )

	if !self.Smoked then
		if CurTime() - self.Created >= self.Duration then
			self.Smoked = true
		end
	else
		local emitter = self.Emitter
		if !emitter then return end
		
		for i, v in ipairs(self.Bubbles) do
			if v != nil and v != NULL then
				if v:GetPos().z >= (self.WaterZPos-4) then
					local smoke = emitter:Add( "particle/particle_smokegrenade", v:GetPos() )
					smoke:SetVelocity( Vector( math.Rand(-50,50), math.Rand(-50,50), math.Rand(0,1) ) )
					smoke:SetGravity( Vector( math.Rand(-10,10), math.Rand(-10,10),math.Rand(0,10) ) )
					smoke:SetDieTime( 2 )
					smoke:SetStartAlpha( math.Rand(100,200) )
					smoke:SetStartSize( 4 )
					smoke:SetEndSize( 100 )
					smoke:SetRoll( math.Rand(-180,180) )
					smoke:SetRollDelta( math.Rand(-0.2,0.2) )
					smoke:SetColor( 200, 200, 200 )
					smoke:SetAirResistance( 100 )
					smoke:SetCollide( true )
					v:SetDieTime( 0.01 )
					table.remove( self.Bubbles, i )
				end
			end
		end

		local waterlevel = self:WaterLevel()
		
		if self.SmokeTimer > CurTime() then return end
		self.SmokeTimer = CurTime() + (waterlevel > 2 and 0.05 or 0.1)

		local vPos = Vector( 1, 1, 0 )
		local R = math.Rand( 0.8, 1 )
		local vOffset = self:LocalToWorld( Vector(0, 0, self:OBBMins().z) )

		emitter:SetPos( vOffset )

		if waterlevel < 3 then
			local smoke = emitter:Add( "effects/dust", vOffset + vPos )
			smoke:SetVelocity(VectorRand() * math.Rand(250,500) )
			smoke:SetGravity( Vector( math.Rand(-100,100), math.Rand(-100,100), math.Rand(0,50) ) )
			smoke:SetDieTime( 5 )
			smoke:SetStartAlpha( 255 )
			smoke:SetStartSize( 1 )
			smoke:SetEndSize( 400 )
			smoke:SetRoll( math.Rand(-180,180) )
			smoke:SetRollDelta( math.Rand(-0.2,0.2) )
			smoke:SetColor( 200, 200, 200 )
			smoke:SetAirResistance( 500 )
			smoke:SetCollide( true )
		else
			if self.WaterZPos == nil then
				local up = util.TraceLine( { start=vOffset, endpos=vOffset+Vector(0,0,16384), mask=MASK_SOLID_BRUSHONLY } )
				local down = util.TraceLine( { start=up.HitPos, endpos=up.HitPos+Vector(0,0,-16384), mask=MASK_WATER } )
				self.WaterZPos = down.HitPos.z
			end
		
			local bubble = emitter:Add( "effects/bubble", vOffset + vPos )
			bubble:SetVelocity( Vector( math.Rand(-30,30), math.Rand(-30,30), math.Rand(50,100) ) )
			bubble:SetGravity( Vector( math.Rand(-20,20), math.Rand(-20,20), math.Rand(50,200) ) )
			bubble:SetDieTime( 100 )
			bubble:SetStartAlpha( 255 )
			bubble:SetStartSize( 2 )
			bubble:SetEndSize( 4 )
			bubble:SetRoll( math.Rand(-5,5) )
			bubble:SetRollDelta( math.Rand(-0.2,0.2) )
			bubble:SetColor( 250, 250, 250 )
			bubble:SetAirResistance( 5 )
			bubble:SetCollide( true )
			table.insert( self.Bubbles, bubble )
		end
		
		self.Emitter:Finish()
	end
	
	return true
end

function ENT:Draw()
	self:DrawModel()
end
