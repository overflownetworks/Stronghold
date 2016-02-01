--[[-------------------------------------------------------

Fight to Survive: Stronghold by RoaringCow, TehBigA is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.

This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 
444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

---------------------------------------------------------]]
function GM:HatEffectsThink()
	for _, ply in ipairs(player.GetAll()) do
		if IsValid( ply.Hat ) then
			local ragdoll = ply:GetRagdollEntity()
			local parent = ply.Hat:GetParent()
			if ply:Alive() then
				if parent != ply then ply.Hat:SetParent( ply ) parent = ply end
			else
				if parent == ply then ply.Hat:SetParent( ragdoll ) parent = ragdoll end
			end
			
			local hatpos, hatang = ply:GetHatPos(), ply:GetHatAng()
			
			if IsValid( parent ) then
				local index = parent:LookupBone( "ValveBiped.Bip01_Head1" )
				local pos, ang = parent:GetBonePosition( index )
				local forward, right, up = ang:Forward(), ang:Right(), ang:Up()
				
				ang:RotateAroundAxis( right, -90 )
				ang:RotateAroundAxis( forward, 90 )
				ang:RotateAroundAxis( forward, hatang.y )
				ang:RotateAroundAxis( right, hatang.r )
				ang:RotateAroundAxis( up, hatang.p )
				
				ply.Hat:SetPos( pos + hatpos.x*right + hatpos.y*up + hatpos.z*forward )
				ply.Hat:SetAngles( ang )
			end
			
			if (ply == LocalPlayer() and ply:Alive()) or IsValid( LocalPlayer():GetObserverTarget() or nil ) then
				ply.Hat:SetNoDraw( true )
			else
				ply.Hat:SetNoDraw( false )
			end
		end
	end
end

local function RecieveHat( um )
	local ply = um:ReadEntity()
	if !IsValid( ply ) then return end
	local enable = um:ReadBool()
	
	if enable then
		local hat = um:ReadString()
		local tbl = GAMEMODE.ValidHats[hat]
		
		if !tbl then
			if IsValid( ply.Hat ) then ply.Hat:Remove() end
			ply.Hat = nil
			ply.HatID = nil
			return
		end
		
		ply.HatID = hat
	
		if !IsValid( ply.Hat ) then
			ply.Hat = ents.Create( "prop_physics" )
			ply.Hat:SetModel( tbl.model )
			ply.Hat:Spawn()
			if ply == LocalPlayer() then
				ply.Hat:SetNoDraw( true )
			end
		elseif ply.Hat:GetModel() != tbl.model then
			ply.Hat:SetModel( tbl.model )
		end
		
		ply:SetHatPos( tbl.pos )
		ply:SetHatAng( tbl.ang )
	else
		if IsValid( ply.Hat ) then ply.Hat:Remove() end
		ply.Hat = nil
		ply.HatID = nil
	end
end
usermessage.Hook( "sh_hat", RecieveHat )