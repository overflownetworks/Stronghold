--[[-------------------------------------------------------

Fight to Survive: Stronghold by RoaringCow, TehBigA is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.

This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons,
444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

---------------------------------------------------------]]
local grenades = {
	["weapon_sh_c4"]		= true,
	["weapon_sh_smoke"] 	= true,
	["weapon_sh_grenade"] 	= true,
	["weapon_sh_flash"] 	= true
}

-- ----------------------------------------------------------------------------------------------------

local meta = FindMetaTable( "Player" )

INITSTATE_ASKING, INITSTATE_WAITING, INITSTATE_OK = 0, 1, 2
AccessorFuncNW( meta, "m_iInitialized", "Initialized", INITSTATE_ASKING, FORCE_NUMBER )

AccessorFunc( meta, "m_iNextHealthRegen", "NextHealthRegen", 0, FORCE_NUMBER )
AccessorFunc( meta, "m_iLastKill", "LastKill", 0, FORCE_NUMBER )

AccessorFuncNW( meta, "m_fLastSpawn", "LastSpawn", 0, FORCE_NUMBER )
AccessorFuncNW( meta, "m_strMapVote", "MapVote", "" )

AccessorFunc( meta, "m_vHatPos", "HatPos", Vector(0,0,0) )
AccessorFunc( meta, "m_aHatAng", "HatAng", Angle(0,0,0) )

-- To add clientside smoothing
if CLIENT then
	function meta:SetViewOffset( pos )
		self.m_vViewOffset = pos
	end

	function meta:SetViewOffsetDucked( pos )
		self.m_vViewOffsetDucked = pos
	end
end

function meta:CreateServerSideRagdoll()
	local ragdoll = ents.Create( "prop_ragdoll" )
	ragdoll:SetModel( self:GetModel() )
	ragdoll:SetPos( self:GetPos() )
	ragdoll:SetAngles( self:GetAngles() )
	ragdoll:Spawn()
	ragdoll:Activate()

	ragdoll:SetCollisionGroup( COLLISION_GROUP_WEAPON )

	local vel = self:GetVelocity()
	for index=0, ragdoll:GetPhysicsObjectCount() do
		local pos, ang = self:GetBonePosition( ragdoll:TranslatePhysBoneToBone(index) )
		local rd_physobj = ragdoll:GetPhysicsObjectNum( index )
		if IsValid( rd_physobj ) then
			rd_physobj:SetPos( pos )
			rd_physobj:SetAngles( ang )
			rd_physobj:SetVelocity( vel * (rd_physobj:GetMass()/85) * 2 )
		end
	end

	table.insert( GAMEMODE.Ragdolls, {ent=ragdoll,time=CurTime()} )
end

function meta:SaveData()
	if self:GetInitialized() != INITSTATE_OK then return end
	local steamid = self:SteamID()

	local data = { steamid = steamid }
	data.Statistics = self.Statistics
	data.Loadouts = self.Loadouts

	data.Items = table.Copy( self.Items )
	for k, v in pairs(data.Items) do
		local ammo = k
		if grenades[k] and self:GetWeapon( k ) ~= NULL then
			ammo = "grenade"
		end
		local additional = self:GetAmmoCount( ammo )  -- If the player is alive - get the held ammo then save
		data.Items[k].count = data.Items[k].count + additional
	end

	if data.Items == nil then data.Items = {} end
	data.Items["money"] = { type=0, count=self.Money }

	data.Licenses = self.Licenses

	local encoded = glon.encode( data )
	file.Write( "Stronghold/PlayerInfo/"..string.gsub(steamid,":","_")..".txt", encoded )
end

