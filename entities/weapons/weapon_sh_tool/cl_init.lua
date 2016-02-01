gmod_toolmode = CreateClientConVar( "gmod_toolmode", "rope", true, true )
local TOOL_RADIAL_SHOWMOUSE = CreateClientConVar( "sh_tool_radialshowmouse", 0, true, false )
local TOOL_RADIAL_MODE = CreateClientConVar( "sh_tool_radialmode", 1, true, false )
local TOOL_RADIAL_SPEED = CreateClientConVar( "sh_tool_radialmode_speed", 0.15, true, false )
local TOOL_ALTERNATEINPUT = CreateClientConVar( "sh_tool_altinput", 0, true, false )

include( "shared.lua" )
include( "cl_viewscreen.lua" )

SWEP.PrintName          = "TOOL GUN"
SWEP.Slot               = 5
SWEP.SlotPos            = 1
SWEP.DrawAmmo           = false
SWEP.DrawCrosshair      = false

SWEP.WepSelectIcon = surface.GetTextureID( "vgui/gmod_tool" )

SWEP.MenuOpen = false
SWEP.MenuCurAngle = 90
SWEP.MenuTargetAngle = 90

local function round( x, interval, total )
	if interval == 0 then
		return (x-math.floor(x) >= 0.50 and math.ceil(x) or math.floor(x))
	else
		return round( (x/total) * (total/interval), 0 ) * interval
	end
end

local MAT_CROSSHAIR = surface.GetTextureID( "sprites/hud/v_crosshair2" )
function SWEP:DrawHUD()
	local sw, sh = ScrW()/640, ScrH()/480
	local x, y, w, h = ScrW()-math.floor(sw*150), math.floor(sh*432), math.floor(sw*136), math.max( 67, math.floor(sh*36) )
	local firemode = self:GetFireMode()
	local _, th = surface.GetTextSize( "ABC123" )
	local mode = self:GetMode()
	local tool = self:GetToolObject( mode )
	local str_fm = (firemode == 0 and "PRIMARY" or "SECONDARY")
	local tw, th = surface.GetTextSize( str_fm )

	self:RadialDrawHUD()

	-- Info box
	--[[surface.SetFont( "DefaultBold" )

	th = math.floor( th )
	surface.SetTextColor( 255, 220, 0, 220 )

	draw.RoundedBox( 8, x, y, w, h, Color(0,0,0,76) )
	draw.RoundedBox( 4, x+6, y+6, w-12, th+4, Color(0,0,0,100) )
	draw.RoundedBox( 4, x+6, y+th+16, w-12, h-th-22, Color(0,0,0,100) )


	surface.SetTextPos( x+10, math.floor(y+2+th/2) )
	surface.DrawText( "TOOL MODE: " )
	surface.DrawText( !tool and "None" or (tool.Name and tool.Name or "#"..mode) )


	surface.SetTextPos( x+w-tw-9, math.floor(y+2+th/2) )
	surface.DrawText( str_fm )

	if tool then
		surface.SetTextPos( x+10, y+th+19 )
		surface.DrawText( "#Tool_"..mode.."_desc" )

		surface.SetFont( "Default" )
		local _, th2 = surface.GetTextSize( "ABC123" )
		surface.SetTextPos( x+14, y+th+th2+20 )
		surface.DrawText( (tool:GetStage()+1)..": " )
		surface.DrawText( "#Tool_"..mode.."_"..tool:GetStage() )
	end]]

	-- Crosshair
	local col = Color( 255, 255, 255, 220 )
	if tool and !tool.HideAuth then
		local trace, _ = self:Authorize()
		if trace != nil then
			col = Color( 100, 255, 100, 220 )
		else
			col = Color( 255, 100, 100, 220 )
		end
	end

	if !self.MenuOpen or !TOOL_RADIAL_SHOWMOUSE:GetBool() or TOOL_RADIAL_MODE:GetInt() != 1 then
		x, y = ScrW()/2, ScrH()/2
	else
		x, y = gui.MousePos()
		local cx, cy = ScrW()/2, ScrH()/2
		local dist, dist_max = math.Distance( x, y, cx, cy ), ScrH()/1050*80
		if dist > dist_max then
			local norm = Vector( x-cx, cy-y, 0 ):GetNormalized()
			x, y = cx+norm.x*dist_max, cy-norm.y*dist_max
		end
	end
	surface.SetTexture( MAT_CROSSHAIR )
	surface.SetDrawColor( col )
	if !self.MenuOpen then
		surface.DrawTexturedRectRotated( x, y, 32, 32, (firemode == 0 and 0 or 90) )
	else
		surface.DrawTexturedRectRotated( x, y, 32, 32, 0 )
		surface.DrawTexturedRectRotated( x, y, 32, 32, 90 )
	end

	if firemode == 0 or self.MenuOpen then
		surface.SetDrawColor( 0, 0, 0, 200 )
		surface.DrawRect( x-2, y-2, 4, 4 )
		surface.SetDrawColor( col )
		surface.DrawRect( x-1, y-1, 2, 2 )
	elseif firemode == 1 then
		surface.SetDrawColor( 0, 0, 0, 200 )
		surface.DrawRect( x-4, y-2, 8, 4 )
		surface.SetDrawColor( col )
		surface.DrawRect( x-3, y-1, 2, 2 )
		surface.DrawRect( x+1, y-1, 2, 2 )
	end

	if tool then tool:DrawHUD() end
