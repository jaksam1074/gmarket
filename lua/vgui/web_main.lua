local Tablet = Tablet or nil
local Screen = Screen or nil

local ItemList = ItemList or {}

local ShoppingCart =  {}

net.Receive("gmarket_OpenWeb", function()
	if( Tablet!=nil ) then
		Tablet:Remove()
	elseif( Screen!=nil ) then
		Screen:Remove()
	end
	ItemList = net.ReadTable()
	Tablet = vgui.Create("GTablet")
	Screen = vgui.Create("GTabletScreen", Tablet)
	Tablet:MoveTo( ScrW()/2-Tablet:GetWide()/2, ScrH()/2-Tablet:GetTall()/2, 1, 0, 0.2)
end)

local TABLET = {}
local SHOPPINGCART = {}
local GMARKET = {}
local SCREEN = {}

local Twide, Ttall = ScrW()*0.667, ScrH()*0.667 -- Tablet wide and tall (1280, 720)
local Swide, Stall = ScrW()*0.625, ScrH()*0.574 -- Screen wide and tall (1200, 640)

function TABLET:Init() -- Tablet
	
	self:SetSize( Twide, Ttall )
	self:SetPos( ScrW()/2-Twide/2, ScrH() )
	self:SetVisible( true )
	self:ShowCloseButton( false )
	self:MakePopup()
	self:SetTitle("")
	self:SetDraggable( false )
	
	local HomeButton = vgui.Create( "DButton", self ) -- The button for closing the tablet
	HomeButton:SetText( "" )
	HomeButton:SetSize( ScrW()*0.036, ScrH()*0.023 ) -- 70, 25
	HomeButton:SetPos( Twide/2-HomeButton:GetWide()/2, Ttall-(Ttall-Stall)/4-HomeButton:GetTall()/2 )
	HomeButton.Paint   = function()
		draw.RoundedBox( 6, 0, 0, HomeButton:GetWide(), HomeButton:GetTall(), Color(189, 195, 199) )
	end
	HomeButton.DoClick = function()
		if(timer.Exists( "LoadingBar" ) ) then -- Removes the loading bar if exist
			timer.Remove( "LoadingBar" )
		end
		self:MoveTo( ScrW()/2-Twide/2, ScrH(), 1, 0, 0.2)
		self:SetMouseInputEnabled( false )
		self:SetKeyboardInputEnabled( false )
		self:NewAnimation( 1,0, 0.2, function() 
			self:Close()
		end)
	end
	
end

function TABLET:Paint(wide, height)
	draw.RoundedBox( 30, 0, 0, wide, height, Color(20, 20, 20) )
end
derma.DefineControl( "GTablet", "Opens GTablet", TABLET, "DFrame")