function meta:FailedInitialize()
	if !IsValid( self ) then return end
	if self:GetInitialized() == INITSTATE_OK then return end

	self:SendLua( [[surface.CreateFont( "IF", font = "coolvetica", size = 48, weight = 700, antialias = true, additive = false})]] )
	self:SendLua( [[function __IF1()
		surface.SetFont( "IF" )
		local sw, sh = ScrW(), ScrH()
		local x, y, w, h = 0, math.floor(sh*0.50-34), sw, 68
		__IF2( sw, sh, x, y, w, h )
	end]] )
	self:SendLua( [[function __IF2( sw, sh, x, y, w, h )
		surface.SetDrawColor( 0, 0, 0, 220 )
		surface.DrawRect( 0, 0, sw, sh )
		surface.DrawRect( x, y, w, h )
		__IF3( sw, sh, x, y, w, h )
	end]] )
	self:SendLua( [[function __IF3( sw, sh, x, y, w, h )
		surface.SetDrawColor( 200, 0, 0, 120 )
		surface.DrawRect( x, y+1, w, 1 )
		surface.DrawRect( x, y+h-2, w, 1 )
		surface.SetTextColor( 200, 50, 50, 255 )
		__IF4( sw, sh, x, y, w, h )
	end]] )
	self:SendLua( [[function __IF4( sw, sh, x, y, w, h )
		local tw, _ = surface.GetTextSize( "Information transfer failure, reconnect!" )
		surface.SetTextPos( sw*0.50-tw*0.50, y+15 )
		surface.DrawText( "Information transfer failure, reconnect!" )
	end]] )
	self:SendLua( [[GAMEMODE.HUDPaint = __IF1]] )
end

function meta:IsBot()
	for _, v in ipairs(player.GetBots()) do
		if v == self then return true end
	end
	return false
end

--[[function meta:IsDonator()
	if self:IsAdmin() or self:IsUserGroup( "moderator" ) or self:IsUserGroup( "gold" ) or self:IsUserGroup( "platinum" ) then
		return true
	else
		return false
	end
end

function meta:IsGold()
	if self:IsUserGroup( "gold" ) or self:IsUserGroup( "moderator" ) then
		return true
	else
		return false
	end
end

function meta:IsPlatinum()
	if self:IsUserGroup( "platinum" ) or self:IsAdmin() then
		return true
	else
		return false
	end
end]]

function meta:Heal( amt )
	if amt + self:Health() <= self:GetMaxHealth() then
		self:SetHealth(self:Health() + amt)
	else
		self:SetHealth(self:GetMaxHealth())
	end
end

function meta:AddArmor( amt )
	if amt + self:Armor() <= 100 then
		self:SetArmor(self:Armor() + amt)
	else
		self:SetArmor(100)
	end
end

function meta:SendMessage( msg, title, msgsnd )
	msg = sql.SQLStr( msg, true )
	title = sql.SQLStr( title or "Stronghold", true )
	if SERVER then
		self:SendLua( [[chat.AddText(Color(200,200,200,255),"]]..title..[[: ",Color(200,50,50,255),"]]..msg..[[")]] )
		if msgsnd == true then
			self:SendLua( [[surface.PlaySound("buttons/button15.wav")]] )
		elseif msgsnd == false then
			self:SendLua( [[surface.PlaySound("buttons/button16.wav")]] )
		end
	else
		chat.AddText( Color(200,200,200,255), title..": ", Color(200,50,50,255), msg )
		if msgsnd == true then
			surface.PlaySound( "buttons/button15.wav" )
		elseif msgsnd == false then
			surface.PlaySound( "buttons/button16.wav" )
		end
	end
end

-- ----------------------------------------------------------------------------------------------------

g_SBoxObjects = {}

function meta:CheckLimit( str )
	if game.SinglePlayer() then return true end

	local c = server_settings.Int( "sbox_max"..str, 0 )
	if c < 0 then return true end
	if self:GetCount( str ) > c-1 then self:LimitHit( str ) return false end

	return true
end

function meta:GetCount( str, minus )
	if CLIENT then
		return self:GetNetworkedInt( "Count."..str, 0 )
	end

	minus = minus or 0

	if !self:IsValid() then return end

	local key = self:UniqueID()
	local tab = g_SBoxObjects[key]

	if !tab || !tab[str] then
		self:SetNetworkedInt( "Count."..str, 0 )
		return 0
	end

	local c = 0
	for k, v in pairs(tab[str]) do
		if v:IsValid() then
			c = c + 1
		else
			tab[str][k] = nil
		end
	end

	self:SetNetworkedInt( "Count."..str, c - minus )
	return c
end

function meta:AddCount( str, ent )
	if SERVER then
		local key = self:UniqueID()
		g_SBoxObjects[ key ] = g_SBoxObjects[ key ] or {}
		g_SBoxObjects[ key ][ str ] = g_SBoxObjects[ key ][ str ] or {}

		local tab = g_SBoxObjects[ key ][ str ]

		if IsValid( ent ) then
			table.insert( tab, ent )
			self:GetCount( str )
			ent:CallOnRemove( "GetCountUpdate", function( ent, ply, str ) ply:GetCount(str, 1) end, self, str )
		end
	end
