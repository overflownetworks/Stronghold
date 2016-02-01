--[[---------------------------------------------------]]--
--[[--Welcome to RoaringCow's Stronghold weapon base!--]]--
--[[----I realize it's a fuckheap but I don't care.----]]--
--[[---------------------------------------------------]]--
if (SERVER) then
	AddCSLuaFile("shared.lua")
	AddCSLuaFile("cl_init.lua")
	SWEP.Weight 		= 5
elseif (CLIENT) then
	SWEP.DrawAmmo			= true		
	SWEP.DrawCrosshair		= false			
	SWEP.ViewModelFlip		= true		
	SWEP.CSMuzzleFlashes	= true
	SWEP.ViewModelFOV		= 60
	SWEP.Slot 				= 0
	SWEP.SlotPos			= 0
	CreateClientConVar( "sh_fx_detailedimpacteffects", "1", true, false )
	CreateClientConVar( "sh_fx_smokeyimpacteffects", "1", true, false )
	CreateClientConVar( "sh_fx_impacteffects", "1", true, false )
	CreateClientConVar( "sh_fx_muzzleeffects", "1", true, false )
	CreateClientConVar( "sh_fx_explosiveeffects", "1", true, false )
	CreateClientConVar( "sh_fx_dynamicweldlight", "1", true, false )
	CreateClientConVar( "sh_hitsound", "1", true, false )
	CreateClientConVar( "sh_hitindicator", "1", true, false )

	-- This is the font that's used to draw the death icons.
	--surface.CreateFont("csd", ScreenScale(30), 500, true, true, "CSKillIcons")

	-- This is the font that's used to draw the select icons.
	surface.CreateFont("csd", ScreenScale(60), 500, true, true, "CSKillIcons")
	
end
SWEP.HoldType				= "ar2"
SWEP.MuzzleEffect			= "rifle" 
SWEP.MuzzleAttachment		= "1" 
SWEP.ShellEjectAttachment	= "2"
SWEP.EjectDelay				= 0
SWEP.Category				= "STRONGHOLD"
SWEP.DrawWeaponInfoBox  	= true
SWEP.Author 				= "RoaringCow"
SWEP.Contact 				= ""
SWEP.Purpose 				= ""
SWEP.Instructions 			= ""
SWEP.Spawnable 				= false
SWEP.AdminSpawnable 		= false
SWEP.Weight 				= 5
SWEP.AutoSwitchTo 			= false
SWEP.AutoSwitchFrom 		= false
SWEP.Primary.Sound 			= Sound("Weapon_AK47.Single")
SWEP.Primary.Recoil 		= 1
SWEP.Primary.Damage 		= 0
SWEP.Primary.NumShots 		= 0
SWEP.Primary.Cone 			= 0.0005
SWEP.Primary.ClipSize 		= 0
SWEP.Primary.Delay 			= 0
SWEP.Primary.DefaultClip 	= 0
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= "none"
SWEP.Secondary.Ammo 		= "none"
SWEP.bInIronSight 			= false
SWEP.Recoil 				= 0
SWEP.RMod					= 1		--Emulates recoil animation in ironsight if set to 1.
SWEP.SlideLocks				= 0		--Plays the first frame of the reloading animation on the last shot. For pistols.
SWEP.FireSelect				= 1		--Set to 1 if the weapon has a select fire option.
SWEP.Look					= 1		--View model will appear to stay relative to your body while sprinting when you look up/down. 
SWEP.CycleSpeed				= 1		--How fast weapons should play the fire animation. 1 is normal speed.
SWEP.IronCycleSpeed			= 10	--How fast weapons without RMod should fire in ironsight.
SWEP.RKick					= 10	--How much recoil affects rearward travel for RMod.
SWEP.RRise					= 0.02	--Correct for rise during recoil for RMod.
SWEP.RSlide					= 0		--Correct for left/right movement during recoil for RMod.
SWEP.LastAmmoCount 			= 0	
SWEP.FreeFloatHair			= 0		--Set to 1 if the weapon should have a crosshair for ironsight.
SWEP.ModelRunAnglePreset	= 0		--Preset run angles for rifles/pistols/retardedbackwardsmodeledbullshitbecausewhoevermodeledthecssweaponsisfuckingretardedandshoulddie.
SWEP.SMG					= false		--Is the weapon an SMG? Affects hip fire spread and recoil.
SWEP.Sniper					= false		--Is the weapon a Sniper? Affects hip fire spread and recoil.
SWEP.Acog					= false		--Does the weapon use and Acog? Determines 
SWEP.MSniper				= false		--Is the weapon a MSniper(automatic sniper)? Affects hip fire spread and recoil.
SWEP.Reloading				= false		--Is the weapon reloading?
SWEP.InitialScope 			= false		--Has the weapon scoped yet? Used to prevent the scope fade in from playing when you haven't pressed the zoom button.
SWEP.IronSightsPos 			= Vector (0, 0.1, 0)
SWEP.IronSightsAng 			= Vector (0, 0, 0)
SWEP.Zoom					= 60
local IRONSIGHT_TIME = 0.15
local DashDelta = 0



SWEP.HitImpact = function( attacker, tr, dmginfo )
--Stat tracking, disregard.
	if IsValid( tr.Entity ) and tr.Entity:IsPlayer() then
		attacker:AddStatistic( "BulletsHit", 1 )
	end
	
--Damage people in vehicles.
	if (SERVER) and IsValid( tr.Entity ) and tr.Entity:GetClass() == "prop_vehicle_prisoner_pod" and IsValid( tr.Entity:GetDriver() ) then
		local driver = tr.Entity:GetDriver()
		driver:TakeDamage( dmginfo:GetDamage(), dmginfo:GetAttacker(), dmginfo:GetInflictor() )
	end
	
--Position	
	local hit = EffectData()
		hit:SetOrigin(tr.HitPos)
		hit:SetNormal( (tr.StartPos-tr.HitPos):Normalize() )
		hit:SetScale(20)
		hit:SetEntity( tr.Entity )
--Dirt
	--if tr.MatType == MAT_DIRT then
	--return end
--Ragdolls
	if tr.Entity:GetClass() == ( "prop_ragdoll" ) then
			util.Effect("bloodspray", hit)
			--util.Effect("bloodimpact", hit)
--The Living
		elseif tr.Entity:IsPlayer() or tr.Entity:IsNPC() then
			util.Effect("bloodspray", hit)
--Glass			
		elseif tr.MatType == MAT_GLASS then
			util.Effect("GlassImpact", hit)	
--Metal \m/
		elseif tr.MatType == MAT_METAL then
			util.Effect("hitmetal", hit)
--Plastic			
		elseif tr.MatType == MAT_PLASTIC then
			util.Effect("impactplastic", hit)
--World not skybox
		elseif tr.HitWorld and !tr.HitSky  then
			hit:SetNormal(tr.HitNormal)
			util.Effect("impactdust", hit)
	end
end

function SWEP:RunAnglePreset() --Preset run angles for rifles/pistols/retardedbackwardsmodeledbullshitbecausewhoevermodeledthecssweaponsisfuckingretardedandshoulddie.
	if self.ModelRunAnglePreset == 0 then
		self.RunArmAngle  = Angle( 2.5, 50, 6 )
		self.RunArmOffset = Vector( 1, -0.1, -5 )
	end
	if self.ModelRunAnglePreset == 1 then
		self.RunArmAngle  = Angle( -10, -50, -6 )
		self.RunArmOffset = Vector( 1, 2, 5 )
	end
	if self.ModelRunAnglePreset == 2 then
		self.RunArmAngle  = Angle( 10, 60, 5 )
		self.RunArmOffset = Vector( 3, 0, -10 )
	end
	if self.ModelRunAnglePreset == 3 then
		self.RunArmAngle  = Angle( -20, 5, 2 )
		self.RunArmOffset = Vector( -2, 0, 3 )
	end
	if self.ModelRunAnglePreset == 4 then
		self.RunArmAngle  = Angle( -20, 0, 0 )
		self.RunArmOffset = Vector( 0, 0, 0 )
	end
end

function SWEP:Initialize()
	self:RunAnglePreset()
	self:SetWeaponHoldType( self.HoldType ) 	-- 3rd person hold type
	self.Reloadaftershoot = 0 	-- Can't reload when firing
	self.LastLoad = 0
	self.Loaded = true
	self.Zoom = self.Sniper and !self.MSniper and 30 or self.Sniper and self.MSniper and 50 or self.Zoom
end

function SWEP:ZoomScale() -- Sets the zoom scale of different weapon types.
	local WepZooms = self.Sniper and !self.MSniper and 30 or self.Sniper and self.MSniper and 50 or 60
	if self.UseScope and self:GetIronsights() and !self.Owner:KeyDownLast( IN_USE ) and self.Owner:KeyDown( IN_USE ) then
		if !self.Zoomed then
			self.Zoom = self.Zoom * 0.6
			if SERVER then self.Owner:SetFOV( self.Zoom, 0.2 ) end
			self.Zoomed = true
		else
			self.Zoom = WepZooms
			if SERVER  then self.Owner:SetFOV( self.Zoom, 0.2 ) end
			self.Zoomed = false
		end
	end
end

function SWEP:IronSight()
	self:ZoomScale()
	if self.Sprinting or self.Reloading then 
		if self:GetIronsights() then self.Owner:SetFOV( 0, 0.2 ) end
		self:SetIronsights( false, self.Owner )
	return end
		if self.Owner:KeyDown(IN_ATTACK2) and !self:GetIronsights() and !self.Owner:KeyDown(IN_USE) then	
			if SERVER then self.Owner:SetFOV( self.Zoom, 0.2 ) end
			if self.RMod == 1 then 
				self.Weapon:SendWeaponAnim( ACT_VM_IDLE )
				self.Owner:GetViewModel():SetPlaybackRate( 0 )end
			self:SetIronsights( true, self.Owner )
		elseif !self.Owner:KeyDown(IN_ATTACK2) and self:GetIronsights() then
			if SERVER then self.Owner:SetFOV( 0, 0.2 ) end
			self:SetIronsights( false, self.Owner )	
		end
end

function SWEP:AdjustMouseSensitivity( )
	if self.Owner:KeyDown(IN_ATTACK2) then
		return self.Owner:GetFOV( ) / self.Owner:GetInfo( "fov_desired" )
	end
end

function SWEP:Think()
	self:FireMode()
	self:IronSight()
	self.Sprinting = self.Owner:KeyDown( IN_FORWARD| IN_BACK | IN_MOVELEFT | IN_MOVERIGHT ) and self.Owner:KeyDown( IN_SPEED )
	self.Walking = self.Owner:KeyDown( IN_FORWARD| IN_BACK | IN_MOVELEFT | IN_MOVERIGHT )
	if self.Primary.Ammo == "buckshot" and self.Weapon:Clip1() < self.Primary.ClipSize then
		self.Loaded = false
	end
	if self.Reloading then
		self:Reload()
	end
	if self.Reloading and self.Owner:KeyPressed(IN_ATTACK) and self.Primary.Ammo == "buckshot" then
		self.FinishLoad = true
		self.LastLoad = CurTime() + 0.3
	end
end

function SWEP:Reload()
	
	if self.Primary.ClipSize > self.Owner:GetAmmoCount(self.Primary.Ammo) and (self.Owner:GetAmmoCount(self.Primary.Ammo) + self.Weapon:Clip1()) == self.Weapon:Clip1() then
	return end
	
	if self.Reloadaftershoot > CurTime() then 
	return end 
	
	if self.FinishLoad then	--Finished loading shotgun?
		self.Weapon:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
		self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)
		self.Reloading = false
		self.FinishLoad = false
	return end
		
	if self.Primary.Ammo == "buckshot" then
		if !self.Reloading and !self.Loaded then
			self.Weapon:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START)
			self.LastLoad = CurTime() + 0.3
			self.Reloading = true
		end
		if self.Reloading and CurTime() >= self.LastLoad and self.Weapon:Clip1() == self.Primary.ClipSize - 1 then
			self.Weapon:SendWeaponAnim(ACT_VM_RELOAD)
			self.Weapon:SetClip1(self.Weapon:Clip1() + 1)
			self.LastLoad = CurTime() + 0.3
		end
		if self.Reloading and CurTime() >= self.LastLoad and self.Weapon:Clip1() < self.Primary.ClipSize - 1 then
			self.Weapon:SendWeaponAnim(ACT_VM_RELOAD)
			self.Weapon:SetClip1(self.Weapon:Clip1() + 1)
			self.LastLoad = CurTime() + 0.5
		end
		if self.Reloading and CurTime() >= self.LastLoad and self.Weapon:Clip1() == self.Primary.ClipSize and !self.Loaded then
			self.FinishLoad = true
			self.Loaded = true
		end
	end
	
	if self.Weapon:Clip1() == self.Primary.ClipSize then 
	return end
	
	if self.Primary.Ammo == "buckshot" then return end
	
	self.Weapon:DefaultReload(ACT_VM_RELOAD)
	if self.GetIronsights then self.Owner:SetFOV( 0, 0.2 ) end
		self:SetIronsights( false )
		self.Owner:AddStatistic( "Reloads", 1 )
	
	if self.PrintName == "SIG-SAUER P228" then
		self.IronSightsPos = Vector (4.6978, 0, 2.8949)
		self.IronSightsAng = Vector (-0.585, -0.6464, 0)
	end

