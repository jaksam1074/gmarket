GMarket = GMarket or {}
local PLAYER = FindMetaTable("Player")

-- Returns the list with all Items that can be sold (default and non)
function GMarket.OnSaleList( ply )
	local Items = {}
	local ReducedPerc = 0
	
	-- if ply is a GPrime member adds GPrime default items to OnSaleList and reduce gmarket items cost
	if( ply:IsGPrimeMember() ) then
		for k, v in pairs(cfg.GPrimeDefaultItems) do
			local DefaultItem = {Content = util.TableToJSON(v), Date = util.DateStamp(), Name = v.ItemName, Price = v.ItemPrice, SteamID = "GPrime" }
			table.insert(Items, DefaultItem)
		end
		ReducedPerc = cfg.GPrimeReducedAmount
	end
	for k, v in pairs(cfg.DefaultItems) do
		local ItemCost = v.ItemPrice - v.ItemPrice * ReducedPerc
		local DefaultItem = {Content = util.TableToJSON(v), Date = util.DateStamp(), Name = v.ItemName, Price = ItemCost, SteamID = "GMarket" }
		table.insert(Items, DefaultItem)
	end
	
	local ItemsFromUsers = sql.Query("SELECT * FROM gmarket_onsale") or {}
	
	for k, v in pairs(ItemsFromUsers) do
		v.Price = tonumber(v.Price)
		table.insert(Items, v)
	end
	return Items
end

-- Returns true if PLAYER is a GPrime member, false if not
function PLAYER:IsGPrimeMember()
	local id = sql.Query( "SELECT SteamID, Expires FROM gmarket_gprimemembers WHERE SteamID = " .. sql.SQLStr( self:SteamID64(), true ) )
	if( id == nil ) then
		return false 
	else 
		if( tonumber(id[1].Expires) < os.time() ) then -- Checks if GPrime is expired for the user, if so, deletes his account
			sql.Query( "DELETE FROM gmarket_gprimemembers WHERE SteamID = " .. sql.SQLStr( self:SteamID64(), true ) )
			return false
		else
			return true
		end
	end
end

-- Returns the list of items that a player has to withdraw from mailbox
function PLAYER:WithdrawList()
	return sql.Query( "SELECT * FROM gmarket_towithdraw WHERE SteamID = " .. sql.SQLStr( self:SteamID64(), true ) ) or {}
end

-- Adds an Item in gmarket_onsale
function PLAYER:SellItem(Item, Price)
	local Content = sql.SQLStr( util.TableToJSON( Item.ItemContent ) )
	local Steamid = sql.SQLStr( self:SteamID64() )
	local name = sql.SQLStr( Item.ItemContent.ItemName )
	local CleanPrice = sql.SQLStr( Price, true )
	sql.Query([[INSERT INTO gmarket_onsale(SteamID, Content, Date, Price, Name)
		VALUES(]]..Steamid..[[,]]..Content..[[,']].. sql.SQLStr( util.DateStamp(), true )..[[',]].. CleanPrice .. [[,]] .. name ..[[)
	]])
end

-- Receive Item to sell info
net.Receive("gmarket_Sell", function(len, ply)
	local Item = net.ReadTable()
	local Price = net.ReadInt(32)
	Item.ItemEntity:Remove()
	ply:SellItem(Item, Price)
end)

-- Adds item to "towithdraw"
function PLAYER:AddItemToWithdraw( Content, Price, name )
	local Steamid	 = sql.SQLStr( self:SteamID64() )
	sql.Query([[INSERT INTO gmarket_towithdraw(SteamID, Content, Date, Price, Name)
		VALUES(]]..Steamid..[[,]]..Content..[[,']]..sql.SQLStr(util.DateStamp(), true )..[[',]].. Price .. [[,]] .. name ..[[)
	]])
end