end

function meta:LimitHit( str )
	self:SendLua( "GAMEMODE:LimitHit( '".. str .."' )" )
end

local tracepositions = { Vector(0,0,0) }
for i=1, 16 do
	table.insert( tracepositions, Vector(math.cos(math.pi/8*i)*17,math.sin(math.pi/8*i)*17,0) )
end
function meta:IsColliding( ent, filter )
	return PlayerHullIsColliding( self:GetPos(), self:Crouching(), ent, {self} )
end

function PlayerHullIsColliding( pos, crouching, ent, filter )
	--filter = table.Add( filter or {}, {GetWorldEntity()} )
	for _, start in ipairs(tracepositions) do
		local adjstart = start + pos
		local trace = util.TraceLine( {
				start=adjstart,
				endpos=adjstart + Vector( 0, 0, (crouching and 37 or 73) ),
				filter=filter
			}
		)
		if trace.Entity == ent then
			return true
		end
	end
	return false
end

-- ----------------------------------------------------------------------------------------------------

-- LIST OF STATISTICS --
GM.StatisticsEventNames = {
	kills = "Kills",
	deaths = "Deaths",
	dmgtaken = "Damage Taken",
	dmginflicted = "Damage Inflicted",
	bulletsfired = "Rounds Fired",
	bulletshit = "Rounds Hit",
	reloads = "Number of times Reloaded",
	ironsights = "Number of times Iron Sighted",
	propsplaced = "Props Placed",
	propsdestroyed = "Props Destroyed",
	longestalive = "Longest time alive",
	gbuxhighestmul = "GBux Highest Multiplier",
	gbuxmoneyearned = "GBux Earned",
	steps = "Number of Steps",
	jumps = "Number of Jumps",
	crouches = "Number of Crouches"
}

-- Kills						- kills
-- Deaths						- deaths
-- Damage taken					- dmgtaken
-- Damage inflicted				- dmginflicted
-- Bullets fired				- bulletsfired - In weapon base
-- Bullets hit					- bulletshit - In weapon base
-- Number of times reloaded 	- reloads - In weapon base
-- Number of times iron sighted	- ironsights - In weapon base
-- Props placed					- propsplaced
-- Props destroyed				- propsdestroyed
-- Longest time alive			- longestalive
-- Highest multiplier			- gbuxhighestmul
-- Money earned					- gbuxmoneyearned
-- Number of steps				- steps
-- Number of jumps				- jumps
-- Number of crouches			- crouches

function meta:AddStatistic( event, amt )
	if CLIENT then return end
	if !self.Statistics then self.Statistics = {} end
	if !self.Statistics[event] then self.Statistics[event] = 0 end
	self.Statistics[event] = self.Statistics[event] + (amt or 1)
end

function meta:SetStatistic( event, amt )
	if CLIENT then return end
	if !self.Statistics then self.Statistics = {} end
	if !self.Statistics[event] then self.Statistics[event] = 0 end
	self.Statistics[event] = amt
end

function meta:GetStatistic( event, default )
	if !self.Statistics then self.Statistics = {} end
	if !self.Statistics[event] then self.Statistics[event] = default end
	return self.Statistics[event]
end

function meta:GetStatistics()
	return self.Statistics or {}
end

if SERVER then
	function meta:SendStatistics( ply )
		if !self.Statistics then self.Statistics = {} end
		net.Start("sh_statistics")
			net.WriteEntity(self)
			net.WriteTable(self.Statistics)
		net.Send(ply)
	end
	concommand.Add( "sh_requeststats",
		function( ply, _, args )
			local other = Entity( tonumber(args[1]) )
			if IsValid( other ) then other:SendStatistics( ply ) end
		end )

	function meta:SaveStatistics()
		if self:GetInitialized() != INITSTATE_OK then return end
		--sqlx.UpdatePlayerData( "sh_statistics", self, self.Statistics )
	end
end

net.Receive("sh_statistics", function( _, ply)
	local ply = net.ReadEntity()
	local statistics = net.ReadTable()
	if IsValid( ply ) then
		ply.Statistics = statistics or {}
		ply.StatisticsUpdated = os.date( "%I:%M:%S %p" )
		if ValidPanel( GAMEMODE.HelpFrame ) and ValidPanel( GAMEMODE.HelpFrame.StatsPanel ) then
			GAMEMODE.HelpFrame.StatsPanel:PlayerSelected( ply )
		end
	end
end)

