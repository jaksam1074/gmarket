net.Receive("gmarket_Notify", function() -- Notification that player receives
	local txt = net.ReadString()
	notification.AddLegacy( txt, NOTIFY_GENERIC, 2 )
	surface.PlaySound( "ambient/water/drip" .. math.random(1, 4) .. ".wav" )
end)