-- Removes items from the market and adds them to withdraw list for the buyer
function PLAYER:BuyItem(Items)
	
	local FullPrice	 = 0
	local plyMoney   = self:getDarkRPVar("money")
	
	-- Calculates the full price of items bought
	for k, v in pairs(Items) do
		FullPrice = FullPrice + v.Price
	end
	
	-- Can player afford it?
	if( FullPrice > plyMoney ) then
		net.Start("gmarket_Notify")
			net.WriteString( lang["No money"] )
		net.Send(self)
	return end
	
	-- Deletes bought item from market, add items to withdraw list and gives money to seller
	for k, v in pairs(Items) do
		local Content 	= sql.SQLStr( v.Content )
		local CleanPrice = sql.SQLStr( v.Price, true )
		local name		= sql.SQLStr( v.Name )
		
		if(v.ID!=nil) then
			local seller = player.GetBySteamID64( v.SteamID )
			sql.Query("DELETE FROM gmarket_onsale WHERE ID=".. sql.SQLStr(v.ID, true) )
			if( seller ) then
				seller:addMoney( v.Price )
				
				net.Start("gmarket_Notify")
					net.WriteString( lang["Sold"] .. " \"" .. v.Name .. "\" " .. lang["for"] .. v.Price)
				net.Send(seller)
			else
				local SellerSteamID = sql.SQLStr( v.SteamID )
				sql.Query("INSERT INTO gmarket_soldinfo(SteamID, Price, Name) VALUES ("..SellerSteamID..","..CleanPrice..","..name..")")
			end
		end
		
		local Deliverytime
		
		if( self:IsGPrimeMember() ) then
			Deliverytime = cfg.GPrimeDeliveryTime
		else
			Deliverytime = cfg.DeliveryTime
		end
		
		timer.Simple( Deliverytime, function()
			self:AddItemToWithdraw(Content, CleanPrice, name)
			net.Start("gmarket_Notify")
				net.WriteString( lang["Arrived"] )
			net.Send(self)
		end )
		
	end
	self:addMoney(-FullPrice)
	net.Start("gmarket_Notify")
		net.WriteString( lang["Purchased"] )
	net.Send(self)
end

-- Buy items in shopping cart of the user
net.Receive("gmarket_Buy", function(len,ply)
	local Items = net.ReadTable()
	local IDList = {}
	local OnSaleIDs = sql.Query("SELECT ID FROM gmarket_onsale") or {}
	
	if( table.Count( OnSaleIDs ) > 0 ) then
		for k,v in pairs( OnSaleIDs ) do
			table.insert(IDList, v.ID)
		end
	end
	
	for _, item in pairs( Items ) do
		if(item.ID!=nil) then
			if( not table.HasValue(IDList, item.ID) ) then -- A item is not available anymore
				net.Start("gmarket_Notify")
					net.WriteString( lang["No available"] )
				net.Send(ply)
				return
			end
		end
	end
	
	ply:BuyItem(Items)
end)

-- Single Buy an item

function PLAYER:SingleBuy(Item)
	local Price		= Item.Price
	local plyMoney   = self:getDarkRPVar("money")
	
	if(Price > plyMoney) then 
		net.Start("gmarket_Notify")
			net.WriteString( lang["No money"] )
		net.Send(self)
	return end
	
	local name		= sql.SQLStr( Item.Name )
	local Content 	= sql.SQLStr( Item.Content )
	local CleanPrice = sql.SQLStr( Price, true )
	
	if(Item.ID != nil) then
		local seller = player.GetBySteamID64( Item.SteamID )
		sql.Query("DELETE FROM gmarket_onsale WHERE ID=".. sql.SQLStr( Item.ID, true ) )
		
		if( seller ) then -- seller is online
			seller:addMoney( Price )
			
			net.Start("gmarket_Notify")
				net.WriteString( lang["Sold"] .. " \"" .. Item.Name .. "\" " .. lang["for"] .. Price)
			net.Send(seller)
		else -- seller is offline
			local SellerSteamID = sql.SQLStr( Item.SteamID )
			sql.Query("INSERT INTO gmarket_soldinfo(SteamID, Price, Name) VALUES ("..SellerSteamID..","..CleanPrice..","..name..")")
		end
	end
	
	local Deliverytime
	
	if( self:IsGPrimeMember() ) then
		Deliverytime = cfg.GPrimeDeliveryTime
	else
		Deliverytime = cfg.DeliveryTime
	end
	
	timer.Simple( Deliverytime, function()
		self:AddItemToWithdraw(Content, CleanPrice, name)
		net.Start("gmarket_Notify")
			net.WriteString( lang["Arrived"] )
		net.Send(self)
	end )
	
	self:addMoney(-Price)
	net.Start("gmarket_Notify")
		net.WriteString( lang["Purchased"] )
	net.Send(self)
end

-- Get info from Single buy from GTabelt
net.Receive("gmarket_SingleBuy", function(len, ply)
	local Item = net.ReadTable()
	local IDList = {}
	local OnSaleIDs = sql.Query("SELECT ID FROM gmarket_onsale") or {}
	
	if( table.Count( OnSaleIDs ) > 0 ) then
		for k,v in pairs( OnSaleIDs ) do
			table.insert(IDList, v.ID)
		end
	end
	
	if(Item.ID!=nil) then
		if( not table.HasValue(IDList, Item.ID) ) then -- A Item is not available anymore
			net.Start("gmarket_Notify")
				net.WriteString( lang["No available"] )
			net.Send(ply)
			return
		end
	end
	
	ply:SingleBuy(Item)
end)

