safecol = createColCuboid ( -2096.1049804688, 102.16305541992, 35.153751373291, 200, 150, 100 )
safeZoneRadar = createRadarArea ( -2096.1049804688, 102.16305541992, 200, 150, 0, 255, 0, 120 )


function enterZone(hitPlayer,thePlayer)
local skin = getElementModel (hitPlayer)
      if ( skin == 285 ) then
    toggleControl (hitPlayer, "fire", false )
    toggleControl (hitPlayer, "aim_weapon", false)
    toggleControl (hitPlayer, "vehicle_fire", false)
    outputChatBox("Welcome, in Racoon Town!", hitPlayer, 0, 255, 0)
       else
         killPed (hitPlayer)
end
end
addEventHandler( "onColShapeHit", safecol, enterZone )

function leaveZone(hitPlayer,thePlayer)
local skin = getElementModel (hitPlayer)
    toggleControl (hitPlayer, "fire", true)
    toggleControl (hitPlayer, "aim_weapon", true)
    toggleControl (hitPlayer, "vehicle_fire", true)
    outputChatBox("* WARNING: You left Racoon Town, You are now in the Infected Zone!", hitPlayer, 255, 0, 0)
 if not ( skin == 285 )  then
  killPed (hitPlayer)
end
end
addEventHandler( "onColShapeLeave", safecol, leaveZone )