end

function SWEP:Deploy()
	if !self.Owner or !self.Owner:Alive() then 
	return false end

	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	self.Reloadaftershoot = CurTime() + 1
	self:SetIronsights( false )
	self.Weapon:SetNextPrimaryFire( CurTime() + 1 )
	
	if self.PrintName == "SIG-SAUER P228" then
		self.IronSightsPos = Vector (4.7705, 0, 2.9103)
		self.IronSightsAng = Vector (-0.5696, 0.1092, 0)
	end
	
	return true
end

function SWEP:PrimaryAttack()
	if self.Sprinting or self.Reloading then 
	return end

	if not self:CanPrimaryAttack() or self.Owner:WaterLevel() > 2 then return end
	self.Reloadaftershoot = CurTime() + self.Primary.Delay
	self.Weapon:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self.Weapon:EmitSound(self.Primary.Sound)
	self:RecoilPower()
	self:TakePrimaryAmmo(1)

	if ((SinglePlayer() and SERVER) or CLIENT) then
		self.Weapon:SetNetworkedFloat("LastShootTime", CurTime())
	end
end 

function SWEP:CanPrimaryAttack()
	if ( self.Weapon:Clip1() <= 0 ) and self.Primary.ClipSize > -1 or self.Reloading then
		self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)
		self.Weapon:EmitSound("Weapons/ClipEmpty_Pistol.wav")
		return false
	end
	return true
