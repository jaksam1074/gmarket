local Seller = Seller or nil
local SellerEnt
net.Receive("gmarket_OpenSeller", function()
	if( Seller!=nil ) then
		Seller:Remove()
	end
	
	SellerEnt = net.ReadEntity()
	Seller = vgui.Create("GSeller")
end)

local SELLER = {}

function SELLER:Init()
	self:SetSize( ScrW() * 0.300, ScrH() * 0.200 )
	self:Center()
	self:SetVisible( true )
	self:ShowCloseButton( false )
	self:MakePopup()
	self:SetTitle("")
	self:SetDraggable( false )
	
	local MailBoxButton = vgui.Create( "DButton", self )
	MailBoxButton:SetFont("GMarketBoldFont")
	MailBoxButton:SetText( lang["MailBox"] .. " ($" .. cfg.MailBoxPrice .. ")" )
	MailBoxButton:SetTextColor( Color(0,0,0,0) ) -- Invisible text, it will be drawed later
	MailBoxButton:SizeToContents()
	MailBoxButton:SetPos( self:GetWide()/2+5, self:GetTall()/3-MailBoxButton:GetTall()/2 )
	MailBoxButton.Paint   = function(self, w, h)
		surface.SetDrawColor( 241, 196, 15 )
		surface.DrawRect( 0, 0, w, h )
		surface.SetDrawColor( 255, 255, 255 )
		surface.DrawOutlinedRect( 0, 0, w, h )
		local txt = MailBoxButton:GetText() surface.SetFont( MailBoxButton:GetFont() ) local w_txt, h_txt = surface.GetTextSize( txt )
		draw.SimpleText( txt, MailBoxButton:GetFont(), w/2, h/2-h_txt/2, Color(44, 62, 80) , TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
	end
	MailBoxButton.DoClick = function()
		net.Start("gmarket_BuyMailBox")
			net.WriteEntity(SellerEnt)
		net.SendToServer()
		self:Remove()
	end
	
	local GTabletButton = vgui.Create( "DButton", self )
	GTabletButton:SetFont("GMarketBoldFont")
	GTabletButton:SetText( "GTablet ($" .. cfg.GTabletPrice .. ")" )
	GTabletButton:SetTextColor( Color(0,0,0,0) ) -- Invisible text, it will be drawed later
	GTabletButton:SizeToContents()
	GTabletButton:SetPos( self:GetWide()/2-5-GTabletButton:GetWide(), self:GetTall()/3-GTabletButton:GetTall()/2 )
	GTabletButton.Paint   = function(self, w, h)
		surface.SetDrawColor( 241, 196, 15 )
		surface.DrawRect( 0, 0, w, h )
		surface.SetDrawColor( 255, 255, 255 )
		surface.DrawOutlinedRect( 0, 0, w, h )
		local txt = GTabletButton:GetText() surface.SetFont( GTabletButton:GetFont() ) local w_txt, h_txt = surface.GetTextSize( txt )
		draw.SimpleText( txt, GTabletButton:GetFont(), w/2, h/2-h_txt/2, Color(44, 62, 80) , TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
	end
	GTabletButton.DoClick = function()
		net.Start("gmarket_BuyGTablet")
		net.SendToServer()
		self:Remove()
	end
	
	local CloseButton = vgui.Create( "DButton", self )
	CloseButton:SetFont("GMarketBoldFont")
	CloseButton:SetText( lang["Nothing"] )
	CloseButton:SetTextColor( Color(0,0,0,0) ) -- Invisible text, it will be drawed later
	CloseButton:SizeToContents()
	CloseButton:SetPos( self:GetWide()/2-CloseButton:GetWide()/2, self:GetTall()-CloseButton:GetTall()-5 )
	CloseButton.Paint   = function(self, w, h)
		surface.SetDrawColor( 229, 80, 57 )
		surface.DrawRect( 0, 0, w, h )
		surface.SetDrawColor( 255, 255, 255 )
		surface.DrawOutlinedRect( 0, 0, w, h )
		local txt = CloseButton:GetText() surface.SetFont( CloseButton:GetFont() ) local w_txt, h_txt = surface.GetTextSize( txt )
		draw.SimpleText( txt, CloseButton:GetFont(), w/2, h/2-h_txt/2, Color(44, 62, 80) , TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
	end
	CloseButton.DoClick = function()
		self:Remove()
	end
end

function SELLER:Paint( w, h )
	surface.SetDrawColor( 47, 54, 64 )
	surface.DrawRect( 0, 0, w, h )
	draw.SimpleText( lang["Hi"], "GMarketBoldFont", w/2, 5, Color(250, 211, 144) , TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
end

derma.DefineControl( "GSeller", "Opens Seller menu", SELLER, "DFrame")