local function SQLiteSETUP()
	-- Here it will save perma seller positions
	if( not file.Exists("gmarket_data", "DATA") ) then
		MsgC(Color(125, 95, 255), "[GMarket] Creating data gmarket_data...\n")
		file.CreateDir("gmarket_data")
		MsgC(Color(125, 95, 255), "[GMarket] data created!\n")
	end
	
	-- This will save things on sale
	if( not sql.TableExists( "gmarket_onsale" ) ) then
		MsgC(Color(125, 95, 255), "[GMarket] Creating data gmarket_onsale...\n")
		local query = sql.Query([[
			CREATE TABLE  gmarket_onsale(
				ID 			INTEGER PRIMARY KEY AUTOINCREMENT,
				SteamID 	VARCHAR(17),
				Content		VARCHAR,
				Date		TEXT,
				Price		TEXT,
				Name		VARCHAR
			);
		]])
		
		if( query==false ) then
			MsgC(Color(125, 95, 255), "[GMarket] Error: " .. sql.LastError() .. "\n")
		else
			MsgC(Color(125, 95, 255), "[GMarket] data created!\n")
		end
	end
	
	-- This will save things to withdraw
	if( not sql.TableExists( "gmarket_towithdraw" ) ) then
		MsgC(Color(125, 95, 255), "[GMarket] Creating data gmarket_towithdraw...\n")
		local query = sql.Query([[
			CREATE TABLE  gmarket_towithdraw(
				ID 			INTEGER PRIMARY KEY AUTOINCREMENT,
				SteamID 	VARCHAR(17),
				Content		VARCHAR,
				Date		TEXT,
				Price		TEXT,
				Name		VARCHAR
			);
		]])
		
		if( query==false ) then
			MsgC(Color(125, 95, 255), "[GMarket] Error: " .. sql.LastError() .. "\n")
		else
			MsgC(Color(125, 95, 255), "[GMarket] data created!\n")
		end
	end
	
	-- This will save sold info for offline players
	if( not sql.TableExists( "gmarket_soldinfo" ) ) then
		MsgC(Color(125, 95, 255), "[GMarket] Creating data gmarket_soldinfo...\n")
		local query = sql.Query([[
			CREATE TABLE  gmarket_soldinfo(
				ID 			INTEGER PRIMARY KEY AUTOINCREMENT,
				SteamID 	VARCHAR(17),
				Price		INTEGER,
				Name		VARCHAR
			);
		]])
		
		if( query==false ) then
			MsgC(Color(125, 95, 255), "[GMarket] Error: " .. sql.LastError() .. "\n")
		else
			MsgC(Color(125, 95, 255), "[GMarket] data created!\n")
		end
	end
	
	-- This will save Prime members
	if( not sql.TableExists( "gmarket_gprimemembers" ) ) then
		MsgC(Color(125, 95, 255), "[GMarket] Creating data gmarket_gprimemembers...\n")
		local query = sql.Query([[
			CREATE TABLE  gmarket_gprimemembers(
				ID 			INTEGER PRIMARY KEY AUTOINCREMENT,
				SteamID 	VARCHAR(17),
				Expires		INTEGER
			);
		]])
		
		if( query==false ) then
			MsgC(Color(125, 95, 255), "[GMarket] Error: " .. sql.LastError() .. "\n")
		else
			MsgC(Color(125, 95, 255), "[GMarket] data created!\n")
		end
	end
end
hook.Add("Initialize", "GMarket_CreateData", SQLiteSETUP) -- Creates all data needed

-- Saves sellers positions in the acutal map
concommand.Add( "gmarket_savepos", function( ply, cmd, args )
	if( ply:IsAdmin() ) then
		local seller_pos = {}
		
		for k, v in pairs( ents.FindByClass( "gmarket_seller" ) ) do
			table.insert(seller_pos, {SellerPos = v:GetPos(), SellerAngle = v:GetAngles() } )
		end
		
		file.Write("gmarket_data/seller_pos_" .. game.GetMap() .. ".txt", util.TableToJSON(seller_pos)) 
		print( "[GMarket] Seller positions saved")
	else
		print( "[GMarket] " .. ply:GetName() .. " tried to save seller pos (Not authorized)")
	end
end )

local function LoadSellers() -- Loads Seller entities if there are any in the map
	if(file.Exists("gmarket_data/seller_pos_" .. game.GetMap() .. ".txt", "DATA")) then
		local SellerPos = util.JSONToTable( file.Read ( "gmarket_data/seller_pos_" .. game.GetMap() .. ".txt", "DATA" ) ) -- Get seller positions and angles
		for k, v in pairs(SellerPos) do
			local Seller = ents.Create("gmarket_seller")
			Seller:SetPos(v.SellerPos)
			Seller:SetAngles(v.SellerAngle)
			Seller:Spawn()
		end
		MsgC(Color(125, 95, 255), "[GMarket] Sellers Loaded!\n")
	else
		MsgC(Color(125, 95, 255), "[GMarket] No sellers found in this map!\n")
	end
end
hook.Add( "InitPostEntity", "gmarket_LoadSellersPos", LoadSellers) -- Loads MailBox entities if there are any in the map on map loading
hook.Add( "PostCleanupMap", "gmarket_CleanUpReload", LoadSellers) -- Loads MailBox entities if there are any in the map after a cleanup

concommand.Add( "gmarket_cleardata", function( ply, cmd, args )
	if( ply:IsSuperAdmin() ) then
		-- Clears sql lite tables
		sql.Query("DROP TABLE gmarket_onsale")
		sql.Query("DROP TABLE gmarket_towithdraw")
		sql.Query("DROP TABLE gmarket_soldinfo")
		sql.Query("DROP TABLE gmarket_gprimemembers")
		
		-- Clears saved seller pos in data folder
		local SellerPos = file.Find( "gmarket_data/*.txt", "DATA" )
		for k, v in pairs( SellerPos ) do
			print(v)
			file.Delete( "gmarket_data/" .. v )
		end
		file.Delete("gmarket_data")
		
		-- Start data creation process
		SQLiteSETUP()
		print( "[GMarket] All Data Cleared by " .. ply:GetName())
	else
		print( "[GMarket] " .. ply:GetName() .. " tried to clear GMarket data (Not authorized)")
	end
end )