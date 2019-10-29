include("shared.lua")

function ENT:Draw()
	self:DrawModel()
	if self:GetPos():Distance(EyePos()) > 1500 then return end	
	
	local Pos = self:GetPos()
	local Ang = self:GetAngles()
	
	Ang:RotateAroundAxis(Ang:Up(), 90)
	cam.Start3D2D( Pos + Ang:Up() * 12 , Ang, 0.2 )
		draw.SimpleText( "GMarket", "GMarketFont", 0, -15, Color(52, 152, 219), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
	cam.End3D2D()
end