end
 
function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	draw.SimpleText( self.IconLetter, "CSKillIcons", x + wide*0.5, y + tall*0.3, Color( 255, 220, 0, 255 ), TEXT_ALIGN_CENTER )
	self:PrintWeaponInfo( x + wide + 20, y + tall * 0.95, alpha )
end

function SWEP:GetViewModelPosition( pos, ang )
	if (not self.IronSightsPos) then return pos, ang 
	end
	local scale = math.Clamp((CurTime() - self.Recoil)*20, -5, 1 )
	local scale2 = math.Clamp((CurTime() - self.Recoil)*10, -0, 2 )

	local bIron = self.bInIronSight
	if self.Owner:KeyDown( IN_FORWARD| IN_BACK | IN_MOVELEFT | IN_MOVERIGHT ) and self.Owner:KeyDown( IN_SPEED ) then
		if (!self.DashStartTime) then
			self.DashStartTime = CurTime()
		end
		DashDelta = math.Clamp( ((CurTime() - self.DashStartTime) / 0.15) ^ 1.2, 0, 1 )
	else
		if ( self.DashStartTime ) then
			self.DashEndTime = CurTime()
			self.DashStartTime = nil
		end
		if ( self.DashEndTime ) then
			DashDelta = math.Clamp( ((CurTime() - self.DashEndTime) / 0.1) ^ 1.2, 0, 1 )
			DashDelta = 1 - DashDelta
			if ( DashDelta == 0 ) then self.DashEndTime = nil end
		else
			DashDelta = 0
		end
	end

	if ( DashDelta != 0 ) then
		local Down = ang:Up() * -1
		local Right = ang:Right() 
		local Forward = ang:Forward() *2
		pos = pos + ( Down * (self.RunArmOffset.x) + Forward * (self.RunArmOffset.y) + Right * (self.RunArmOffset.z) ) * DashDelta
		local INERT = self.Owner:GetVelocity().z*0.1
		local RUNPOS = math.Clamp(self.Owner:GetAimVector().z*-10, -3,0.3) 
		local RUNPOS2 = math.Clamp(self.Owner:GetAimVector().z*-0.3, -1,0.3) 
		local NEGRUNPOS = math.Clamp(self.Owner:GetAimVector().z*4, -2,2) --ErrorNoHalt(NEGRUNPOS*self.RunArmAngle.pitch)
		local NEGRUNPOS2 = math.Clamp(self.Owner:GetAimVector().z*2, -0.5,2)
		
		if self.bInScope or self.Look == 0 then
			ang:RotateAroundAxis( Right,self.RunArmAngle.pitch  * DashDelta)
		elseif self.ModelRunAnglePreset	== 3 then
			ang:RotateAroundAxis( Right,self.RunArmAngle.pitch * NEGRUNPOS2 )
		elseif self.ModelRunAnglePreset == 2 then
			ang:RotateAroundAxis( Right,self.RunArmAngle.yaw * RUNPOS2 )
		elseif self.ModelRunAnglePreset	== 1 then
			ang:RotateAroundAxis( Right,self.RunArmAngle.pitch * NEGRUNPOS )--ErrorNoHalt(self.RunArmAngle.pitch)
		elseif self.ModelRunAnglePreset	== 0 then
			ang:RotateAroundAxis( Right,self.RunArmAngle.pitch * RUNPOS )
		end
		ang:RotateAroundAxis( Down,  self.RunArmAngle.yaw   * DashDelta )
		ang:RotateAroundAxis( Forward,  self.RunArmAngle.roll  * DashDelta ) 
		ang:RotateAroundAxis(Right, self.RunArmAngle.pitch * DashDelta)
	end
	
	if (bIron != self.bLastIron) then
		self.bLastIron = bIron
		self.fIronTime = CurTime()
	end
	
	self.BobScale =  0
	if !self.Owner:KeyDown(IN_ATTACK2) then self.SwayScale = 1 else self.SwayScale = 0.3 end
	local fIronTime = self.fIronTime or 0
	if (not bIron and fIronTime < CurTime() - IRONSIGHT_TIME) then
		return pos, ang
	end
	local Mul = 1.0
	if (fIronTime > CurTime() - IRONSIGHT_TIME) then
		Mul = math.Clamp((CurTime() - fIronTime) / IRONSIGHT_TIME, 0, 1)
		if not bIron then Mul = 1 - Mul end
	end

	local Offset= self.IronSightsPos
	
	if (self.IronSightsAng) then
		ang = ang 
		ang:RotateAroundAxis(ang:Right(), 		self.IronSightsAng.x * Mul)
		ang:RotateAroundAxis(ang:Up(), 		self.IronSightsAng.y * Mul )
		ang:RotateAroundAxis(ang:Forward(), 	self.IronSightsAng.z * Mul )
	end

	local Right 	= ang:Right()
	local Up 		= ang:Up()
	local Forward 	= ang:Forward()
	
	if self.RMod == 1 or self.RMod == 0 and self.Weapon:Clip1() == 0 and self.Primary.Ammo != "buckshot" then
		pos = pos + Offset.x * Right * (Mul+(scale*self.RSlide)-self.RSlide)
		pos = pos + Offset.y * Forward * ((Mul+(scale*self.RKick)-self.RKick)+scale2)
		pos = pos + Offset.z * Up * ((Mul+(scale*-self.RRise))+self.RRise)
	elseif self.RMod == 0 and self.Weapon:Clip1() != 0 then
		pos = pos + Offset.x * Right * Mul
		pos = pos + Offset.y * Forward * Mul
		pos = pos + Offset.z * Up * Mul
	end
 
	return pos, ang	