-- ----------------------------------------------------------------------------------------------------

AccessorFuncNW( meta, "m_strLoadoutPrimary", "LoadoutPrimary", "" )
AccessorFuncNW( meta, "m_strLoadoutSecondary", "LoadoutSecondary", "" )
AccessorFuncNW( meta, "m_strLoadoutExplosive", "LoadoutExplosive", "" )
AccessorFunc( meta, "m_strSpawnedLoadoutPrimary", "SpawnedLoadoutPrimary", "" )
AccessorFunc( meta, "m_strSpawnedLoadoutSecondary", "SpawnedLoadoutSecondary", "" )
AccessorFunc( meta, "m_strSpawnedLoadoutExplosive", "SpawnedLoadoutExplosive", "" )

function meta:SetLoadout( name )
	if !self.Loadouts then self.Loadouts = {} end

	if self.Loadouts[name] then
		self.m_strLoadoutPrimary = self.Loadouts[name].primary
		self.m_strLoadoutSecondary = self.Loadouts[name].secondary
		self.m_strLoadoutExplosive = self.Loadouts[name].explosive
	end
end

function meta:EditLoadout( name, primary, secondary, explosive )
	if !self.Loadouts then self.Loadouts = {} end

	if !GAMEMODE.PrimaryWeapons[primary] or !GAMEMODE.SecondaryWeapons[secondary] or !GAMEMODE.Explosives[explosive] then return end
	self.Loadouts[name] = { primary=primary, secondary=secondary, explosive=explosive }
end

function meta:GetLoadout( name )
	if !self.Loadouts then self.Loadouts = {} end
	return self.Loadouts[name]
end

function meta:GetLoadouts()
	if !self.Loadouts then self.Loadouts = {} end
	return self.Loadouts
end

function meta:RemoveLoadout( name )
	if !self.Loadouts then self.Loadouts = {} end

	self.Loadouts[name] = nil
	--if SERVER then sqlx.DeletePlayerData( "sh_loadouts", self, {name={"=",name}} ) end
end

function meta:SaveLoadouts()
	if self:GetInitialized() != INITSTATE_OK then return end
	if !self.Loadouts then self.Loadouts = {} end

	--[[sql.Begin()
	for k, v in pairs(self.Loadouts) do
		sqlx.DeletePlayerData( "sh_loadouts", self, {name={"=",k}} )
		sqlx.CreatePlayerData( "sh_loadouts", self, {name=k,primarywep=v.primary,secondarywep=v.secondary,explosivewep=v.explosive} )
	end
	sql.Commit()]]
end


-- ----------------------------------------------------------------------------------------------------

function meta:GetLicenses( type )
	if !self.Licenses then self.Licenses = { [1]={weapon_sh_mp5a4=-1}, [2]={weapon_sh_p228=-1} } end
	return type == nil and self.Licenses or self.Licenses[type]
end

function meta:GetLicense( type, class )
	if !self.Licenses then self.Licenses = { [1]={weapon_sh_mp5a4=-1}, [2]={weapon_sh_p228=-1} } end
	return self.Licenses[type] and self.Licenses[type][class] or nil
end

function meta:SetLicenseTime( type, class, time )
	if !self.Licenses then self.Licenses = { [1]={weapon_sh_mp5a4=-1}, [2]={weapon_sh_p228=-1} } end

	if type == 1 or type == 2 or type == 5 then
		if !self.Licenses[type] then self.Licenses[type] = {} end
		self.Licenses[type][class] = time

		self:SaveLicenses()
	end
end

function meta:GetLicenseTimeLeft( type, class )
	if !self.Licenses then self.Licenses = { [1]={weapon_sh_mp5a4=-1}, [2]={weapon_sh_p228=-1} } end

	if type == 1 or type == 2 or type == 5 then
		local ostime = os.time()
		if !self.Licenses[type] then self.Licenses[type] = {} end
		if self.Licenses[type][class] == -1 then
			return -1
		else
			return math.max( 0, (self.Licenses[type][class] or 0)-ostime )
		end
	end

	return 0
end

function meta:AddLicenseTime( type, class, time )
	if !self.Licenses then self.Licenses = { [1]={weapon_sh_mp5a4=-1}, [2]={weapon_sh_p228=-1} } end

	if type == 1 or type == 2 or type == 5 then
		if !self.Licenses[type] then self.Licenses[type] = {} end
		self.Licenses[type][class] = (self.Licenses[type][class] or os.time()) + time

		self:SaveLicenses()
	end
