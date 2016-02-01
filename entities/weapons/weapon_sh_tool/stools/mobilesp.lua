resource.AddFile( "materials/toolicons/spawnpoint.vmt" )
resource.AddFile( "materials/toolicons/spawnpoint.vtf" )

TOOL.Category		= "Fight To Survive"
TOOL.Name			= "Spawn Point"
TOOL.Command		= nil
TOOL.ConfigName		= ""

if CLIENT then TOOL.SelectIcon = surface.GetTextureID( "toolicons/spawnpoint" ) end
TOOL.NoAuthOnPlayer = true
TOOL.RequiresTraceHit = true
TOOL.TraceDistance = 100

if CLIENT then
	language.Add( "Tool_mobilesp_name", "Mobile Spawn Point" )
	language.Add( "Tool_mobilesp_desc", "Create Mobile Spawn Points" )
	language.Add( "Tool_mobilesp_0", "Click to create a Spawn Point." )
	language.Add( "Undone_mobile spawn point", "Undone Mobile Spawn point" )
end

function TOOL:LeftClick( trace )
	if !self.Placeable then return false end
	if CLIENT then return true end
	local ply = self:GetOwner()
	local model = "models/props_combine/combine_mine01.mdl"
	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch + 90

	local msp = MakeSpawnPoint( ply, Ang, trace.HitPos, model )
	if IsValid( msp ) then
		msp:SetMaxHealth( 20 )
		msp:SetHealth( 1 )
		undo.Create( "Mobile Spawn Point" )
			undo.AddEntity( msp )
			undo.SetPlayer( ply )
		undo.Finish()
		
		self.SWEP:SetNextPrimaryFire( CurTime() + 1 )
	end
	
	return true
end

function TOOL:RightClick( trace )
	return self:LeftClick( trace )
end

function TOOL:Think()
	local ply = self:GetOwner()
	local pos, ang = ply:GetShootPos(), ply:GetAimVector()
	local tr = util.TraceLine( {start=pos,endpos=pos+100*ang,filter=ply} )
	self.Placeable = tr.Hit and math.abs( tr.HitNormal.z ) > 0.70
	self.PlacePos = tr.HitPos

	local ang = tr.HitNormal:Angle()
	ang.pitch = ang.pitch + 90
	if CLIENT then self:DoGhostEntity( tr.HitPos, ang ) end
end

local ERROR_SOUND = Sound( "buttons/button10.wav" )
if SERVER then
	function MakeSpawnPoint( ply, Ang, Pos, Model )
		if ply:GetCount( "spawnpoints" ) > 4 then ply:SendMessage("Mobile Spawnpoint limit reached.") return end
		
	
		local spawnpoint = ents.Create( "sent_spawnpoint" )
		if !spawnpoint:IsValid() then return end
		spawnpoint:SetModel( Model )

		spawnpoint:SetAngles( Ang )
		spawnpoint:SetPos( Pos )
		spawnpoint:Spawn()
		spawnpoint:SetPlayer( ply )
		spawnpoint.Owner = ply
		if !ply.SpawnPoint then ply.SpawnPoint = {} end
		table.insert( ply.SpawnPoint, spawnpoint )
		
		ply:AddCount( "spawnpoints", spawnpoint )
		
		DoPropSpawnedEffect( spawnpoint )

		gamemode.Call( "PlayerSpawnedSENT", ply, spawnpoint )

		return spawnpoint
	end
elseif CLIENT then
	function TOOL:DoGhostEntity( pos, ang )
		if !self.Placeable then ang = Angle( 0, 0, 0 ) end

		if !IsValid( self.GhostEntity ) then
			self.GhostEntity = ents.Create( "prop_physics" )
			self.GhostEntity:SetModel( "models/props_combine/combine_mine01.mdl" )
			self.GhostEntity:SetColor( 255, 0, 0, 200 )
			self.GhostEntity:SetPos( pos )
			self.GhostEntity:SetAngles( ang )
			self.GhostEntity:Spawn()
			self.GhostEntity:SetMoveType( MOVETYPE_NONE )
		end
		
		self.GhostEntity:SetPos( pos )
		self.GhostEntity:SetAngles( ang )
		
		if self.Placeable then
			self.GhostEntity:SetColor( 0, 255, 0, 200 )
		else
			self.GhostEntity:SetColor( 255, 0, 0, 200 )
		end
	end
	
	function TOOL:Holster()
		if IsValid( self.GhostEntity ) then self.GhostEntity:Remove() end
	end
	
	function TOOL:OnRemove()
		if IsValid( self.GhostEntity ) then self.GhostEntity:Remove() end
	end
	
	function TOOL:OwnerChanged()
		if IsValid( self.GhostEntity ) then self.GhostEntity:Remove() end
	end
end