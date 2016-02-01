AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

function ENT:Think()
	if CurTime()-self.Created > 10 then
		self:Remove()
	end
end