end

function meta:RemoveLicense( type, class )
	if !self.Licenses then self.Licenses = { [1]={weapon_sh_mp5a4=-1}, [2]={weapon_sh_p228=-1} } end

	if type == 1 or type == 2 or type == 5 then
		if !self.Licenses[type] then self.Licenses[type] = {} end
		self.Licenses[type][class] = nil

		self:SaveLicenses()
	end
end

function meta:SaveLicenses()
	if self:GetInitialized() != INITSTATE_OK then return end
	if !self.Licenses then self.Licenses = { [1]={weapon_sh_mp5a4=-1}, [2]={weapon_sh_p228=-1} } end

	--[[sql.Begin()
	for k, v in pairs(self.Licenses[1] or {}) do
		if !table.HasValue( DoNotSaveLicenses, k ) then
			sqlx.DeletePlayerData( "sh_licenses", self, {license={"=",k}} )
			sqlx.CreatePlayerData( "sh_licenses", self, {type=1,license=k,epoch_end=v} )
		end
	end
	for k, v in pairs(self.Licenses[2] or {}) do
		if !table.HasValue( DoNotSaveLicenses, k ) then
			sqlx.DeletePlayerData( "sh_licenses", self, {license={"=",k}} )
			sqlx.CreatePlayerData( "sh_licenses", self, {type=2,license=k,epoch_end=v} )
		end
	end
	for k, v in pairs(self.Licenses[5] or {}) do
		if !table.HasValue( DoNotSaveLicenses, k ) then
			sqlx.DeletePlayerData( "sh_licenses", self, {license={"=",k}} )
			sqlx.CreatePlayerData( "sh_licenses", self, {type=5,license=k,epoch_end=v} )
		end
	end
	sql.Commit()]]
end

-- ----------------------------------------------------------------------------------------------------

function meta:GetMoney()
	if !self.Money then self.Money = 0 end
	return self.Money
end

function meta:AddMoney( amt )
	if !self.Money then self.Money = 0 end
	self.Money = self.Money + amt
end

function meta:SetMoney( amt )
	self.Money = type(amt) == "number" and amt or tonumber(amt)
	if SERVER then self:SaveMoney() end
end

function meta:SaveMoney()
	if self:GetInitialized() != INITSTATE_OK then return end
	if !self.Money then self.Money = 0 end
	--sqlx.UpdatePlayerData( "sh_inventory", self, {count=self.Money}, {item={"=","money"}} )
end

function meta:GetMultiplier()
	if !self.Multiplier then self.Multiplier = 0 end
	return self.Multiplier
end

function meta:AddMultiplier( amt )
	if !self.Multiplier then self.Multiplier = 0 end
	self.Multiplier = math.max( 0, self.Multiplier + amt )
end

function meta:SetMultiplier( amt )
	self.Multiplier = amt
end

function meta:SendMoneyAndMultiplier()
	umsg.Start( "sh_moneyandmultiplier", self )
		umsg.Float( self.Money or 0 )
		umsg.Float( self.Multiplier or 0 )
	umsg.End()
end

local function ReceiveMoneyAndMultiplier( um )
	local ply = LocalPlayer()
	if IsValid( ply ) then
		ply:SetMoney( um:ReadFloat() )
		ply:SetMultiplier( um:ReadFloat() )
	end
end
usermessage.Hook( "sh_moneyandmultiplier", ReceiveMoneyAndMultiplier )

-- ----------------------------------------------------------------------------------------------------

function meta:GetItems()
	if !self.Items then self.Items = {} end
	return self.Items
end

function meta:GetItem( item )
	if !self.Items then self.Items = {} end
	return self.Items[item]
end

function meta:GetItemCount( item )
	if !self.Items then self.Items = {} end
	return self.Items[item] and self.Items[item].count or 0
end

-- If type is nil, the method will try and figure it out, otherwise 0
function meta:SetItem( type, item, count )
	if !self.Items then self.Items = {} end
	count = math.max( 0, count )

	if !self.Items[item] then
		if type == nil then
			type = 0
			if GAMEMODE.Explosives[item] then
				type = 3
			elseif GAMEMODE.Ammo[item] then
				type = 4
			end
		end
		self.Items[item] = { type=type, count=count }
	else
		self.Items[item].count = count
	end
	SH_SendClientItem( self, item )