end

function SWEP:SetStage( ... )
	if !self:GetToolObject() then return end
	return self:GetToolObject():SetStage( ... )
end

function SWEP:GetStage( ... )
	if !self:GetToolObject() then return end
	return self:GetToolObject():GetStage( ... )
end

function SWEP:ClearObjects( ... )
	if !self:GetToolObject() then return end
	self:GetToolObject():ClearObjects( ... )
end

function SWEP:StartGhostEntities( ... )
	if !self:GetToolObject() then return end
	self:GetToolObject():StartGhostEntities( ... )
end

function SWEP:FreezeMovement()
	local mode = self:GetMode()
	if !self:GetToolObject() then return self.MenuOpen end
	return self:GetToolObject():FreezeMovement() or self.MenuOpen
end

--[[
	RADIAL MENU
]]

local MOUSE_CHECK_DIST = 80
local MOUSE_CUR_DIST = 0
local CUR_SELECTION, LAST_SELECTION = nil
function SWEP:RadialThink()
	if !self.MenuOpen then return end

	local sscale = ScrH() / 1050
	local radialmode = TOOL_RADIAL_MODE:GetInt()
	if radialmode == 1 then
		if self.MenuOpen then
			local mx, my = gui.MousePos()
			local cx, cy = ScrW()/2, ScrH()/2
			MOUSE_CUR_DIST = math.Distance( mx, my, cx, cy )
			if MOUSE_CUR_DIST > sscale*48 then
				local norm = Vector( mx-cx, cy-my, 0 ):GetNormalized()
				self.MenuTargetAngle = norm:Angle().y
				if MOUSE_CUR_DIST > MOUSE_CHECK_DIST*sscale then
					gui.SetMousePos( cx+norm.x*(MOUSE_CHECK_DIST*sscale), cy-norm.y*(MOUSE_CHECK_DIST*sscale) )
				end
			end
		end
		self.MenuCurAngle = math.ApproachAngle( self.MenuCurAngle, self.MenuTargetAngle, 15*(math.AngleDifference(self.MenuCurAngle,self.MenuTargetAngle)/180) )
	else
		local cmd = self.Owner:GetCurrentCommand()
		self.MenuCurAngle = self.MenuCurAngle - (radialmode == 2 and cmd:GetMouseX() or cmd:GetMouseY()) * TOOL_RADIAL_SPEED:GetFloat()
		if self.MenuCurAngle < 0 then self.MenuCurAngle = self.MenuCurAngle + 360 end
	end

	CUR_SELECTION, _ = self:GetCurrentSelection()
	if LAST_SELECTION != nil and CUR_SELECTION != LAST_SELECTION then
		surface.PlaySound( self.DuringSelectionSound )
	end
	LAST_SELECTION = CUR_SELECTION
end

