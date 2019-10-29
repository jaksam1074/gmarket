AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_lab/powerbox01a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	
	local phys = self:GetPhysicsObject()
	
	if(phys:IsValid() ) then
		phys:Wake()
	end
end
function ENT:Use( activator, ply )
	if ( IsValid( ply ) and ply:IsPlayer() )then
		if( ply == self:CPPIGetOwner() ) then
			self:EmitSound( "doors/door_metal_thin_open1.wav" )
			net.Start("gmarket_OpenMailBox")
				net.WriteEntity( self )
				net.WriteTable( ply:WithdrawList() )
			net.Send(ply)
		else
			net.Start("gmarket_Notify")
				net.WriteString( lang["This is not your mailbox"] )
			net.Send(ply)
		end
	end
end