end


function SWEP:SetIronsights( b )
	if b and !self.bInIronSight then self.Owner:AddStatistic( "IronSights", 1 ) end
	self.bInIronSight = b
end

function SWEP:GetIronsights()
	return self.bInIronSight
end

function SWEP:RecoilPower()
	self.Owner:ViewPunchReset()

	local Stance = self.Owner:IsOnGround() and self.Owner:Crouching() and 10 -- Crouching
	or !self.Sprinting and self.Owner:IsOnGround() and 15 --Standing
	or self.Walking and self.Owner:IsOnGround() and 20 --Walking
	or !self.Owner:IsOnGround() and 25  --Flying
	or self.Primary.Ammo == "buckshot" and 0 --Shotguns not affected

	local WepType = ( self.Sniper && 8 || self.SMG && 2 || self.Pistol && 2 || self.Primary.Ammo == "buckshot" && 0 || 1.6)
	local Shotgun = self.Primary.Ammo == "buckshot" and self.Primary.Cone or 0

	if self:GetIronsights() then
		self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil * Stance * 0.1, self.Primary.NumShots, self.Primary.Cone) --Ironsight
		self.Owner:ViewPunch(Angle(math.Rand(-0.1,-0.01)))			
	else
		self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil * 0, self.Primary.NumShots, self.Primary.Cone*self.Primary.Recoil * Stance * WepType + Shotgun) --Hipfire
		self.Owner:ViewPunch(Angle(math.Rand(-0.25,0.25),math.Rand(-0.25,0.25),math.Rand(-0.25,0.25)))
	end
