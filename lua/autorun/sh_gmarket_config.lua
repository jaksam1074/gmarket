cfg = {} local GMarket_Config = cfg

-- Available icons list: handgun, heavy, knife, machine-gun, rifle, shotgun, smg, sniper, grenade, pack (used for entities)

-- Items always on sale on GMarket (THE LAST ONE MUST NOT HAVE COMMA AT END) Available categories: Weapons, Entities
GMarket_Config.DefaultItems = {
--{ItemName = "AK-47", ItemClass = "weapon_ak472", ItemCategory = "Weapons", ItemPrice = 100, ItemIcon = "rifle"},
}

-- default items that only GPrime members can see and buy from GMarket, Available categories: Weapons, Entities
GMarket_Config.GPrimeDefaultItems = {
--{ItemName = "Rocket Launcher", ItemClass = "weapon_rpg", ItemCategory = "Weapons", ItemPrice = 600, ItemIcon = "heavy"},
}

-- Items that users can sell through MailBoxes, Available categories: Weapons, Entities
GMarket_Config.ItemsCanBeSold = {
--{ItemName = "Deagle", ItemClass = "weapon_deagle2", ItemCategory = "Weapons", ItemIcon = "handgun"},
}

-- Max price that item can be sold
GMarket_Config.MaxPrice = 100000

-- GTablet price
GMarket_Config.GTabletPrice = 500

-- MailBox price
GMarket_Config.MailBoxPrice = 2000

-- Normal delivery time
GMarket_Config.DeliveryTime = 10

-- GPrime delivery time
GMarket_Config.GPrimeDeliveryTime = 5

-- GPrime reduced price % on GMarket DefaultItems. 0 for no reduction, 1 for free items (0.15 = 15%, 0.50 = 50%)
GMarket_Config.GPrimeReducedAmount = 0.25

-- GPrime price
GMarket_Config.GPrimePrice = 5000

-- GPrime duration (in days, only integer. Ex: 1, 2, 3, 4)
GMarket_Config.GPrimeDuration = 2

AddCSLuaFile()