function EFFECT:Init(data)

if GetConVarNumber( "sh_fx_muzzleeffectsoff" ) == 1 then
return end
	
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
	local AddVel = self.WeaponEnt:GetOwner():GetVelocity()
	if self.WeaponEnt:GetOwner():KeyDown(IN_ATTACK2) then return end		
		for i = 1,2 do
			local particle = emitter:Add( "effects/dust2", self.Position )

				particle:SetVelocity( 50 * i * self.Forward + 8 * VectorRand() + AddVel )
				particle:SetAirResistance( 400 )
				particle:SetGravity( Vector(0, 0, math.Rand(-10, 10) ) )
				particle:SetDieTime( math.Rand( 0.5, 1.0 ) )
				particle:SetStartAlpha( math.Rand( 10, 50 ) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( math.Rand( 1, 4.5 ) )
				particle:SetEndSize( math.Rand( 6, 7.5 ) )
				particle:SetRoll( math.Rand( -25, 25 ) )
				particle:SetRollDelta( math.Rand( -0.05, 0.05 ) )
				particle:SetLighting(1)
				particle:SetColor( 255, 255, 255 )
		end
	end
	
	if self.WeaponEnt:IsWeapon() then return end
	local AddVel2 = LocalPlayer():GetVelocity()
		for i = 1,2 do
			local particle = emitter:Add( "effects/dust2", self.Position + 25 * self.Forward - 2 * self.Up)

				particle:SetVelocity( 50 * i * self.Forward + 8 * VectorRand() + AddVel2 )
				particle:SetAirResistance( 400 )
				particle:SetGravity( Vector(0, 0, math.Rand(-10, 10) ) )
				particle:SetDieTime( math.Rand( 0.5, 1.0 ) )
				particle:SetStartAlpha( math.Rand( 10, 50 ) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( math.Rand( 1, 4.5 ) )
				particle:SetEndSize( math.Rand( 6, 7.5 ) )
				particle:SetRoll( math.Rand( -25, 25 ) )
				particle:SetRollDelta( math.Rand( -0.05, 0.05 ) )
				particle:SetLighting(1)
				particle:SetColor( 255, 255, 255 )
		end
	emitter:Finish()
end


function EFFECT:Think()

	return false
end


function EFFECT:Render()
end