local TEX_RADIALBG = surface.GetTextureID( "tool_radialbg" )
local TEX_RADIALSELECT = surface.GetTextureID( "tool_radialselect" )
local TEX_RADIALMOUSE = surface.GetTextureID( "sprites/hud/v_crosshair1" )
function SWEP:RadialDrawHUD()
	if !self.MenuOpen then return end

	local sscale = ScrH() / 1050
	local sx, sy = ScrW()/2, ScrH()/2
	local size, size_half, center, label = 256*sscale, 128*sscale, 84*sscale, 150*sscale

	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.SetTexture( TEX_RADIALBG )
	surface.DrawTexturedRect( sx-size_half, sy-size_half, size, size )
	if MOUSE_CUR_DIST > sscale*48 or TOOL_RADIAL_MODE:GetInt() != 1 then
		surface.SetTexture( TEX_RADIALSELECT )
		surface.DrawTexturedRectRotated( sx, sy, size, size, self.MenuCurAngle )
	end

	local i, count = 0, table.Count( self.Tool )
	for k, v in pairs(self.Tool) do
		if v.AllowedCVar == 0 or v.AllowedCVar:GetBool() then
			local brightness = (k == CUR_SELECTION and 255 or 200)
			local ang = v.RadialAngle
			local vx, vy = math.cos(ang), math.sin(ang)
			local x, y = sx-vx*center, sy+vy*(center-1)

			local lx, ly = math.cos( ang+self.ToolAngBetween/2 ), math.sin( ang+self.ToolAngBetween/2 )
			surface.SetDrawColor( 80, 80, 80, 200 )
			surface.DrawLine( sx+lx*74*sscale, sy+ly*74*sscale, sx+lx*94*sscale, sy+ly*94*sscale )

			surface.SetDrawColor( brightness, brightness, brightness, 255 )
			surface.SetTexture( v.SelectIcon or self.WepSelectIcon )
			surface.DrawTexturedRectRotated( x, y, 64, 64, 0 )

			surface.SetFont( "DefaultBold" )
			local tw, th = surface.GetTextSize( v.Name )
			local tx, ty = sx-vx*label-tw/2-tw/4*vx, sy+vy*label-th/2-th*vy

			surface.SetTextColor( 0, 0, 0, 255 )
			for _x=-1, 1 do
				for _y=-1, 1 do
					surface.SetTextPos( tx+_x, ty+_y )
					surface.DrawText( v.Name )
				end
			end
			--[[surface.SetTextPos( tx-1, ty-1 )
			surface.DrawText( v.Name )
			surface.SetTextPos( tx-1, ty+1 )
			surface.DrawText( v.Name )
			surface.SetTextPos( tx+1, ty-1 )
			surface.DrawText( v.Name )
			surface.SetTextPos( tx+1, ty+1 )
			surface.DrawText( v.Name )]]

			surface.SetTextColor( brightness, brightness, brightness, 220 )
			surface.SetTextPos( tx, ty )
			surface.DrawText( v.Name )

			--draw.SimpleTextOutlined( v.Name, "DefaultBold", math.floor(x-tw/2), math.floor(y), Color(brightness,brightness,brightness,220), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(20,20,20,220) )

			i = i + 1
		end
	end
end

function SWEP:GetCurrentSelection()
	local sscale = ScrH() / 1050
	local radialmenu = TOOL_RADIAL_MODE:GetInt() != 1
	local selection, selectionang = self:GetMode(), -1

	if MOUSE_CUR_DIST > sscale*48 or radialmenu then
		local selang = -1
		local i, count = 0, table.Count( self.Tool )
		for k, v in pairs(self.Tool) do
			local ang = math.deg( v.RadialAngle - self.ToolAngBetween/2 )
			local diff = math.AngleDifference( (!radialmenu and self.MenuTargetAngle or self.MenuCurAngle), ang )
			if selang == -1 or diff < selang then
				selang = diff
				selection = k
				selectionang = math.deg( v.RadialAngle ) + 180 -- I'm not sure what is going on here but WHAT EVER
			end
			i = i + 1
		end
	end

	return selection, math.NormalizeAngle( selectionang )
end

function SWEP:OpenMenu()
	if self.MenuOpen then return end

	if TOOL_RADIAL_MODE:GetInt() == 1 then
		vgui.GetWorldPanel():SetCursor( "blank" )
		gui.EnableScreenClicker( true )
		gui.SetMousePos( ScrW()/2, ScrH()/2 )
	else
		local sel, ang = self:GetCurrentSelection()
		self.MenuTargetAngle = ang
		self.MenuCurAngle = ang
	end

	self.MenuOpen = true
end

function SWEP:CloseMenu()
	if !self.MenuOpen then return end

	self.MenuOpen = false

	-- Check for selection
	local selection, _ = self:GetCurrentSelection()
	if selection != self:GetMode() then
		RunConsoleCommand( "gmod_toolmode", selection )
		surface.PlaySound( self.SelectSound )
	end

	if TOOL_RADIAL_MODE:GetInt() == 1 then
		gui.EnableScreenClicker( false )
		vgui.GetWorldPanel():SetCursor( "" )
	end
end

local function KeyPress( ply, key )
	if !IsValid( ply ) or !IsValid( ply:GetActiveWeapon() ) or ply:GetActiveWeapon():GetClass() != "weapon_sh_tool" then return end
	local altinput = TOOL_ALTERNATEINPUT:GetBool()
	local weapon = ply:GetActiveWeapon()

	if (altinput and key == IN_RELOAD) or (!altinput and key == IN_ATTACK2) then
		weapon:OpenMenu()
	end
end
hook.Add( "KeyPress", "tool_KeyPress", KeyPress )

local function KeyRelease( ply, key )
	if !IsValid( ply ) or !IsValid( ply:GetActiveWeapon() ) or ply:GetActiveWeapon():GetClass() != "weapon_sh_tool" then return end
	local altinput = TOOL_ALTERNATEINPUT:GetBool()
	local weapon = ply:GetActiveWeapon()

	if (altinput and key == IN_RELOAD) or (!altinput and key == IN_ATTACK2) then
		weapon:CloseMenu()
	end
end
hook.Add( "KeyRelease", "tool_KeyRelease", KeyRelease )
