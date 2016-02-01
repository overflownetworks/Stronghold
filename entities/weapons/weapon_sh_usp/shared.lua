if (SERVER) then
	AddCSLuaFile("shared.lua")
	SWEP.HoldType 		= "pistol"
elseif (CLIENT) then
	SWEP.PrintName 		= "USP .45"
	SWEP.IconLetter 	= "a"
	SWEP.CSMuzzleFlashes	= false
	SWEP.ViewModelFOV		= 60

	killicon.AddFont("weapon_sh_usp", "CSKillIcons", SWEP.IconLetter, Color(200, 200, 200, 255))
end

SWEP.MuzzleAttachment		= "1" 
SWEP.Base 					= "weapon_sh_base_pistol"
SWEP.Spawnable 				= true
SWEP.AdminSpawnable 		= true
SWEP.ViewModel 				= "models/weapons/v_pist_usp.mdl"
SWEP.WorldModel 			= "models/weapons/w_pist_usp.mdl"
SWEP.Primary.Sound 			= Sound("Weapon_USP.SilencedShot")
SWEP.Primary.Recoil 		= 0.3
SWEP.Primary.Damage 		= 13
SWEP.Primary.NumShots 		= 1
SWEP.Primary.ClipSize 		= 15
SWEP.Primary.Delay 			= 0.1
SWEP.Primary.DefaultClip 	= 15
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= "pistol"
SWEP.IronSightsPos 			= Vector (4.48, 0.1, 2.75)
SWEP.IronSightsAng 			= Vector (-0.15, 0, 0)
--SWEP.ViewModelBonescales 	= {["v_weapon"] = Vector(0.01, 0.01, 0.01)}
SWEP.VElements = {
	["some_unique_name"] = { type = "Model", model = "models/props_silo/pylon.mdl", bone = "v_weapon.USP_Switch", pos = Vector(-0.11, 0.699, 13.812), angle = Angle(-180, 0, 0), size = Vector(0.123, 0.123, 0.123), color = Color(150, 150, 150, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} }
}

function SWEP:Initialize()
 
    self:RunAnglePreset()

	self:SetWeaponHoldType( self.HoldType ) 	-- 3rd person hold type

	self.Reloadaftershoot = 0 	-- Can't reload when firing
 
    if CLIENT then
     
        self:CreateModels(self.VElements) // create viewmodels
        self:CreateModels(self.WElements) // create worldmodels
         
        // init view model bone build function
        self.BuildViewModelBones = function( s )
            if LocalPlayer():GetActiveWeapon() == self and self.ViewModelBonescales then
                for k, v in pairs( self.ViewModelBonescales ) do
                    local bone = s:LookupBone(k)
                    if (!bone) then continue end
                    local m = s:GetBoneMatrix(bone)
                    if (!m) then continue end
                    m:Scale(v)
                    s:SetBoneMatrix(bone, m)
                end
            end
        end
         
    end
 
end
 
 
function SWEP:OnRemove()
     
    // other onremove code goes here
     
    if CLIENT then
        self:RemoveModels()
    end
     
