function EFFECT:Init(data)
	if CLIENT then
		local vec1, vec2 = LocalPlayer():GetShootPos(), self:GetPos()
		local ang = ( (vec1 +vec1:Angle():Forward()) -vec2 ):Angle()
		local Location = vec1 +(ang:Forward() *-1000)
		local random = math.random( 98, 100 )
		local gunsound = data:GetEntity().DistantSound
		if gunsound then
			sound.Play( "distantsound/"..gunsound, LocalPlayer():GetShootPos(), 100, random, 0.5 )
			if self:GetPos():Distance(LocalPlayer():GetShootPos()) > 1000 then
				sound.Play( "distantsound/"..gunsound, Location, 100, random, 1 )
			end
		end
	end

	if GetConVarNumber( "sh_fx_muzzleeffects" ) == 0 then return end

	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()

	if !IsValid( self.WeaponEnt ) then return end

	self.Position = self:GetTracerShootPos(data:GetOrigin(), self.WeaponEnt, self.Attachment)
	self.Forward = data:GetNormal()
	self.Angle = self.Forward:Angle()
	self.Right = self.Angle:Right()
	self.Up = self.Angle:Up()
	
	local emitter = ParticleEmitter(self.Position)
	
	if self.WeaponEnt:IsWeapon() then
		if self.WeaponEnt:GetOwner():KeyDown(IN_ATTACK2) then return end
		local AddVel = self.WeaponEnt:GetOwner():GetVelocity()
	
		for i = 1,2 do
			local particle = emitter:Add( "particle/particle_smokegrenade", self.Position )

			particle:SetVelocity( 50 * i * self.Forward + 8 * VectorRand() )
			particle:SetAirResistance( 400 )
			particle:SetGravity( Vector(0, 0, math.random(10, -10) ) )
			particle:SetDieTime( math.random( 0.2, 0.5 ) )
			particle:SetStartAlpha( math.random( 50, 140 ) )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( math.random( 0, 0 ) )
			particle:SetEndSize( math.random( 5, 9 ) )
			particle:SetRoll( math.random( -25, 25 ) )
			particle:SetRollDelta( math.random( -0.05, 0.05 ) )
			particle:SetColor( 150, 150, 150 )
			particle:SetLighting(1)
			particle:SetCollide(true)
		end
		
		for i = 1,2 do 
			local particle = emitter:Add( "effects/muzzleflash"..math.random( 1, 4 ), self.Position + 1 * self.Forward )

			particle:SetVelocity( 100 * self.Forward + 1.1 * AddVel )
			particle:SetAirResistance( 160 )
			particle:SetDieTime( 0.05 )
			particle:SetStartAlpha( 150 )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( 2 )
			particle:SetEndSize( 4 )
			particle:SetRoll( math.random( 180, 480 ) )
			particle:SetRollDelta( math.random( -1, 1) )
			particle:SetColor( 255, 255, 255 )	
		end
	end
	
	if self.WeaponEnt:IsWeapon() then return end
	
	local AddVel2 = LocalPlayer():GetVelocity()
	for i = 1,2 do
		local particle = emitter:Add( "particle/particle_smokegrenade", self.Position + 25 * self.Forward - 1.8 * self.Up)

		particle:SetVelocity( 50 * i * self.Forward + 8 * VectorRand() )
		particle:SetAirResistance( 400 )
		particle:SetGravity( Vector(0, 0, math.random(10, -10) ) )
		particle:SetDieTime( math.random( 0.2, 0.5 ) )
		particle:SetStartAlpha( math.random( 50, 140 ) )
		particle:SetEndAlpha( 0 )
		particle:SetStartSize( math.random( 0, 0 ) )
		particle:SetEndSize( math.random( 5, 9 ) )
		particle:SetRoll( math.random( -25, 25 ) )
		particle:SetRollDelta( math.random( -0.05, 0.05 ) )
		particle:SetColor( 150, 150, 150 )
		particle:SetLighting(1)
		particle:SetCollide(true)
	end
	
	for i = 1,2 do 
		local particle = emitter:Add( "effects/muzzleflash"..math.random( 1, 4 ), self.Position + 25 * self.Forward - 1.8 * self.Up)

		particle:SetVelocity( 100 * self.Forward + 1.1 * AddVel2 )
		particle:SetAirResistance( 160 )
		particle:SetDieTime( 0.05 )
		particle:SetStartAlpha( 150 )
		particle:SetEndAlpha( 0 )
		particle:SetStartSize( 2  )
		particle:SetEndSize( 4 )
		particle:SetRoll( math.random( 180, 480 ) )
		particle:SetRollDelta( math.random( -1, 1) )
		particle:SetColor( 255, 255, 255 )	
	end

	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end