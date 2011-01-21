function sendHeadshot ( attacker, weapon, bodypart, loss )
	if attacker == getLocalPlayer() then
		if bodypart == 9 then
			triggerServerEvent( "onPlayerHeadshot", getRootElement(), source, attacker, weapon, loss )
			triggerServerEvent( "onServerHeadshot", getRootElement(), source, attacker, weapon, loss )
		end
	end
end
addEventHandler ( "onClientPedDamage", getRootElement(), sendHeadshot )
addEventHandler ( "onClientPlayerDamage", getRootElement(), sendHeadshot )
