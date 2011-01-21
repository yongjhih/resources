function MakePlayerHeadshot( attacker, weapon, bodypart, loss )
	if getElementType ( attacker ) == "ped" then
		if bodypart == 9 then
			triggerEvent("onPlayerHeadshot", source, attacker, weapon, loss )
			setPedHeadless ( source, true )
			killPed( source, attacker, weapon, bodypart )
			setTimer( BackUp, 1800, 1, source )
		end
	end
end

function MakeHeadshot( source, attacker, weapon, loss )
	killPed( source, attacker, weapon, 9 )
	setPedHeadless ( source, true )
	setTimer( BackUp, 1800, 1, source )
end

function BackUp( source )	
	if getElementType ( source ) == "player" then
		setPedHeadless ( source, false )
	end
end

function outputHeadshotIcon (killer, weapon, bodypart)
	if bodypart == 9 then
		cancelEvent()
		local r2,g2,b2 = getPlayerNametagColor(killer)
		local r1,g1,b1 = getPlayerNametagColor(source)
		exports.killmessages:outputMessage (
		{getPlayerName(killer),{"padding",width=3},{"icon",id=weapon},{"padding",width=3},{"icon",id=256},{"padding",width=3},{"color",r=r1,g=g1,b=b1},getPlayerName(source) }, getRootElement(),r2,g2,b2) 				
	end
end
addEvent ( "onPlayerHeadshot", true )
addEvent ( "onServerHeadshot", true )
addEventHandler( "onPlayerDamage", getRootElement(), MakePlayerHeadshot )
addEventHandler( "onPlayerKillMessage", getRootElement(), outputHeadshotIcon )
addEventHandler( "onServerHeadshot", getRootElement(), MakeHeadshot )
