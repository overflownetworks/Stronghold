--[[-------------------------------------------------------

Fight to Survive: Stronghold by RoaringCow, TehBigA is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.

This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or send a letter to Creative Commons, 
444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

---------------------------------------------------------]]
local SND_PRIMARY = Sound( "weapons/mp5Navy/mp5_slideback.wav" )
local SND_SECONDARY = Sound( "weapons/elite/elite_sliderelease.wav" )
local SND_EXPLOSIVE = Sound( "weapons/pinpull.wav" )
local SND_CONFIRM = Sound( "buttons/button9.wav" )
local SND_FAIL = Sound( "buttons/button11.wav" )

local PANEL = {}

AccessorFunc( PANEL, "m_iFOV", "FOV", FORCE_NUMBER )

function PANEL:Init()
	self.m_angOffset = Angle( 0, 0, 0 )
	self.m_bMouseHeld = false
end

function PANEL:Setup( model, title, fov, offset )
	self.m_strTitle = title
	self.m_iFOV = fov or self.m_iFOV

	if IsValid( self.m_Entity ) then
		self.m_Entity:Remove()
		self.m_Entity = nil
	end
	
	self.m_Entity = ClientsideModel( model, RENDER_GROUP_OPAQUE_ENTITY )
	self.m_Entity:SetNoDraw( true )
	
	local min, max = self.m_Entity:GetRenderBounds()
	local center = (min+max) * -0.50
	self.m_Entity:SetPos( center + (offset or Vector(0,0,0)) )
	self.m_Entity:SetAngles( Angle(0,35,0) )
end

function PANEL:OnMousePressed()
	self:MouseCapture( true )
	self.m_iMouseX, self.m_iMouseY = self:CursorPos()
	self.m_bMouseHeld = true
end

function PANEL:OnMouseReleased()
	self:MouseCapture( false )
	self.m_bMouseHeld = false
end

function PANEL:OnCursorMoved( x, y )
	if self.m_bMouseHeld then
		self.m_angOffset.p = math.Clamp( self.m_angOffset.p + (self.m_iMouseY - y) * 0.50, -60, 80 )
		--while self.m_angOffset.p > 180 do self.m_angOffset.p = self.m_angOffset.p - 360 end
		--while self.m_angOffset.p < -180 do self.m_angOffset.p = self.m_angOffset.p + 360 end
		self.m_angOffset.y = self.m_angOffset.y + (self.m_iMouseX - x) * 0.50
		while self.m_angOffset.y > 180 do self.m_angOffset.y = self.m_angOffset.y - 360 end
		while self.m_angOffset.y < -180 do self.m_angOffset.y = self.m_angOffset.y + 360 end
	end
	self.m_iMouseX, self.m_iMouseY = x, y
end

function PANEL:Paint()
	local x, y = self:LocalToScreen( 0, 0 )
	local w, h = self:GetWide(), self:GetTall()
	local skin = self:GetSkin()
	
	skin:DrawGenericBackground( 0, 0, w, h, skin.bg_color )
	
	surface.SetFont( "Trebuchet19" )
	local tw, _ = surface.GetTextSize( self.m_strTitle or "" )
	draw.SimpleTextOutlined( self.m_strTitle or "", "Trebuchet19", math.floor(w*0.50-tw*0.50), 10, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color(0,0,0,255) )
	
	if !IsValid( self.m_Entity ) then return end
	
	local ang = Vector( 0.9285, 0.0000, 0.3714 ):Angle()
	ang = ang + self.m_angOffset
	
	cam.Start3D( ang:Forward()*26, (ang:Forward()*-1):Angle(), self.m_iFOV or 90, x+2, y+2, w-4, h-4 )
	cam.IgnoreZ( true )
		render.SuppressEngineLighting( true )
		
		render.SetLightingOrigin( self.m_Entity:GetPos() )
		render.ResetModelLighting( 1, 1, 1 )
		render.SetColorModulation( 1, 1, 1 )
		
		self.m_Entity:DrawModel()
		
		render.SuppressEngineLighting( false )
	cam.IgnoreZ( false )
	cam.End3D()
	
	if !self.m_bMouseHeld then
		self.m_angOffset.p = math.ApproachAngle( self.m_angOffset.p, 0, self.m_angOffset.p*0.05 )
		self.m_angOffset.y = math.ApproachAngle( self.m_angOffset.y, 0, self.m_angOffset.y*0.05 )
	end
