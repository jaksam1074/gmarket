include("shared.lua")

function ENT:Draw()
	self:DrawModel()
	
	if self:GetPos():Distance(EyePos()) > 700 then return end	
	
	local Pos = self:GetPos()
	local Ang = self:GetAngles()
	
	Ang:RotateAroundAxis(Ang:Up(), 90)
	Ang:RotateAroundAxis(Ang:Right(), 0)
	Ang:RotateAroundAxis(Ang:Forward(), 90)
	cam.Start3D2D( Pos + Ang:Up() * 13, Ang, 0.05 )
		draw.SimpleText( self:CPPIGetOwner():Name() .. " MailBox", "GMarketFont", -10, -220, Color(52, 152, 219), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
	cam.End3D2D()
end