function SHOPPINGCART:Init()
	
	self:SetSize(Swide-50, Stall-65)
	self:SetPos(Swide/2-self:GetWide()/2, 50)
	
	local ScrollCart = vgui.Create( "DScrollPanel", self )
	ScrollCart:SetSize( self:GetWide(), self:GetTall()-60 )
	ScrollCart:SetPos(0,50)
	
	for k, v in pairs(ShoppingCart) do
		local ItemContents = util.JSONToTable(v.Content)
		
		local ItemToPurchase = ScrollCart:Add( "DPanel" )
		ItemToPurchase:Dock( TOP )
		ItemToPurchase:DockMargin( 20, 10, 20, 10 )
		ItemToPurchase:SetSize( self:GetWide(), self:GetTall()/5 )
		ItemToPurchase.Paint = function(self, w, h)
			surface.SetDrawColor( Color(149, 165, 166, 200) )
			surface.DrawOutlinedRect( 0, 0, w, h )
			draw.SimpleText( v.Name, "GMarketBoldFont", w/2, 5, Color(73, 111, 178), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP ) -- Item Name
			draw.SimpleText( lang["Price: $"] .. v.Price, "GMarketBoldFont", w/2, 30, Color(192, 57, 43), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP ) -- Item Price
			local txt = lang["Seller"] .. v.SteamID surface.SetFont( "GMarketLittleFont" ) local w_txt, h_txt = surface.GetTextSize( txt )
			draw.SimpleText( txt, "GMarketLittleFont", w-w_txt/2-5, 5, Color(149, 165, 166), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP ) -- Seller ID
			local txt = "ID: " .. ItemContents.ItemClass surface.SetFont( "GMarketLittleFont" ) local w_txt, h_txt = surface.GetTextSize( txt )
			draw.SimpleText( txt, "GMarketLittleFont", w-w_txt/2-5, h-h_txt-5, Color(149, 165, 166), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP ) -- Item Class
		end
		
		local RemoveFromCartButton = vgui.Create( "DButton", ItemToPurchase ) -- The button for opening gmarket
		RemoveFromCartButton:SetFont( "GMarketBoldFont" )
		RemoveFromCartButton:SetText( lang["Remove"] )
		RemoveFromCartButton:SetSize(ScrW()*0.078, ScrH()*0.032)
		RemoveFromCartButton:SetPos(5, 5)
		RemoveFromCartButton.Paint   = function(self, w, h)
			surface.SetDrawColor( 231, 76, 60 )
			surface.DrawOutlinedRect( 0, 0, w, h )
		end
		RemoveFromCartButton.DoClick = function()
			ItemToPurchase:Remove()
			table.RemoveByValue(ShoppingCart, v)
			if( table.Count( ShoppingCart )==0 ) then
				ScrollCart:Remove()
			end
		end
	end
	
	if( table.Count( ShoppingCart )>0 ) then
		local PurchaseButton = ScrollCart:Add( "DButton" )
		PurchaseButton:Dock( TOP )
		PurchaseButton:DockMargin( self:GetWide()*0.391, 10, self:GetWide()*0.391, 10 )
		PurchaseButton:SetFont( "GMarketBoldFont" )
		PurchaseButton:SetText( lang["Purchase all"] )
		PurchaseButton.Paint = function(self, w, h)
			surface.SetDrawColor( Color(241, 196, 15) )
			surface.DrawOutlinedRect( 0, 0, w, h )
		end
		PurchaseButton.DoClick = function()
			net.Start("gmarket_Buy")
				net.WriteTable(ShoppingCart)
			net.SendToServer()
			Tablet:Remove()
		end
	end
	
	local GMarketButton = vgui.Create( "DButton", self ) -- The button for opening gmarket
	GMarketButton:SetFont( "GMarketBoldFont" )
	GMarketButton:SetText( "GMarket" )
	GMarketButton:SizeToContents()
	GMarketButton:SetPos(5, 5)
	GMarketButton.Paint   = function(self, w, h)
		surface.SetDrawColor( 44, 62, 80 )
		surface.DrawOutlinedRect( 0, 0, w, h )
	end
	GMarketButton.DoClick = function()
		self:Remove()
		vgui.Create("GMarket", Screen)
	end
	
end

