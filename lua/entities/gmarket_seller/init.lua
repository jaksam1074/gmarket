AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
 
	self:SetModel( "models/breen.mdl" )
	self:SetHullType( HULL_HUMAN )
	self:SetHullSizeNormal( )
	self:SetNPCState( NPC_STATE_SCRIPT )
	self:SetSolid( SOLID_BBOX )
	self:CapabilitiesAdd( CAP_ANIMATEDFACE )
	self:CapabilitiesAdd( CAP_TURN_HEAD )
	self:SetUseType( SIMPLE_USE )
	self:DropToFloor()
	self:SetMaxYawSpeed( 90 )
 
end

function ENT:OnTakeDamage()
	return false 
end

function ENT:AcceptInput( Name, Activator, Caller )
	if Name == "Use" and Caller:IsPlayer() then
		local hello = {"vo/npc/male01/hi01.wav", "vo/npc/male01/hi02.wav"}
		self:EmitSound(hello[math.random(#hello)])
		net.Start( "gmarket_OpenSeller" )
			net.WriteEntity(self)
		net.Send( Caller )
    end
end

function ENT:Draw()
	self:DrawModel()
	
	cam.Start3D2D( self:GetPos(), self:GetAngles(), 1 )
		draw.RoundedBox(0,0,0,1000,1000, Color(120,255,120))
	cam.End3D2D()
end