end

-- If the item doesn't exist, or if type is nil, the method will try and figure out the type, otherwise 0
function meta:AddItem( item, count, type )
	if !self.Items then self.Items = {} end
	--ErrorNoHalt( "AddItem - "..item.." "..count.." "..tostring(type).."\n" )
	if !self.Items[item] then
		if type == nil then
			type = 0
			if GAMEMODE.Explosives[item] then
				type = 3
			elseif GAMEMODE.Ammo[item] then
				type = 4
			end
		end
		self.Items[item] = { type=type, count=math.max( 0, count ) }
	else
		self.Items[item].count = math.max( 0, self.Items[item].count + count )
	end
	SH_SendClientItem( self, item )
end

function meta:BuyItem( type, class, amount )
	if !IsValid( self ) or GAMEMODE.GameOver then return end

	if type == 1 and GAMEMODE.PrimaryWeapons[class] then

		--ErrorNoHalt( "Giving primary...\n" )
		local cost = (amount == 2 and GAMEMODE.PrimaryWeapons[class].price or GAMEMODE.PrimaryWeapons[class].price*0.10)
		if cost > 0 and self:GetMoney() >= cost then
			--ErrorNoHalt( "Primary given\n" )
			if amount == 2 then
				self:SetLicenseTime( 1, class, -1 )
			else
				self:AddLicenseTime( 1, class, 3600 )
			end
			SH_SendClientLicense( self, type, class )
			self:AddMoney( -cost )
		end

	elseif type == 2 and GAMEMODE.SecondaryWeapons[class] then

		--ErrorNoHalt( "Giving secondary...\n" )
		local cost = (amount == 2 and GAMEMODE.SecondaryWeapons[class].price or GAMEMODE.SecondaryWeapons[class].price*0.10)
		if cost > 0 and self:GetMoney() >= cost then
			if amount == 2 then
				self:SetLicenseTime( 2, class, -1 )
			else
				self:AddLicenseTime( 2, class, 3600 )
			end
			SH_SendClientLicense( self, type, class )
			self:AddMoney( -cost )
		end

	elseif type == 3 and GAMEMODE.Explosives[class] then

		--ErrorNoHalt( "Giving explosives...\n" )
		local cost = GAMEMODE.Explosives[class].price * amount
		if cost > 0 and self:GetMoney() >= cost then
			self:AddItem( class, amount, 3 )
			self:AddMoney( -cost )
			SH_SendClientItem( self, class )
		end

	elseif type == 4 and GAMEMODE.Ammo[class] then

		--ErrorNoHalt( "Giving ammo...\n" )
		local cost = GAMEMODE.Ammo[class].price * amount
		if cost > 0 and self:GetMoney() >= cost then
			self:AddItem( class, amount, 4 )
			self:AddMoney( -cost )
			SH_SendClientItem( self, class )
		end

	elseif type == 5 and GAMEMODE.Hats[class] then

		--ErrorNoHalt( "Giving hat...\n" )
		local cost = GAMEMODE.Hats[class].price
		if cost > 0 and self:GetMoney() >= cost then
			self:AddLicenseTime( 5, class, 86400 )
			SH_SendClientLicense( self, type, class )
			self:AddMoney( -cost )
		end

	end

	self:SendMoneyAndMultiplier()
end

function meta:SaveItems()
	if self:GetInitialized() != INITSTATE_OK then return end
	if !self.Items then self.Items = {} end
	local alive = true -- self:Alive()

	--[[sql.Begin()
	for k, v in pairs(self.Items) do
		local ammo = k

		if grenades[k] and self:GetWeapon( k ) ~= NULL then
			ammo = "grenade"

			print( "adding grenade: ".. k )
		end

		local additional = alive and self:GetAmmoCount( ammo ) or 0 -- If the player is alive - get the held ammo then save
		sqlx.DeletePlayerData( "sh_inventory", self, {item={"=",k}} )
		sqlx.CreatePlayerData( "sh_inventory", self, {type=v.type,item=k,count=v.count+additional} )
	end
	sql.Commit()]]
end

-- ----------------------------------------------------------------------------------------------------

function meta:EnableHat( name )
	local rf = RecipientFilter()
	rf:AddAllPlayers()

	umsg.Start( "sh_hat", rf )
		umsg.Entity( self )
		if !name or name == "" then
			umsg.Bool( false )
		else
			umsg.Bool( true )
			umsg.String( name )
		end
	umsg.End()