function SHOPPINGCART:Paint(w, h)

	local price = 0
	if(table.Count( ShoppingCart )>0 ) then
		for k, v in pairs(ShoppingCart) do
			price = price+v.Price
		end
	end
	
	surface.SetDrawColor( Color( 0, 0, 0, 180 ) )
	surface.DrawOutlinedRect( 0, 0, w, h )
	local txt = lang["Shopping Cart"] .. " $" .. price surface.SetFont( "GMarketFont" ) local txt_w, txt_h = surface.GetTextSize( txt )
	draw.SimpleText( txt, "GMarketMediumFont", w/2, 5, Color(46, 204, 113), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
	if(table.Count( ShoppingCart )==0) then
		local txt = lang["Empty"] surface.SetFont( "GMarketMediumFont" ) local txt_w, txt_h = surface.GetTextSize( txt )
		draw.SimpleText( txt, "GMarketMediumFont", w/2, h/2-txt_h, Color(211, 84, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
	end
end
vgui.Register("ShoppingCart", SHOPPINGCART)

function GMARKET:Init()

	ShoppingCart =  {}
	
	self:SetSize(Swide-50, Stall-65)
	self:SetPos(Swide/2-self:GetWide()/2, 50)
	
	local Weapons = vgui.Create( "DPanel", self ) -- Weapon category
	Weapons:SetPos( 1, 50 )
	Weapons:SetSize( self:GetWide()-2, self:GetTall()-51 )
	Weapons:SetVisible(false)
	Weapons.Paint = function(self, w, h)
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawRect( 0, 0, w, h )
	end
	
	local ScrollWeapons = vgui.Create( "DScrollPanel", Weapons ) -- Weapons Scrollbar
	ScrollWeapons:SetSize( Weapons:GetWide(), Weapons:GetTall() )
	ScrollWeapons:SetPos(0,0)
	
	local Entities = vgui.Create( "DPanel", self ) -- Weapon category
	Entities:SetPos( 1, 50 )
	Entities:SetSize( self:GetWide()-2, self:GetTall()-51 )
	Entities:SetVisible(false)
	Entities.Paint = function(self, w, h)
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawRect( 0, 0, w, h )
	end
	
	local ScrollEntities = vgui.Create( "DScrollPanel", Entities ) -- Entities Scrollbar
	ScrollEntities:SetSize( Entities:GetWide(), Entities:GetTall() )
	ScrollEntities:SetPos(0,0)
	
	local GPrime = vgui.Create( "DPanel", self ) -- GPrime Panel
	GPrime:SetPos( 1, 50 )
	GPrime:SetSize( self:GetWide()-2, self:GetTall()-51 )
	GPrime:SetVisible(false)
	GPrime.Paint = function(self, w, h)
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawRect( 0, 0, w, h )
		local txt = lang["Features"] surface.SetFont( "GMarketMediumFont" ) local ftr_w, ftr_h = surface.GetTextSize( txt )
		draw.SimpleText( txt, "GMarketMediumFont", w/2, 5, Color(46, 204, 113), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP ) -- Features
		local txt = "- " .. lang["Delivery Time"] .. " ("..cfg.GPrimeDeliveryTime.. lang["Seconds"] .. ")" surface.SetFont( "GMarketBoldFont" ) local txt_w, txt_h = surface.GetTextSize( txt )
		draw.SimpleText( txt, "GMarketBoldFont", w/2, 15 + ftr_h, Color(45, 52, 54), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP ) -- Delivery time reduced
		local txt = "- " .. lang["Items cost"] surface.SetFont( "GMarketBoldFont" ) local txt_w, txt_h = surface.GetTextSize( txt )
		draw.SimpleText( txt, "GMarketBoldFont", w/2, 30 + ftr_h + txt_h, Color(45, 52, 54), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP ) -- Item cost reduced
		local txt = "- " .. lang["Exclusive items"] surface.SetFont( "GMarketBoldFont" ) local txt_w, txt_h = surface.GetTextSize( txt )
		draw.SimpleText( txt, "GMarketBoldFont", w/2, 45 + ftr_h + txt_h * 2, Color(45, 52, 54), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP ) -- Exclusive items
		local txt = lang["Price: $"] .. cfg.GPrimePrice surface.SetFont( "GMarketMediumFont" ) local txt_w, txt_h = surface.GetTextSize( txt )
		draw.SimpleText( txt, "GMarketMediumFont", w/2, 60 + ftr_h + txt_h * 3, Color(192, 57, 43), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP ) -- Exclusive items
	end
	
	local BuyGPrimeButton = vgui.Create( "DButton", GPrime ) -- The button for showing weapons
	BuyGPrimeButton:SetFont( "GMarketMediumFont" )
	BuyGPrimeButton:SetText( lang["Purchase"] .. " GPrime" )
	BuyGPrimeButton:SetColor( Color(45, 52, 54) )
	BuyGPrimeButton:SizeToContents()
	BuyGPrimeButton:SetPos(GPrime:GetWide()/2-BuyGPrimeButton:GetWide()/2, GPrime:GetTall() - BuyGPrimeButton:GetTall() - 5)
	BuyGPrimeButton.Paint   = function(self, w, h)
		surface.SetDrawColor( 0,0,0 )
		surface.DrawOutlinedRect( 0, 0, w, h )
		surface.SetDrawColor( 241, 196, 15 )
		surface.DrawRect( 1, 1, w-2, h-2 )
	end
	BuyGPrimeButton.DoClick = function()
		net.Start("gmarket_BuyGPrime")
		net.SendToServer()
		Tablet:Remove()
	end
	
	for k, v in pairs(ItemList) do
		local Item = {}
		local ItemContents = util.JSONToTable(v.Content)
		
		if(ItemContents.ItemCategory=="Weapons") then
			Item.Panel = ScrollWeapons:Add( "DPanel" )
		elseif(ItemContents.ItemCategory=="Entities") then
			Item.Panel = ScrollEntities:Add( "DPanel" )
		end
		Item.Panel:SetSize(Entities:GetWide(), Weapons:GetTall()/3)
		Item.Panel:Dock( TOP )
		Item.Panel:DockMargin( 20, 10, 20, 10 )
		Item.Panel.Paint = function(self, w, h)
			surface.SetDrawColor( Color(149, 165, 166, 200) )
			surface.DrawOutlinedRect( 0, 0, w, h )
			local txt = v.Name surface.SetFont( "GMarketBoldFont" ) local name_txt_w, name_txt_h = surface.GetTextSize( txt )
			draw.SimpleText( txt, "GMarketBoldFont", w/2, 5, Color(73, 111, 178), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP ) -- Item Name
			draw.SimpleText( lang["Price: $"] .. v.Price, "GMarketBoldFont", w/2, name_txt_h+5, Color(192, 57, 43), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP ) -- Item Price
			local txt = lang["Seller"] .. v.SteamID surface.SetFont( "GMarketLittleFont" ) local seller_txt_w, seller_txt_h = surface.GetTextSize( txt )
			draw.SimpleText( txt, "GMarketLittleFont", w/2, h-seller_txt_h-5, Color(149, 165, 166), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP ) -- Seller ID
			local txt = "ID: " .. ItemContents.ItemClass surface.SetFont( "GMarketLittleFont" ) local txt_w, txt_h = surface.GetTextSize( txt )
			draw.SimpleText( txt, "GMarketLittleFont", w/2, h-seller_txt_h-txt_h-5, Color(149, 165, 166), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP ) -- Item Class
			local txt = lang["Added"] .. v.Date surface.SetFont( "GMarketLittleFont" ) local txt_w, txt_h = surface.GetTextSize( txt )
			draw.SimpleText( txt, "GMarketLittleFont", w-txt_w/2-5, 5, Color(127, 140, 141), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP ) -- Date
		end
		
		Item.Image = vgui.Create( "DImage", Item.Panel )
		Item.Image:SetSize( ScrW() * 0.066, ScrH() * 0.118 )
		Item.Image:SetPos( 15, Item.Panel:GetTall()/2-Item.Image:GetTall()/2 )
		Item.Image:SetImage( "icons/" .. ItemContents.ItemIcon .. ".png" )
		
		local AddToCartButton = vgui.Create( "DButton", Item.Panel ) -- The button for showing weapons
		AddToCartButton:SetFont( "GMarketMediumFont" )
		AddToCartButton:SetText( lang["Add To Cart"] )
		AddToCartButton:SizeToContents()
		AddToCartButton:SetPos(Item.Panel:GetWide()-AddToCartButton:GetWide()-60, Item.Panel:GetTall()-AddToCartButton:GetTall()-5)
		AddToCartButton.Paint   = function(self, w, h)
			surface.SetDrawColor( 0,0,0 )
			surface.DrawOutlinedRect( 0, 0, w, h )
			surface.SetDrawColor( 241, 196, 15 )
			surface.DrawRect( 1, 1, w-2, h-2 )
		end
		AddToCartButton.DoClick = function()
			table.insert(ShoppingCart, v)
			if(v.ID==nil) then return end
			AddToCartButton:SetEnabled(false)
		end
		
		local PurchaseButton = vgui.Create( "DButton", Item.Panel ) -- The button for showing weapons
		PurchaseButton:SetFont( "GMarketBoldFont" )
		PurchaseButton:SetText( lang["Purchase"] )
		PurchaseButton:SizeToContents()
		PurchaseButton:SetPos(Item.Panel:GetWide()-PurchaseButton:GetWide()-60, Item.Panel:GetTall()-AddToCartButton:GetTall()-5 - PurchaseButton:GetTall() - 5)
		PurchaseButton.Paint   = function(self, w, h)
			surface.SetDrawColor( 0,0,0 )
			surface.DrawOutlinedRect( 0, 0, w, h )
			surface.SetDrawColor( 231, 76, 60 )
			surface.DrawRect( 1, 1, w-2, h-2 )
		end
		PurchaseButton.DoClick = function()
			Tablet:Remove()
			net.Start("gmarket_SingleBuy")
				net.WriteTable(v)
			net.SendToServer()
		end
	end
	
	local NonActiveColor = Color(231, 76, 60)
	local ActiveColor	 = Color(39, 174, 96)
	local WeaponsColor, EntitiesColor, GPrimeColor = NonActiveColor, NonActiveColor, NonActiveColor
	
	-- This shows weapons panel and hides all other panels
	local WeaponsButton = vgui.Create( "DButton", self ) -- The button for showing weapons
	WeaponsButton:SetFont( "GMarketBoldFont" )
	WeaponsButton:SetText( lang["Weapons"] )
	WeaponsButton:SizeToContents()
	WeaponsButton:SetPos(self:GetWide()/2 - WeaponsButton:GetWide()/2, 5)
	WeaponsButton.Paint   = function(self, w, h)
		surface.SetDrawColor( WeaponsColor )
		surface.DrawOutlinedRect( 0, 0, w, h )
	end
	WeaponsButton.DoClick = function()
		Weapons:SetVisible(true)
		Entities:SetVisible(false)
		GPrime:SetVisible(false)
		WeaponsColor 	= ActiveColor
		EntitiesColor 	= NonActiveColor
		GPrimeColor		= NonActiveColor
	end
	
	-- This shows entities panel and hides all other panels
	local EntitiesButton = vgui.Create( "DButton", self ) -- The button for showing entities
	EntitiesButton:SetFont( "GMarketBoldFont" )
	EntitiesButton:SetText( lang["Entities"] )
	EntitiesButton:SizeToContents()
	EntitiesButton:SetPos(self:GetWide()/2-EntitiesButton:GetWide() - WeaponsButton:GetWide()/2 - 5, 5)
	EntitiesButton.Paint   = function(self, w, h)
		surface.SetDrawColor( EntitiesColor )
		surface.DrawOutlinedRect( 0, 0, w, h )
	end
	EntitiesButton.DoClick = function()
		Weapons:SetVisible(false)
		Entities:SetVisible(true)
		GPrime:SetVisible(false)
		WeaponsColor 	= NonActiveColor
		EntitiesColor 	= ActiveColor
		GPrimeColor		= NonActiveColor
	end
	
	-- This shows entities panel and hides all other panels
	local GPrimeButton = vgui.Create( "DButton", self ) -- The button for showing entities
	GPrimeButton:SetFont( "GMarketBoldFont" )
	GPrimeButton:SetText( "GPrime" )
	GPrimeButton:SizeToContents()
	GPrimeButton:SetPos(self:GetWide()/2+WeaponsButton:GetWide()/2 + 5, 5)
	GPrimeButton.Paint   = function(self, w, h)
		surface.SetDrawColor( GPrimeColor )
		surface.DrawOutlinedRect( 0, 0, w, h )
	end
	GPrimeButton.DoClick = function()
		Weapons:SetVisible(false)
		Entities:SetVisible(false)
		GPrime:SetVisible(true)
		WeaponsColor 	= NonActiveColor
		EntitiesColor 	= NonActiveColor
		GPrimeColor		= ActiveColor
	end
	
	-- This sorts the items
	local SortByBox = vgui.Create( "DComboBox", self )
	SortByBox:SetSize( ScrW()*0.078, ScrH()*0.018 )
	SortByBox:SetPos( self:GetWide()-SortByBox:GetWide()-5, 5 )
	SortByBox:SetFont("GMarketLittleFont")
	SortByBox:SetValue( lang["Sort by"] )
	SortByBox:AddChoice( lang["Price(Low to high)"] )
	SortByBox:AddChoice( lang["Price(High to low)"] )
	SortByBox:AddChoice( lang["Name(A-Z)"] )
	SortByBox:AddChoice( lang["Name(Z-A)"] )
	SortByBox:AddChoice( lang["Date(Newer-older)"] )
	SortByBox:AddChoice( lang["Date(Older-newer)"] )
	SortByBox.OnSelect = function( panel, index, value )
		if(index==1) 	 then 	table.SortByMember(ItemList, "Price", true )
		elseif(index==2) then 	table.SortByMember(ItemList, "Price", false )
		elseif(index==3) then	table.SortByMember(ItemList, "Name",  true )
		elseif(index==4) then	table.SortByMember(ItemList, "Name",  false )
		elseif(index==5) then	table.SortByMember(ItemList, "Date",  false )
		elseif(index==6) then	table.SortByMember(ItemList, "Date",  true )	end
		self:Remove()
		vgui.Create( "GMarket", Screen )
	end
	
	local ShoppingCartButton = vgui.Create( "DButton", self ) -- The button for opening shopping Cart
	ShoppingCartButton:SetFont( "GMarketBoldFont" )
	ShoppingCartButton:SetText( lang["Shopping Cart"] )
	ShoppingCartButton:SizeToContents()
	ShoppingCartButton:SetPos(5, 5)
	ShoppingCartButton.Paint   = function(self, w, h)
		surface.SetDrawColor( 44, 62, 80 )
		surface.DrawOutlinedRect( 0, 0, w, h )
	end
	ShoppingCartButton.DoClick = function()
		self:Remove()
		vgui.Create("ShoppingCart", Screen)
	end
	
end

function GMARKET:Paint(w, h)
	surface.SetDrawColor( Color( 0, 0, 0, 180 ) )
	surface.DrawOutlinedRect( 0, 0, w, h )
	local txt = lang["Welcome"] surface.SetFont( "GMarketFont" ) local txt_w, txt_h = surface.GetTextSize( txt )
	draw.SimpleText( txt, "GMarketFont", w/2, h/2-txt_h, Color(46, 204, 113), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
end
vgui.Register("GMarket", GMARKET)

function SCREEN:Init() -- Screen
	self:SetSize( Swide, Stall )
	self:Center()
	
	local Battery = vgui.Create( "DImage", self )
	Battery:SetSize( ScrW() * 0.008, ScrH() * 0.014 )
	Battery:SetPos( Swide - 80, 5 )
	Battery:SetImage( "icons/battery.png" )
	
	local Wifi = vgui.Create( "DImage", self )
	Wifi:SetSize( ScrW() * 0.008, ScrH() * 0.014 )
	Wifi:SetPos( 5, 5 )
	Wifi:SetImage( "icons/wifi.png" )
	
	local EnterGMarket = vgui.Create( "DButton", self ) -- The button for closing the tablet
	EnterGMarket:SetText( "" )
	local w, h = draw.WordBox( 8, 0, 0, lang["Enter GMarket"], "GMarketLittleFont", Color(41, 128, 185), Color(236, 240, 241) )
	EnterGMarket.Paint   = function() draw.WordBox( 8, 0, 0, lang["Enter GMarket"], "GMarketLittleFont", Color(41, 128, 185), Color(236, 240, 241) ) end
	EnterGMarket:SetSize( w, h )
	EnterGMarket:Center()
	EnterGMarket.DoClick = function()
		
		EnterGMarket:Hide()
		local Percentage = 0
		local LoadingBar = vgui.Create( "DProgress", self )
		LoadingBar:SetSize( ScrW()*0.104, ScrH()*0.018 ) -- 200, 20
		LoadingBar:SetPos( Swide/2-LoadingBar:GetWide()/2, Stall/2-LoadingBar:GetTall()/2 )
		LoadingBar:SetFraction( Percentage )
		
		if(timer.Exists( "LoadingBar" ) ) then
			timer.Remove( "LoadingBar" )
		end
		
		timer.Create( "LoadingBar", 0.05, 20, function()
			Percentage = Percentage + 0.05
			LoadingBar:SetFraction( Percentage )
			if(timer.RepsLeft( "LoadingBar" )==0 ) then
				LoadingBar:Remove()
				vgui.Create( "GMarket", self )
			end
		end)
		
	end
end

function SCREEN:Paint(wide, height)
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawRect( 0, 0, wide, height )
	local txt = "GMarket" surface.SetFont( "GMarketFont" ) local w, h = surface.GetTextSize( txt )
	draw.SimpleText( txt, "GMarketFont", Swide/2, (Ttall-Stall)/4-h/2, Color(52, 152, 219), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
	local txt = os.date( "%H:%M", os.time() ) surface.SetFont( "GMarketFont" ) local w, h = surface.GetTextSize( txt )
	draw.SimpleText( txt, "GMarketLittleFont", wide-w/2, 7, Color(52, 152, 219), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP ) -- tablet clock
end
vgui.Register("GTabletScreen", SCREEN)