end
     
 
if CLIENT then
 
    SWEP.vRenderOrder = nil
    function SWEP:ViewModelDrawn()
         
        local vm = self.Owner:GetViewModel()
        if !ValidEntity(vm) then return end
         
        if (!self.VElements) then return end
         
        if vm.BuildBonePositions ~= self.BuildViewModelBones then
            vm.BuildBonePositions = self.BuildViewModelBones
        end
 
        if (self.ShowViewModel == nil or self.ShowViewModel) then
            vm:SetColor(255,255,255,255)
        else
            // we set the alpha to 1 instead of 0 because else ViewModelDrawn stops being called
            vm:SetColor(255,255,255,1) 
        end
         
        if (!self.vRenderOrder) then
             
            // we build a render order because sprites need to be drawn after models
            self.vRenderOrder = {}
 
            for k, v in pairs( self.VElements ) do
                if (v.type == "Model") then
                    table.insert(self.vRenderOrder, 1, k)
                elseif (v.type == "Sprite" or v.type == "Quad") then
                    table.insert(self.vRenderOrder, k)
                end
            end
             
        end
 
        for k, name in ipairs( self.vRenderOrder ) do
         
            local v = self.VElements[name]
            if (!v) then self.vRenderOrder = nil break end
         
            local model = v.modelEnt
            local sprite = v.spriteMaterial
             
            if (!v.bone) then continue end
            local bone = vm:LookupBone(v.bone)
            if (!bone) then continue end
             
            local pos, ang = Vector(0,0,0), Angle(0,0,0)
            local m = vm:GetBoneMatrix(bone)
            if (m) then
                pos, ang = m:GetTranslation(), m:GetAngle()
            end
             
            if (self.ViewModelFlip) then
                ang.r = -ang.r // Fixes mirrored models
            end
             
            if (v.type == "Model" and ValidEntity(model)) then
 
                model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
                ang:RotateAroundAxis(ang:Up(), v.angle.y)
                ang:RotateAroundAxis(ang:Right(), v.angle.p)
                ang:RotateAroundAxis(ang:Forward(), v.angle.r)
 
                model:SetAngles(ang)
                model:SetModelScale(v.size)
                 
                if (v.material == "") then
                    model:SetMaterial("")
                elseif (model:GetMaterial() != v.material) then
                    model:SetMaterial( v.material )
                end
                 
                if (v.skin and v.skin != model:GetSkin()) then
                    model:SetSkin(v.skin)
                end
                 
                if (v.bodygroup) then
                    for k, v in pairs( v.bodygroup ) do
                        if (model:GetBodygroup(k) != v) then
                            model:SetBodygroup(k, v)
                        end
                    end
                end
                 
                if (v.surpresslightning) then
                    render.SuppressEngineLighting(true)
                end
                 
                render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
                render.SetBlend(v.color.a/255)
                model:DrawModel()
                render.SetBlend(1)
                render.SetColorModulation(1, 1, 1)
                 
                if (v.surpresslightning) then
                    render.SuppressEngineLighting(false)
                end
                 
            elseif (v.type == "Sprite" and sprite) then
                 
                local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
                render.SetMaterial(sprite)
                render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
                 
            elseif (v.type == "Quad" and v.draw_func) then
                 
                local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
                ang:RotateAroundAxis(ang:Up(), v.angle.y)
                ang:RotateAroundAxis(ang:Right(), v.angle.p)
                ang:RotateAroundAxis(ang:Forward(), v.angle.r)
                 
                cam.Start3D2D(drawpos, ang, v.size)
                    v.draw_func( self )
                cam.End3D2D()
 
            end
             
        end
         
    end
 
    SWEP.wRenderOrder = nil
    function SWEP:DrawWorldModel()
         
        if (self.ShowWorldModel == nil or self.ShowWorldModel) then
            self:DrawModel()
        end
         
        if (!self.WElements) then return end
         
        if (!self.wRenderOrder) then
 
            self.wRenderOrder = {}
 
            for k, v in pairs( self.WElements ) do
                if (v.type == "Model") then
                    table.insert(self.wRenderOrder, 1, k)
                elseif (v.type == "Sprite" or v.type == "Quad") then
                    table.insert(self.wRenderOrder, k)
                end
            end
 
        end
         
        local opos, oang = self:GetPos(), self:GetAngles()
        local bone_ent
 
        if (ValidEntity(self.Owner)) then
            bone_ent = self.Owner
        else
            // when the weapon is dropped
            bone_ent = self
        end
         
        local bone = bone_ent:LookupBone("ValveBiped.Bip01_R_Hand")
        if (bone) then
            local m = bone_ent:GetBoneMatrix(bone)
            if (m) then
                opos, oang = m:GetTranslation(), m:GetAngle()
            end
        end
         
        for k, name in pairs( self.wRenderOrder ) do
         
            local v = self.WElements[name]
            if (!v) then self.wRenderOrder = nil break end
         
            local model = v.modelEnt
            local sprite = v.spriteMaterial
 
            local pos, ang = Vector(opos.x, opos.y, opos.z), Angle(oang.p, oang.y, oang.r)
 
            if (v.type == "Model" and ValidEntity(model)) then
 
                model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
                ang:RotateAroundAxis(ang:Up(), v.angle.y)
                ang:RotateAroundAxis(ang:Right(), v.angle.p)
                ang:RotateAroundAxis(ang:Forward(), v.angle.r)
 
                model:SetAngles(ang)
                model:SetModelScale(v.size)
                 
                if (v.material == "") then
                    model:SetMaterial("")
                elseif (model:GetMaterial() != v.material) then
                    model:SetMaterial( v.material )
                end
                 
                if (v.skin and v.skin != model:GetSkin()) then
                    model:SetSkin(v.skin)
                end
                 
                if (v.bodygroup) then
                    for k, v in pairs( v.bodygroup ) do
                        if (model:GetBodygroup(k) != v) then
                            model:SetBodygroup(k, v)
                        end
                    end
                end
                 
                if (v.surpresslightning) then
                    render.SuppressEngineLighting(true)
                end
                 
                render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
                render.SetBlend(v.color.a/255)
                model:DrawModel()
                render.SetBlend(1)
                render.SetColorModulation(1, 1, 1)
                 
                if (v.surpresslightning) then
                    render.SuppressEngineLighting(false)
                end
                 
            elseif (v.type == "Sprite" and sprite) then
                 
                local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
                render.SetMaterial(sprite)
                render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
                 
            elseif (v.type == "Quad" and v.draw_func) then
                 
                local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
                ang:RotateAroundAxis(ang:Up(), v.angle.y)
                ang:RotateAroundAxis(ang:Right(), v.angle.p)
                ang:RotateAroundAxis(ang:Forward(), v.angle.r)
                 
                cam.Start3D2D(drawpos, ang, v.size)
                    v.draw_func( self )
                cam.End3D2D()
 
            end
             
        end
         
    end
 
    function SWEP:CreateModels( tab )
 
        if (!tab) then return end
 
        // Create the clientside models here because Garry says we can't do it in the render hook
        for k, v in pairs( tab ) do
            if (v.type == "Model" and v.model and v.model != "" and (!ValidEntity(v.modelEnt) or v.createdModel != v.model) and
                    string.find(v.model, ".mdl") and file.Exists ("../"..v.model) ) then
                 
                v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
                if (ValidEntity(v.modelEnt)) then
                    v.modelEnt:SetPos(self:GetPos())
                    v.modelEnt:SetAngles(self:GetAngles())
                    v.modelEnt:SetParent(self)
                    v.modelEnt:SetNoDraw(true)
                    v.createdModel = v.model
                else
                    v.modelEnt = nil
                end
                 
            elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite) 
                and file.Exists ("../materials/"..v.sprite..".vmt")) then
                 
                local name = v.sprite.."-"
                local params = { ["$basetexture"] = v.sprite }
                // make sure we create a unique name based on the selected options
                local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
                for i, j in pairs( tocheck ) do
                    if (v[j]) then
                        params["$"..j] = 1
                        name = name.."1"
                    else
                        name = name.."0"
                    end
                end
 
                v.createdSprite = v.sprite
                v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)
                 
            end
        end
         
    end
 
    function SWEP:RemoveModels()
        if (self.VElements) then
            for k, v in pairs( self.VElements ) do
                if (ValidEntity( v.modelEnt )) then v.modelEnt:Remove() end
            end
        end
        if (self.WElements) then
            for k, v in pairs( self.WElements ) do
                if (ValidEntity( v.modelEnt )) then v.modelEnt:Remove() end
            end
        end
        self.VElements = nil
        self.WElements = nil
    end
 
end