end

function SWEP:MacShoot()
		local Animation = self.Owner:GetViewModel()
		Animation:SetSequence(Animation:LookupSequence("mac10_fire2"))
end

function SWEP:CSShootBullet(dmg, recoil, numbul, cone)
	if self.Sprinting or self.Reloading then return end
	
	numbul 		= numbul or 1
	cone 			= cone or 0.01
	local bullet 	= {}
	bullet.Num  	= numbul
	bullet.Src 		= self.Owner:GetShootPos()  -- Source
	bullet.Dir 		= self.Owner:GetAimVector() -- Dir of bullet
	bullet.Spread 	= Vector(cone, cone, 0)     -- Aim Cone
	bullet.Tracer 	= 0   						-- Show a tracer on every x bullets
	bullet.Force 	= 0.1 * dmg     			-- Amount of force to give to phys objects
	bullet.Damage 	= dmg						-- Amount of damage to give to the bullets
	bullet.Callback = self.HitImpact
	
	self.Owner:AddStatistic( "BulletsFired", numbul )

	self.Owner:FireBullets(bullet)					-- Fire the bullets
	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	
	if self:GetIronsights() and self.RMod == 0 then
		self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		self.Owner:GetViewModel():SetPlaybackRate( self.IronCycleSpeed )
	end
		if !self:GetIronsights() or self.Sniper then
			self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
			self.Owner:GetViewModel():SetPlaybackRate( self.CycleSpeed )

	end
	--Setting new ironsight angles because of retardedly animated models. Apparently valve employs animators that have never heard of shift+dragging keyframes.
	if self.PrintName == "SIG-SAUER P228" then
		self.IronSightsPos = Vector (4.7648, -0.0028, 2.9876)
		self.IronSightsAng = Vector (-0.6967, 0.0241, -0.0391)
	end
	
	if self.Weapon:Clip1() == 1 and self.SlideLocks == 1 then
		self:SendWeaponAnim(ACT_VM_RELOAD)
		self.Owner:GetViewModel():SetPlaybackRate( 0 )
	end
	
	local fx = EffectData()
	fx:SetEntity(self.Weapon)
	fx:SetOrigin(self.Owner:GetShootPos())
	fx:SetNormal(self.Owner:GetAimVector())
	fx:SetAttachment(self.MuzzleAttachment)
		util.Effect(self.MuzzleEffect,fx)	-- Additional muzzle effects
	
	if CLIENT and self.Owner:KeyDown(IN_ATTACK2) then
	local fx = EffectData()
	fx:SetEntity(self.Owner)
	fx:SetOrigin(self.Owner:EyePos())
	fx:SetNormal(self.Owner:GetAimVector())
		util.Effect(self.MuzzleEffect,fx)	-- Additional muzzle effects
	end
	

	if ( (SinglePlayer() && SERVER) || ( !SinglePlayer() && CLIENT && IsFirstTimePredicted() ) ) then
		local eyeang = self.Owner:EyeAngles()
		eyeang.pitch = eyeang.pitch - math.Rand( recoil * 0.5, recoil * 1 )
		eyeang.yaw = eyeang.yaw + math.Rand( recoil * -0.5, recoil * 0.5 ) 
		self.Owner:SetEyeAngles(eyeang)
		
	end
	self.Recoil = CurTime()