end

-- ----------------------------------------------------------------------------------------------------

function meta:CheckSpawnpoints( nosetpos, tried, tries )
	local tries = tries or 0
	local tried = {}
	if tries > self:GetCount("spawnpoints") and self:GetCount("spawnpoints") !=0 then
		self:SendMessage( "Mobile spawn area obstructed!", "Spawnpoint", false )
		return
	end

	if self.SpawnPoint and table.Count( self.SpawnPoint ) > 0 then
		local ent = table.Random( self.SpawnPoint )
		if (!IsValid( ent ) and IsValid( self )) or table.HasValue( tried, ent ) then
			for k, v in pairs(self.SpawnPoint) do if v == ent then self.SpawnPoint[k] = nil end end
			tries = tries + 1
			self:CheckSpawnpoints( nosetpos, tried, tries )
			return
		end

		local spawnpos
		local pos, up = ent:GetPos()--[[ent:LocalToWorld( ent:OBBCenter() )]], ent:GetAngles():Up()
		if up.z < -0.70 then
			local zscale = (up.z+1) * 3
			spawnpos = (ent:GetPos() + (3+(20*zscale)) * up) - Vector( 0, 0, 72 )
		else
			local zscale = (-up.z+1) * 3
			spawnpos = ent:GetPos() + (3+(20*zscale)) * up
		end

		local filter = ents.FindByClass( "sent_spawnpoint" )
		table.Add( filter, ents.FindByClass("prop_ragdoll") )

		for _, start in ipairs(tracepositions) do
			local adjstart = start + spawnpos
			local trace = util.TraceLine( {
					start=adjstart,
					endpos=adjstart + Vector( 0, 0, (self:Crouching() and 37 or 73) ),
					filter=filter
				}
			)
			if IsValid(trace.Entity) and trace.Entity:GetClass() == "prop_physics" then
				trace.Entity:TakeDamage(5)
			end
		end
		for _, start in ipairs(tracepositions) do
			local adjstart = start + spawnpos
			local trace = util.TraceLine( {
					start=adjstart,
					endpos=adjstart + Vector( 0, 0, (self:Crouching() and 37 or 73) ),
					filter=filter
				}
			)

			if trace.Fraction < 0.95 then
				table.insert( tried, ent )
				tries = tries + 1
				self:CheckSpawnpoints( nosetpos, tried, tries )
				--self.Entity:TakeDamage(20)
				return
			end
		end

		if !nosetpos then self:SetPos( spawnpos ) end
	elseif !self.SpawnPoint then
		self.SpawnPoint = {}
	end
end

if CLIENT then
	net.Receive("sh_loadouts", function()
		local ply = LocalPlayer()
		ply.Loadouts = net.ReadTable()
		GAMEMODE.LoadoutFrame:RefreshLoadouts()
	end)


	net.Receive("sh_loadout", function()
		local ply = LocalPlayer()
		local loadout = net.ReadTable()
		ply.Loadouts = ply.Loadouts or {}
		table.Merge( ply.Loadouts[k], loadout )
		--[[for k, v in pairs(decoded) do
			ply.Loadouts[k] = v
		end]]
		GAMEMODE.LoadoutFrame:RefreshLoadouts()
	end)


	net.Receive("sh_licenses", function()
		local ply = LocalPlayer()
		ply.Licenses = nil
		ply.Licenses = net.ReadTable()
		GAMEMODE.LoadoutFrame:RefreshLicenses()
		GAMEMODE.LoadoutFrame:RefreshHats()
	end)

	net.Receive("sh_license", function()
		local ply = LocalPlayer()
		local license = net.ReadTable()
		ply.Licenses = ply.Licenses or { [1]={}, [2]={} }
		table.Merge( ply.Licenses, license )
		GAMEMODE.LoadoutFrame:RefreshLicenses()
		GAMEMODE.LoadoutFrame:RefreshHats()
	end)

	net.Receive("sh_items", function()
		local ply = LocalPlayer()
		ply.Items = nil
		ply.Items = net.ReadTable()
		GAMEMODE.LoadoutFrame:RefreshLicenses()
	end)

	net.Receive("sh_item", function()
		local ply = LocalPlayer()
		local item = net.ReadTable()
		ply.Items = ply.Items or {}
		table.Merge( ply.Items, item )
		GAMEMODE.LoadoutFrame:RefreshLicenses()
	end)
end
