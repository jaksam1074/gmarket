local Mailbox = Mailbox or nil
local MailBoxEntity = MailBoxEntity or nil
local ItemsList = ItemsList or nil

net.Receive("gmarket_OpenMailBox", function()
	if(Mailbox!=nil) then
		Mailbox:Remove()
	end
	MailBoxEntity = net.ReadEntity()
	ItemsList = net.ReadTable()
	Mailbox = vgui.Create("GMailbox")
	
end)

local SELLBOX = {}

function SELLBOX:Init()
	
	local CanBeSoldItems = {}
	for _, ent in pairs( ents.FindInSphere( MailBoxEntity:GetPos(), 70 ) ) do -- This loop checks if entities near the actual mailbox can be sold or not
		for k, Item in pairs(cfg.ItemsCanBeSold) do
			if(Item.ItemClass == ent:GetClass() ) then
				table.insert(CanBeSoldItems, {ItemContent = Item, ItemEntity = ent})
			end
		end
	end
	
	self:SetSize( ScrW() * 0.500, ScrH() * 0.600 ) -- 800, 600
	self:Center()
	self:SetVisible( true )
	self:ShowCloseButton( true )
	self:MakePopup()
	self:SetTitle("")
	self:SetDraggable( false )
	
	local ItemPanel = ItemPanel or nil
	
	local ItemToSellComboBox = vgui.Create( "DComboBox", self )
	ItemToSellComboBox:SetSize( ScrW() * 0.078, ScrH() * 0.025 )
	ItemToSellComboBox:SetPos( self:GetWide()/2-ItemToSellComboBox:GetWide()/2, self:GetTall()/6 )
	ItemToSellComboBox:SetFont("GMarketBoldFont")
	ItemToSellComboBox:SetValue( lang["Items"] )
	ItemToSellComboBox.OnSelect = function( panel, index, value )
	
		if(ItemPanel!=nil) then
			ItemPanel:Remove()
		end
		
		local Item = CanBeSoldItems[index]
		
		ItemPanel = vgui.Create( "DPanel",self )
		ItemPanel:SetSize( self:GetWide()-100, self:GetTall()-150 )
		ItemPanel:SetPos( self:GetWide()/2-ItemPanel:GetWide()/2, self:GetTall()/5+10 )
		ItemPanel.Paint = function(self, w, h)
			local txt = lang["Item Name"] .. Item.ItemContent.ItemName surface.SetFont( "GMarketMediumFont" ) local name_w_txt, name_h_txt = surface.GetTextSize( txt )
			draw.SimpleText( txt, "GMarketMediumFont", w/2, 20, Color(245, 246, 250) , TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP ) -- Item Name
			local txt = lang["Item Category"] .. Item.ItemContent.ItemCategory surface.SetFont( "GMarketMediumFont" ) local ctg_w_txt, ctg_h_txt = surface.GetTextSize( txt )
			draw.SimpleText( txt, "GMarketMediumFont", w/2, name_h_txt + 40, Color(245, 246, 250) , TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP ) -- Item Category
			local txt = lang["Item Class"] .. Item.ItemContent.ItemClass surface.SetFont( "GMarketMediumFont" ) local class_w_txt, class_h_txt = surface.GetTextSize( txt )
			draw.SimpleText( txt, "GMarketMediumFont", w/2, name_h_txt + ctg_h_txt + 60, Color(245, 246, 250) , TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP ) -- Item Class
			draw.SimpleText( lang["Seller ID"] .. LocalPlayer():SteamID64(), "GMarketMediumFont", w/2, name_h_txt + ctg_h_txt + class_h_txt + 80, Color(245, 246, 250) , TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP ) -- Seller ID
		end
		
		local priceinput = vgui.Create( "DNumberWang", self )
		priceinput:SetSize( ScrW() * 0.052, ScrH() * 0.029 )
		priceinput:SetPos( ItemPanel:GetWide()/2, ItemPanel:GetTall() + priceinput:GetTall() + 15)
		priceinput:SetFont( "GMarketMediumFont" )
		priceinput:SetDecimals( 0 )
		priceinput:SetMax( cfg.MaxPrice )
		priceinput:HideWang()
		
		local SellButton = vgui.Create( "DButton", self )
		SellButton:SetFont("GMarketMediumFont")
		SellButton:SetText( lang["Sell"] )
		SellButton:SetTextColor( Color(0,0,0,0) ) -- Invisible text, it will be drawed later
		SellButton:SizeToContents()
		SellButton:SetPos( self:GetWide()/2-SellButton:GetWide()/2, self:GetTall()-SellButton:GetTall()-5)
		SellButton.Paint = function(self, w, h)
			surface.SetDrawColor( 225, 177, 44 )
			surface.DrawRect( 0, 0, w, h )
			surface.SetDrawColor( 255, 255, 255 )
			surface.DrawOutlinedRect( 0, 0, w, h )
			local txt = lang["Sell"] local txt_w, txt_h = surface.GetTextSize( txt )
			draw.SimpleText( txt, "GMarketMediumFont", w/2, h/2-txt_h/2, Color(245, 246, 250) , TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
		end
		SellButton.DoClick = function()
			if(!LocalPlayer():Alive()) then return end
			Price = math.floor( math.Clamp( priceinput:GetValue(), 0, cfg.MaxPrice ) ) -- Sets the right price
			
			net.Start("gmarket_Sell")
				net.WriteTable(Item)
				net.WriteInt(Price,32)
			net.SendToServer()
			self:Close()
			notification.AddLegacy( "Did it!", NOTIFY_GENERIC, 2 )
			surface.PlaySound( "ambient/water/drip" .. math.random(1, 4) .. ".wav" )
		end
		
	end
	
	for k, v in pairs(CanBeSoldItems) do
		ItemToSellComboBox:AddChoice(v.ItemContent.ItemName)
	end
end

function SELLBOX:Paint(w, h)
	surface.SetDrawColor( 47, 54, 64 )
	surface.DrawRect( 0, 0, w, h )
	draw.SimpleText( lang["Sell an item"], "GMarketFont", w/2, 0, Color(245, 246, 250) , TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
end
derma.DefineControl( "GSellbox", "Opens Sellbox", SELLBOX, "DFrame")

local MAILBOX = {}

function MAILBOX:Init()
	
	self:SetSize( ScrW() * 0.500, ScrH() * 0.600 ) -- 800, 600
	self:Center()
	self:SetVisible( true )
	self:ShowCloseButton( true )
	self:MakePopup()
	self:SetTitle("")
	self:SetDraggable( false )
	
	local SellButton = vgui.Create( "DButton", self )
	SellButton:SetText( "" )
	SellButton:SetPos( 0, 0 )
	SellButton:SetSize( ScrW() * 0.104, ScrH() * 0.032 )
	SellButton.Paint   = function(self, w, h)
		surface.SetDrawColor( 241, 196, 15 )
		surface.DrawRect( 0, 0, w, h )
		surface.SetDrawColor( 255, 255, 255 )
		surface.DrawOutlinedRect( 0, 0, w, h )
		local txt = lang["Sell"] surface.SetFont( "GMarketBoldFont" ) local w_txt, h_txt = surface.GetTextSize( txt )
		draw.SimpleText( txt, "GMarketBoldFont", w/2, h/2-h_txt/2, Color(44, 62, 80) , TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
	end
	SellButton.DoClick = function()
		if(LocalPlayer():Alive()) then
			self:Remove()
			vgui.Create("GSellbox")
		else
			self:Remove()
		end
	end
	
	local ItemListPanel = vgui.Create( "DPanel", self )
	ItemListPanel:SetSize( ScrW()*0.484, ScrH()*0.555 )
	ItemListPanel:SetPos(15, SellButton:GetTall()+5)
	ItemListPanel.Paint = function(self, w, h)
		surface.SetDrawColor( Color( 255, 255, 255, 50 ) )
		surface.DrawOutlinedRect( 0, 0, w, h )
	end
	
	local ItemListScroll = vgui.Create( "DScrollPanel", ItemListPanel )
	ItemListScroll:Dock( FILL )
	for k, v in pairs(ItemsList) do
		local ItemInfo = util.JSONToTable(v.Content)
		local ItemPanel = ItemListScroll:Add( "DPanel" )
		ItemPanel:Dock( TOP )
		ItemPanel:DockMargin( 5, 5, 5, 5 )
		ItemPanel:SetSize( ItemListPanel:GetWide()-10, ItemListPanel:GetTall()/5 )
		ItemPanel.Paint = function(self, w, h)
			surface.SetDrawColor( Color( 127, 140, 141, 255 ) )
			surface.DrawOutlinedRect( 0, 0, w, h )
			draw.SimpleText( ItemInfo.ItemName, "GMarketBoldFont", w/2, 5, Color(192, 57, 43) , TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
			local txt = ItemInfo.ItemClass surface.SetFont( "GMarketBoldFont" ) local w_txt, h_txt = surface.GetTextSize( txt )
			draw.SimpleText( txt, "GMarketBoldFont", w/2, h-h_txt-5, Color(245, 246, 250, 100) , TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
			local txt = lang["Category"] .. ItemInfo.ItemCategory surface.SetFont( "GMarketBoldFont" ) local w_txt, h_txt = surface.GetTextSize( txt )
			draw.SimpleText( txt, "GMarketBoldFont", 5+w_txt/2, 5, Color(142, 68, 173) , TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
			local txt = lang["Price"] .. v.Price surface.SetFont( "GMarketBoldFont" ) local w_txt, h_txt = surface.GetTextSize( txt )
			draw.SimpleText( txt, "GMarketBoldFont", w-w_txt/2-5, 5, Color(245, 246, 250) , TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
		end
		
		local PickUpButton = vgui.Create( "DButton", ItemPanel )
		PickUpButton:SetText( "" )
		PickUpButton:SetSize( ScrW() * 0.104, ScrH() * 0.032 )
		PickUpButton:SetPos( ItemPanel:GetWide()-PickUpButton:GetWide()-20, ItemPanel:GetTall()-PickUpButton:GetTall()-5 )
		PickUpButton.Paint   = function(self, w, h)
			surface.SetDrawColor( 230, 126, 34, 180 )
			surface.DrawRect( 0, 0, w, h )
			surface.SetDrawColor( 255, 255, 255 )
			surface.DrawOutlinedRect( 0, 0, w, h )
			local txt = lang["Pick Up"] surface.SetFont( "GMarketBoldFont" ) local w_txt, h_txt = surface.GetTextSize( txt )
			draw.SimpleText( txt, "GMarketBoldFont", w/2, h/2-h_txt/2, Color(236, 240, 241) , TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
		end
		PickUpButton.DoClick = function()
			if(LocalPlayer():Alive()) then
				net.Start("gmarket_PickUp")
					net.WriteTable(v)
					net.WriteEntity(MailBoxEntity)
				net.SendToServer()
				ItemPanel:Remove()
			else
				self:Remove()
			end
		end
		
	end
	
end

function MAILBOX:Paint(w, h)
	surface.SetDrawColor( 47, 54, 64 )
	surface.DrawRect( 0, 0, w, h )
end
derma.DefineControl( "GMailbox", "Opens Mailbox", MAILBOX, "DFrame")