end

function SWEP:FireMode()
if self.FireSelect == 0 then return end
	if SERVER then
		if self.Primary.Automatic==false and self.Owner:KeyDown(IN_USE) and self.Owner:KeyPressed(IN_ATTACK2) then
			self:SetNetworkedBool( "FireMode", true )
			self.Primary.Automatic = true
			self.Owner:EmitSound( "Weapon_AR2.Empty" )
		elseif self.Primary.Automatic==true and self.Owner:KeyDown(IN_USE) and self.Owner:KeyPressed(IN_ATTACK2) then
			self:SetNetworkedBool( "FireMode", false)
			self.Primary.Automatic = false
			self.Owner:EmitSound( "Weapon_AR2.Empty" )
		end
	elseif CLIENT then
		self.Primary.Automatic = self:GetNetworkedBool( "FireMode", true )
	end
end

function SWEP:Crosshair()
if self.FreeFloatHair == 0 or !self:GetIronsights() then 
return end


local IsSniper = ( self.Sniper and 2 or 1)

local Stance = self.Primary.Cone * 1300

		local x = ScrW() / 2.0
		local y = ScrH() / 2.0
		surface.SetDrawColor( 255, 255, 255, 100 )--white
		surface.DrawRect( x-(Stance*IsSniper)-21,		y-1, 15, 1) --left
		surface.DrawRect( x+(Stance*IsSniper)+4,		y-1, 15, 1) --right
		surface.DrawRect( x-2,				y+(Stance*IsSniper)+2, 2, 10 ) --down

		surface.SetDrawColor( 50, 50, 50, 150 )--grey
		surface.DrawRect( x-(Stance*IsSniper)-6,		y-1, 4, 1) --left
		surface.DrawRect( x+(Stance*IsSniper),		y-1, 4, 1) --right
		surface.DrawRect( x-2,			y+(Stance*IsSniper), 2, 2) --down
	--ErrorNoHalt(Stance)	
end

function SWEP:CanSecondaryAttack()
	return false
end

function SWEP.BulletCallback()
	return { damage = true, effects = false }
end