-- Buys GPrime if the player can afford it
net.Receive("gmarket_BuyGPrime", function(len, ply)

	local plyMoney   = ply:getDarkRPVar("money")
	local plySteamID = sql.SQLStr(ply:SteamID64())
	
	if( not ply:IsGPrimeMember() ) then
		if( plyMoney > cfg.GPrimePrice ) then
			ply:addMoney( -cfg.GPrimePrice )
			sql.Query("INSERT INTO gmarket_gprimemembers(SteamID, Expires) VALUES (" .. plySteamID .. "," .. sql.SQLStr( os.time() + (cfg.GPrimeDuration * 86400) .. ")", true) ) -- os.time + 86400 means tomorrow
			net.Start("gmarket_Notify")
				net.WriteString( lang["GPrime Member"] )
			net.Send(ply)
		else
			net.Start("gmarket_Notify")
				net.WriteString( lang["No money"] )
			net.Send(ply)
		end
	else
		net.Start("gmarket_Notify")
			net.WriteString( lang["Already Member"] )
		net.Send(ply)
	end

end)

-- Buy GTablet from seller
net.Receive("gmarket_BuyGTablet", function(len, ply)
	local plyMoney = ply:getDarkRPVar("money")
	
	if( not ply:HasWeapon("gmarket_tablet") ) then
		if(plyMoney < cfg.GTabletPrice) then
			net.Start("gmarket_Notify")
				net.WriteString( lang["No money"] )
			net.Send(ply)
		else
			ply:addMoney(-cfg.GTabletPrice)
			net.Start("gmarket_Notify")
				net.WriteString( lang["Thank you"] )
			net.Send(ply)
			ply:Give("gmarket_tablet")
		end
	else
		net.Start("gmarket_Notify")
			net.WriteString( lang["You already have"] .. "GTablet" )
		net.Send(ply)
	end
end)

-- Buy MailBox from seller
net.Receive("gmarket_BuyMailBox", function(len, ply)
	local plyMoney = ply:getDarkRPVar("money")
	local Seller = net.ReadEntity()
	local steamid = ply:SteamID64()

	if(plyMoney < cfg.MailBoxPrice) then
		net.Start("gmarket_Notify")
			net.WriteString( lang["No money"] )
		net.Send(ply)
	else
		ply:addMoney(-cfg.MailBoxPrice)
		net.Start("gmarket_Notify")
			net.WriteString( lang["Thank you"] )
		net.Send(ply)
		local MailBox = ents.Create( "gmarket_mailbox" )
		if ( !IsValid( MailBox ) ) then return end
		MailBox:SetPos( Seller:EyePos() + Seller:GetAimVector() * 15 )
		MailBox:CPPISetOwner(ply) -- Falco prop protection set owner of entity
		MailBox:Spawn()
	end
end)

function PLAYER:PickUpItem( Item, MailBox )
	sql.Query("DELETE FROM gmarket_towithdraw WHERE ID = " .. sql.SQLStr(Item.ID, true ) )
	local ItemContent = util.JSONToTable( Item.Content )
	
	local Pack = ents.Create( "gmarket_pack" )
	if ( !IsValid( Pack ) ) then return end
	Pack:SetPos( MailBox:GetPos() + Vector(0, 0, 80) )
	Pack:SetNWString("Item", ItemContent.ItemClass )
	Pack:CPPISetOwner( self )
	Pack:Spawn()
end

-- Pick Up a item from mailbox and removes it from towithdraw list
net.Receive("gmarket_PickUp", function(len, ply) 
	ply:PickUpItem( net.ReadTable(), net.ReadEntity() )
end)

-- Gives to player money for sold items when was offline if there are one
local function OfflineSales( ply )
	timer.Simple(1, function()
		local Sales = sql.Query("SELECT * FROM gmarket_soldinfo WHERE SteamID = " .. sql.SQLStr(ply:SteamID64(), true) ) or {}

		if( Sales == nil ) then return end
		
		sql.Query("DELETE FROM gmarket_soldinfo WHERE SteamID = " .. sql.SQLStr(ply:SteamID64(), true) )
		
		for k, v in pairs(Sales) do
			ply:addMoney( v.Price )
					
			net.Start("gmarket_Notify")
				net.WriteString( lang["Sold"] .. " \"" .. v.Name .. "\" " .. lang["for"] .. v.Price)
			net.Send(ply)
		end
	end)
end
hook.Add("PlayerInitialSpawn", "OfflinePlayerSales", OfflineSales)

-- Removes player's MailBox when player disconnects
local function RemoveMailBox( ply )
	for k, v in pairs( ents.FindByClass("gmarket_mailbox" ) ) do
		if( v:CPPIGetOwner() == ply ) then
			v:Remove()
		end
	end
end
hook.Add("PlayerDisconnected", "RemoveMailbox", RemoveMailBox)