end

vgui.Register( "sh_itemmodel", PANEL, "Panel" )

-- ----------------------------------------------------------------------------------------------------

local PANEL = {}

function PANEL:Init()
	self.Label = vgui.Create( "DLabel", self )
	self.Current = vgui.Create( "DLabel", self )
	
	self.Value = vgui.Create( "DNumberWang", self )
	self.Value:SetDecimals( 0 )
	self.Value:SetMinMax( 0, 1000 )
	
	self.Buy = vgui.Create( "DButton", self )
	self.Buy:SetText( "BUY" )
	function self.Buy.DoClick() self:DoBuy() end
	
	self.m_strBuyClass = ""
	self.m_iBuyType = 0
	self.m_BuyTbl = nil
	self.m_fLastLayout = 0
end

function PANEL:Setup( title, class, type )
	
	
	self.Label:SetText( title )
	self.m_strBuyClass = class
	self.m_iBuyType = type
	self.m_BuyTbl = GAMEMODE.Explosives[class] or GAMEMODE.Ammo[class] or nil
	
	local ply = LocalPlayer()
	local money = (ply and ply.GetMoney) and ply:GetMoney() or 0
	if self.m_BuyTbl then
		local max = money / self.m_BuyTbl.price
		self.Value:SetMinMax( 0, max )
		self.Value:SetValue( math.min(100,math.floor(max*0.50)) )
	else
		self.Value:SetMinMax( 0, 1000 )
		self.Value:SetValue( 50 )
	end
end

function PANEL:Update()
	local ply = LocalPlayer()
	local money = (ply and ply.GetMoney) and ply:GetMoney() or 0
	if money > 0 and self.m_BuyTbl then
		local max = money/self.m_BuyTbl.price
		self.Value:SetMinMax( 0, max )
		self.Value:SetValue( math.min(100,math.floor(max*0.50)) )
	else
		self.Value:SetMinMax( 0, 1000 )
		self.Value:SetValue( 50 )
	end
end

function PANEL:DoBuy()
	local money = LocalPlayer():GetMoney()
	local cost = self.m_BuyTbl.price * self.Value:GetValue()

	if cost <= money then
		surface.PlaySound( SND_CONFIRM )
	else
		surface.PlaySound( SND_FAIL )
	end
	
	RunConsoleCommand( "sh_buyitem", self.m_iBuyType, self.m_strBuyClass, self.Value:GetValue() )
end

function PANEL:Think()
	local count
	if self.m_strBuyClass == "" then
		count = 0
	end
	count = LocalPlayer():GetItemCount( self.m_strBuyClass )
	self.Current:SetText( tostring(count) )
	
	if RealTime() - self.m_fLastLayout > 0.20 then
		self:InvalidateLayout( true )
	end
end

function PANEL:PerformLayout()
	local w, h = self:GetWide(), self:GetTall()
	local qw = w*0.25
	
	self.Label:SizeToContents()
	self.Label:SetTall( h*0.50 )
	self.Label:SetPos( qw-self.Label:GetWide()*0.50, 0 )
	
	self.Current:SizeToContents()
	self.Current:SetTall( h*0.50 )
	self.Current:SetPos( w-qw-self.Current:GetWide()*0.50, 0 )
	
	self.Value:SetSize( w-40, h*0.50 )
	self.Value:SetPos( 0, h*0.50 )
	
	self.Buy:SetSize( 40, h*0.50 )
	self.Buy:SetPos( w-40, h*0.50 )
	
	self.m_fLastLayout = RealTime()
end

