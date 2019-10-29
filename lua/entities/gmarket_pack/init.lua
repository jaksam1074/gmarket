AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_junk/cardboard_box001a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	
	local phys = self:GetPhysicsObject()
	
	if(phys:IsValid() ) then
		phys:Wake()
	end
	
	self.Life = 100
end

local function Destroy(pack, Item)
	local breaksounds = {"physics/cardboard/cardboard_box_break1.wav",
	"physics/cardboard/cardboard_box_break2.wav",
	"physics/cardboard/cardboard_box_break3.wav"}
	local RandomSound = table.Random(breaksounds)
	
	pack:EmitSound( RandomSound )
	Item:SetPos( pack:GetPos() )
	Item:SetCollisionGroup( COLLISION_GROUP_INTERACTIVE_DEBRIS )
	Item:CPPISetOwner( pack:CPPIGetOwner() )
	Item:Spawn()
	pack:Remove()
end

function ENT:Use( activator, caller )	
	local Item = ents.Create( self:GetNWString("Item") )
	if ( !IsValid( Item ) ) then return end
	Destroy(self, Item)
end

function ENT:OnTakeDamage( dmg )
	self.Life = self.Life - dmg:GetDamage()
	
	if(self.Life<=0) then
		local Item = ents.Create( self:GetNWString("Item") )
		if ( !IsValid( Item ) ) then return end
		Destroy(self, Item)
	end
end