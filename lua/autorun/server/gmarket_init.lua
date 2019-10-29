local ntw = {
"gmarket_OpenWeb",
"gmarket_OpenMailBox",
"gmarket_OpenSeller",
"gmarket_Sell",
"gmarket_Buy",
"gmarket_SingleBuy",
"gmarket_BuyGTablet",
"gmarket_BuyMailBox",
"gmarket_BuyGPrime",
"gmarket_PickUp",
"gmarket_Notify",
}

for k, v in pairs(ntw) do
	util.AddNetworkString(v)
end

resource.AddSingleFile( "resource/fonts/nasalization-rg.ttf" )

resource.AddSingleFile( "materials/icons/grenade.png" )
resource.AddSingleFile( "materials/icons/handgun.png" )
resource.AddSingleFile( "materials/icons/heavy.png" )
resource.AddSingleFile( "materials/icons/knife.png" )
resource.AddSingleFile( "materials/icons/machine-gun.png" )
resource.AddSingleFile( "materials/icons/rifle.png" )
resource.AddSingleFile( "materials/icons/shotgun.png" )
resource.AddSingleFile( "materials/icons/smg.png" )
resource.AddSingleFile( "materials/icons/sniper.png" )
resource.AddSingleFile( "materials/icons/pack.png" )
resource.AddSingleFile( "materials/icons/battery.png" )
resource.AddSingleFile( "materials/icons/wifi.png" )

resource.AddSingleFile( "materials/gmarket/cornice.vtf" )
resource.AddSingleFile( "materials/gmarket/schermo.vtf" )
resource.AddSingleFile( "models/gmarket/tablet.mdl" )