vgui.Register( "sh_quickbuy", PANEL, "Panel" )

-- ----------------------------------------------------------------------------------------------------

local PANEL = {}

function PANEL:Init()
	self.Loadouts = vgui.Create( "DListView", self )
	self.Loadouts:AddColumn( "Saved Loadouts" )
	self.Loadouts:SetMultiSelect( false )
	function self.Loadouts.OnRowSelected( panel, lineid, line )
		local ply = LocalPlayer()
		local loadout = ply:GetLoadout( line:GetColumnText(1) )
		if loadout then
			for _, v in ipairs(self.PrimaryList:GetLines()) do
				if v.weaponclass == loadout.primary then
					self.PrimaryList:OnClickLine( v, true )
				end
			end
			for _, v in ipairs(self.SecondaryList:GetLines()) do
				if v.weaponclass == loadout.secondary then
					self.SecondaryList:OnClickLine( v, true )
				end
			end
			for _, v in ipairs(self.ExplosiveList:GetLines()) do
				if v.weaponclass == loadout.explosive then
					self.ExplosiveList:OnClickLine( v, true )
				end
			end
		end
	end
	
	function self.Loadouts.DoDoubleClick( panel, id, line )
		GAMEMODE.LoadoutFrame:Close()
	end
	
	self.SaveLoadout = vgui.Create( "DButton", self )
	self.SaveLoadout:SetText( "Save Loadout" )
	function self.SaveLoadout.DoClick()
	local pri = self.CurrentPrimary or ""
	local sec = self.CurrentSecondary or ""
	local expl = self.CurrentExplosive or ""
	local ply = LocalPlayer()
		if pri == "" or sec == "" or expl == "" then
			ply:SendMessage( "You must select one of every category." )
			surface.PlaySound( SND_FAIL )
		else
			GAMEMODE.LoadoutFrame:SetKeyboardInputEnabled( false )
			GAMEMODE.LoadoutFrame:SetMouseInputEnabled( false )
			self.SaveRequest:SetVisible( true )
			self.SaveRequest:MakePopup()
			self.SaveRequest:Center()
		end
	end
	
	self.RemoveLoadout = vgui.Create( "DButton", self )
	self.RemoveLoadout:SetText( "Remove Selected" )
	function self.RemoveLoadout.DoClick()
		local lineid = self.Loadouts:GetSelectedLine()
		local line = self.Loadouts:GetLine( lineid )
		if line then
			RunConsoleCommand( "sh_removeloadout", line:GetColumnText(1) )
			LocalPlayer():RemoveLoadout( line:GetColumnText(1) )
			self.Loadouts:RemoveLine( lineid )
		end
	end
	
	self.RefreshLoadouts = vgui.Create( "DButton", self )
	self.RefreshLoadouts:SetText( "Refresh" )
	function self.RefreshLoadouts.DoClick()
		self:DoRefreshLoadouts()
		self:DoRefreshLicenses()
	end
	
	-- ----------
	
	self.CurrentPrimary = ""
	
	self.PrimaryModel = vgui.Create( "sh_itemmodel", self )
	self.PrimaryModel:Setup( "models/weapons/w_smg_mp5.mdl", "MP5-A4" )
	
	self.PrimaryList = vgui.Create( "DListView", self )
	self.PrimaryList:SetMultiSelect( false )
	self.PrimaryList:AddColumn( "Primary" )
	local column = self.PrimaryList:AddColumn( "Time left" )
	column:SetFixedWidth( 70 )
	
	self.PrimaryQuickBuy = vgui.Create( "sh_quickbuy", self )
	self.PrimaryQuickBuy:Setup( "SMG Ammo", "smg1", 4 )
	
	function self.PrimaryList.OnRowSelected( panel, lineid, line )
		local old_primary = self.CurrentPrimary
		self.CurrentPrimary = line.weaponclass or ""
		
		if self.CurrentPrimary != "" and old_primary != self.CurrentPrimary then
			RunConsoleCommand( "sh_setprimary", self.CurrentPrimary )
			local tbl = GAMEMODE.PrimaryWeapons[self.CurrentPrimary]
			self.PrimaryModel:Setup( tbl.model, tbl.name, (tbl.fov or 90), tbl.offset, 4 )
			self.PrimaryQuickBuy:Setup( ((tbl.type=="smg1" and "SMG") or (tbl.type=="buckshot" and "Shotgun") or (tbl.type=="ar2" and "Rifle") or (tbl.type=="rpg_round" and "RPG")).." Ammo", tbl.type, 4 )
			surface.PlaySound( SND_PRIMARY )
		end
	end
	
	-- ----------
	
	self.CurrentSecondary = ""
	
	self.SecondaryModel = vgui.Create( "sh_itemmodel", self )
	self.SecondaryModel:Setup( "models/weapons/w_pist_p228.mdl", "SIG-SAUER P228", 60 )
	
	self.SecondaryList = vgui.Create( "DListView", self )
	self.SecondaryList:SetMultiSelect( false )
	self.SecondaryList:AddColumn( "Secondary" )
	local column = self.SecondaryList:AddColumn( "Time left" )
	column:SetFixedWidth( 70 )
	
	self.SecondaryQuickBuy = vgui.Create( "sh_quickbuy", self )
	self.SecondaryQuickBuy:Setup( "Pistol Ammo", "pistol", 4 )
	
	function self.SecondaryList.OnRowSelected( panel, lineid, line )
		local old_secondary = self.CurrentSecondary
		self.CurrentSecondary = line.weaponclass or ""
		if self.CurrentSecondary != "" and old_secondary != self.CurrentSecondary then
			RunConsoleCommand( "sh_setsecondary", self.CurrentSecondary )
			local tbl = GAMEMODE.SecondaryWeapons[self.CurrentSecondary]
			self.SecondaryModel:Setup( tbl.model, tbl.name, (tbl.fov or 60), tbl.offset, 4 )
			self.SecondaryQuickBuy:Setup( ((tbl.type=="smg1" and "SMG") or (tbl.type=="pistol" and "Pistol") or (tbl.type=="buckshot" and "Shotgun") or (tbl.type=="ar2" and "Rifle") or (tbl.type=="rpg_round" and "RPG")).." Ammo", tbl.type, 4 )
			surface.PlaySound( SND_SECONDARY )
		end
	end
	
	-- ----------
	
	self.CurrentExplosive = ""
	
	self.ExplosiveModel = vgui.Create( "sh_itemmodel", self )
	self.ExplosiveModel:Setup( "models/weapons/w_eq_fraggrenade.mdl", "H.E. Grenade", 35 )
	
	self.ExplosiveList = vgui.Create( "DListView", self )
	self.ExplosiveList:SetMultiSelect( false )
	self.ExplosiveList:AddColumn( "Explosives" )
	local column = self.ExplosiveList:AddColumn( "Count" )
	column:SetFixedWidth( 50 )
	
	self.ExplosiveQuickBuy = vgui.Create( "sh_quickbuy", self )
	self.ExplosiveQuickBuy:Setup( "Grenade Ammo", "weapon_sh_grenade", 3 )
	
	function self.ExplosiveList.OnRowSelected( panel, lineid, line )
		local old_explosive = self.CurrentExplosive
		self.CurrentExplosive = line.weaponclass or ""
		if self.CurrentExplosive != "" and old_explosive != self.CurrentExplosive then
			RunConsoleCommand( "sh_setexplosive", self.CurrentExplosive )
			local tbl = GAMEMODE.Explosives[self.CurrentExplosive]
			self.ExplosiveModel:Setup( tbl.model, tbl.name, (tbl.fov or 35), tbl.offset )
			self.ExplosiveQuickBuy:Setup(
				((self.CurrentExplosive=="weapon_sh_grenade" and "H.E. Grenades") or
				 (self.CurrentExplosive=="weapon_sh_smoke" and "Smoke Grenades") or
				 (self.CurrentExplosive=="weapon_sh_flash" and "Flash Grenades") or
				 (self.CurrentExplosive=="weapon_sh_c4" and "C4 Explosives")),
				self.CurrentExplosive, 3 )
			surface.PlaySound( SND_EXPLOSIVE )
		end
	end
	
	-- ----------
	
	self.SaveRequest = vgui.Create( "DFrame" )
	self.SaveRequest:SetDeleteOnClose( false )
	self.SaveRequest:SetTitle( "Save Loadout" )
	self.SaveRequest:SetDraggable( false )
	self.SaveRequest:ShowCloseButton( false )
	self.SaveRequest:SetSize( 150, 94 )
	self.SaveRequest:SetVisible( false )
	self.SaveRequest:SetSkin( "stronghold" )
	
	function self.SaveRequest.Close( panel )
		GAMEMODE.LoadoutFrame:SetKeyboardInputEnabled( false )
		GAMEMODE.LoadoutFrame:SetMouseInputEnabled( false )
		panel:SetVisible( false )
		GAMEMODE.LoadoutFrame:MakePopup()
	end
	
	local label = vgui.Create( "DLabel", self.SaveRequest )
	label:SetText( "Name:" )
	label:SizeToContents()
	label:SetTall( 22 )
	label:SetPos( 10, 30 )
	
	local name = vgui.Create( "DTextEntry", self.SaveRequest )
	name:SetSize( 120-label:GetWide(), 22 )
	name:SetPos( label:GetWide()+20, 30 )
	
	local cancel = vgui.Create( "DButton", self.SaveRequest )
	cancel:SetText( "Cancel" )
	cancel:SetSize( 60, 22 )
	cancel:SetPos( 10, 64 )
	function cancel.DoClick() self.SaveRequest:Close() end
	
	local save = vgui.Create( "DButton", self.SaveRequest )
	save:SetText( "Save" )
	save:SetSize( 60, 22 )
	save:SetPos( 80, 64 ) 
	function save.DoClick() local ply = LocalPlayer()
		if name:GetValue() != "" then 
			self:DoSaveLoadout( name:GetValue() ) self.SaveRequest:Close() 
		else 
			ply:SendMessage( "You must name your loadout." )
			surface.PlaySound( SND_FAIL )
		end 
	end
