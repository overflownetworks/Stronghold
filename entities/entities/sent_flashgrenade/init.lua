AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

function ENT:Think()
	if !self.Flashed and CurTime() - self.Created >= self.dt.Duration then
		self:Flash()
		timer.Simple( 10,
			function( ent )
				if IsValid( ent ) then 
					ent:Remove()
				end
			end, self )
		self.Flashed = true
	end
end

local FlashSnd = Sound( "Flashbang.Explode" )
local FlashDistance = 750
function ENT:Flash()
	self:EmitSound( FlashSnd )
	
	local effectdata = EffectData( )
	effectdata:SetNormal( Vector(0,0,1) )
	effectdata:SetOrigin( self:GetPos() )
	util.Effect( "flash_smoke", effectdata, true, true )

	local pos = self:LocalToWorld( self:OBBCenter() )
	for _, v in ipairs(player.GetAll()) do
		local epos = v:EyePos()
		local tr = util.TraceLine( {start=epos,endpos=pos,filter=v} )
		local norm = (pos-epos)
		local dist = norm:Length()
		if dist <= FlashDistance and (tr.Entity == self or (tr.HitPos-pos):Length() <= 1) then
			local t = (-dist/FlashDistance+1) * 8
			local ang = math.Rad2Deg( math.acos(norm:DotProduct(v:GetAimVector()) / dist) )
			umsg.Start( "sh_flashed", v )
				umsg.Float( math.Clamp(t*(-ang/181+1),0,8) )
			umsg.End()
			if dist < FlashDistance*0.60 then
				v:SetDSP( 34, false )
			end
		end
	end
	self:SetColor( 0, 0, 0, 255 )
end