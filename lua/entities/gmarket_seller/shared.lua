ENT.Type = "ai"
ENT.Base = "base_ai"

ENT.PrintName = "Seller"
ENT.Category = "GMarket"

ENT.Spawnable = true
ENT.AutomaticFrameAdvance = true

function ENT:SetAutomaticFrameAdvance( bUsingAnim )
	self.AutomaticFrameAdvance = bUsingAnim
end