end

function PANEL:DoRefreshLoadouts()
	self.Loadouts:Clear()
	local ply = LocalPlayer()
	for k, _ in pairs(ply:GetLoadouts()) do
		self.Loadouts:AddLine( k )
	end
	self.Loadouts:SortByColumn( 1, false )
end

function PANEL:DoRefreshLicenses()
	local ply = LocalPlayer()
	local ostime = os.time()

	self.PrimaryList:Clear()
	for class, time in pairs(ply:GetLicenses(1)) do
		local timeleft = (time == -1 and -1 or time-ostime)
		local tbl = GAMEMODE.PrimaryWeapons[class]
		if tbl and (timeleft == -1 or timeleft > 0) then
			local line = self.PrimaryList:AddLine( tbl.name, (timeleft != -1 and UTIL_FormatTime(timeleft,true) or "~") )
			line.weaponclass = class
			if class == self.CurrentPrimary then
				line:SetSelected( true )
				selected = self.CurrentPrimary
			end
		end
	end
	self.PrimaryList:SortByColumn( 1, false )
	
		local selectedid = self.PrimaryList:GetSelectedLine() or 1
		if selectedid != nil then
			local line = self.PrimaryList:GetLine(selectedid)
			if line != nil then
				self.PrimaryList:OnClickLine( line )
			end
		end
	
	self.SecondaryList:Clear()
	for class, time in pairs(ply:GetLicenses(2)) do
		local timeleft = (time == -1 and -1 or time-ostime)
		local tbl = GAMEMODE.SecondaryWeapons[class]
		if tbl and (timeleft == -1 or timeleft > 0) then
			local line = self.SecondaryList:AddLine( tbl.name, (timeleft != -1 and UTIL_FormatTime(timeleft,true) or "~") )
			line.weaponclass = class
			if class == self.CurrentSecondary then
				line:SetSelected( true )
			end
		end
	end
	self.SecondaryList:SortByColumn( 1, false )
	
		local selectedid = self.SecondaryList:GetSelectedLine() or 1
		if selectedid != nil then
			local line = self.SecondaryList:GetLine(selectedid)
			if line != nil then
				self.SecondaryList:OnClickLine( line )
			end
		end
	
	self.ExplosiveList:Clear()
	for class, tbl in pairs(GAMEMODE.Explosives) do
		local line = self.ExplosiveList:AddLine( tbl.name, ply:GetItemCount(class) )
		line.weaponclass = class
		if class == self.CurrentExplosive then
			line:SetSelected( true )
		end
	end
	self.ExplosiveList:SortByColumn( 1, false )
	
		local selectedid = self.ExplosiveList:GetSelectedLine() or 1
		if selectedid != nil then
			local line = self.ExplosiveList:GetLine(selectedid)
			if line != nil then
				self.ExplosiveList:OnClickLine( line )
			end
		end
	
	self.PrimaryQuickBuy:Update()
	self.SecondaryQuickBuy:Update()
	self.ExplosiveQuickBuy:Update()
