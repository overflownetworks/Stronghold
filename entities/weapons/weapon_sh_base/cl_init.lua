include("shared.lua")

local SCOPEFADE_TIME = 0.2
function SWEP:DrawHUD()
	if self.UseScope then

			if self.bInIronSight !=self.LastIron then
				self.LastIron = self.bInIronSight
				self.IronTime = CurTime()
			end

		--if !self.bInIronSight then return end
		local In = (math.Clamp( ((CurTime()-self.IronTime)/SCOPEFADE_TIME), 0, 1 ))
		local Out = (math.Clamp( ((CurTime()-self.IronTime)/(SCOPEFADE_TIME*0.5)), 0, 1 )-1)*-1
		local scale = self.bInIronSight and In or 
		!self.bInIronSight and Out

		if self.UseScope and !self.Acog then
			-- Draw the crosshair
			surface.SetDrawColor(0,0,0,255*scale)
			surface.DrawRect(0,ScrH()*0.5,ScrW(),1)
			surface.DrawRect(ScrW()*0.5,0,1,ScrH())

			-- Put the texture
			surface.SetDrawColor(0, 0, 0, 255*scale)
			surface.SetTexture(surface.GetTextureID("scope/scope_normal"))
			surface.DrawTexturedRect((ScrW()*0.5)-(ScrH()*0.5),0, ScrH(), ScrH())

			-- Fill in everything else
			surface.SetDrawColor(0, 0, 0, 255*scale)
			surface.DrawRect(0,0, (ScrW()*0.5)-(ScrH()*0.5)	, ScrH())
			surface.DrawRect(((ScrW()*0.5)-(ScrH()*0.5))+ScrH()	,0, ScrW()	, ScrH())
			--end
		end
				
		if self.UseScope and self.Acog then
			-- Draw the crosshair
			surface.SetDrawColor(200, 0, 0, 255*scale)
			surface.DrawRect(ScrW()*0.5-1,ScrH()*0.5+10, 2,10)
			surface.SetDrawColor(0, 0, 0, 255*scale)
			surface.DrawRect(ScrW()*0.5-1,ScrH()*0.5+20, 2,110)
			surface.DrawRect(ScrW()*0.5-15,ScrH()*0.5+20, 30,1)
			surface.DrawRect(ScrW()*0.5-13,ScrH()*0.5+40, 26,1)
			surface.DrawRect(ScrW()*0.5-5,ScrH()*0.5+70, 10,1)
			surface.DrawRect(ScrW()*0.5-3,ScrH()*0.5+130, 6,1)
			
			surface.DrawRect(ScrW()*0.55,ScrH()*0.5+8, ScrW()*0.45,2)
			surface.DrawRect(0,ScrH()*0.5+8, ScrW()*0.45,2)
			
			surface.DrawRect(ScrW()*0.55,ScrH()*0.5-10, 1,40)
			surface.DrawRect(ScrW()*0.55+40,ScrH()*0.5, 1,20)
			surface.DrawRect(ScrW()*0.55+80,ScrH()*0.5-10, 1,40)
			surface.DrawRect(ScrW()*0.55+120,ScrH()*0.5, 1,20)
			surface.DrawRect(ScrW()*0.55+160,ScrH()*0.5-10, 1,40)
			surface.DrawRect(ScrW()*0.55+200,ScrH()*0.5, 1,20)
			surface.DrawRect(ScrW()*0.55+240,ScrH()*0.5-10, 1,40)
			
			
			surface.DrawRect(ScrW()*0.45,ScrH()*0.5-10, 1,40)
			surface.DrawRect(ScrW()*0.45-40,ScrH()*0.5, 1,20)
			surface.DrawRect(ScrW()*0.45-80,ScrH()*0.5-10, 1,40)
			surface.DrawRect(ScrW()*0.45-120,ScrH()*0.5, 1,20)
			surface.DrawRect(ScrW()*0.45-160,ScrH()*0.5-10, 1,40)
			surface.DrawRect(ScrW()*0.45-200,ScrH()*0.5, 1,20)
			surface.DrawRect(ScrW()*0.45-240,ScrH()*0.5-10, 1,40)
			

			-- Put the texture
			surface.SetDrawColor(0, 0, 0, 255*scale)
			surface.SetTexture(surface.GetTextureID("scope/scope_normal"))
			surface.DrawTexturedRect((ScrW()*0.5)-(ScrH()*0.5),0, ScrH(), ScrH())
			
			surface.SetDrawColor(200, 0, 0, 255*scale)
			surface.SetTexture(surface.GetTextureID("scope/acog_reticle"))
			surface.DrawTexturedRect(ScrW()*0.5-8, ScrH()*0.5-8, 16, 16)

			-- Fill in everything else
			surface.SetDrawColor(0, 0, 0, 255*scale)
			surface.DrawRect(0,0, (ScrW()*0.5)-(ScrH()*0.5)	, ScrH())
			surface.DrawRect(((ScrW()*0.5)-(ScrH()*0.5))+ScrH()	,0, ScrW()	, ScrH())
		end
		end
		self:Crosshair()
end