end

function PANEL:DoSaveLoadout( name )
	local pri = self.CurrentPrimary or ""
	local sec = self.CurrentSecondary or ""
	local expl = self.CurrentExplosive or ""
	local ply = LocalPlayer()
	if name != "" and pri != "" and sec != "" and expl != "" then
		RunConsoleCommand( "sh_editloadout", name, pri, sec, expl )
		ply:EditLoadout( name, pri, sec, expl )
		self:DoRefreshLoadouts()
		surface.PlaySound( SND_CONFIRM )
	end
end

function PANEL:PerformLayout()
	local w, h = self:GetWide(), self:GetTall()
	local spacing = (w-30) * 0.25
	
	self.Loadouts:SetSize( spacing, h-66 )
	self.Loadouts:SetPos( 0, 0 )
	
	self.SaveLoadout:SetSize( spacing, 22 )
	self.SaveLoadout:SetPos( 0, h-66 )
	
	self.RemoveLoadout:SetSize( spacing, 22 )
	self.RemoveLoadout:SetPos( 0, h-44 )
	
	self.RefreshLoadouts:SetSize( spacing, 22 )
	self.RefreshLoadouts:SetPos( 0, h-22 )
	
	self.PrimaryModel:SetSize( spacing, spacing )
	self.PrimaryModel:SetPos( spacing+10, 0 )
	self.PrimaryList:SetSize( spacing, h-54-spacing )
	self.PrimaryList:SetPos( spacing+10, 10+spacing )
	self.PrimaryQuickBuy:SetSize( spacing, 44 )
	self.PrimaryQuickBuy:SetPos( spacing+10, h-44 )
	
	self.SecondaryModel:SetSize( spacing, spacing )
	self.SecondaryModel:SetPos( (spacing+10)*2, 0 )
	self.SecondaryList:SetSize( spacing, h-54-spacing )
	self.SecondaryList:SetPos( (spacing+10)*2, 10+spacing )
	self.SecondaryQuickBuy:SetSize( spacing, 44 )
	self.SecondaryQuickBuy:SetPos( (spacing+10)*2, h-44 )
	
	self.ExplosiveModel:SetSize( spacing, spacing )
	self.ExplosiveModel:SetPos( (spacing+10)*3, 0 )
	self.ExplosiveList:SetSize( spacing, h-54-spacing )
	self.ExplosiveList:SetPos( (spacing+10)*3, 10+spacing )
	self.ExplosiveQuickBuy:SetSize( spacing, 44 )
	self.ExplosiveQuickBuy:SetPos( (spacing+10)*3, h-44 )
	
	self.SaveRequest:Center()
end

vgui.Register( "sh_loadoutpanel", PANEL, "Panel" )