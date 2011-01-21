
shopMarker = createMarker (2308.87,-1.91,25.9,"cylinder",1,255,0,0,128)

addEvent ("viewGUI", true)
function showGui (hitPlayer, matchingDimension)
    triggerClientEvent ("viewGUI", hitPlayer)
end
addEventHandler("onMarkerHit",shopMarker,showGui)

addEvent ("weapBuy", true)
addEventHandler ("weapBuy", getRootElement(), 
function(id, cost, name, ammo)
local player = getPlayerAccount(source)
  if (getPlayerMoney (source) >= tonumber(cost)) then
    outputChatBox ("You bought a " .. name, source, 255, 0, 0, false)
    takePlayerMoney (source, tonumber (cost))
    giveWeapon(source, tonumber(id),100)
     if (getAccountData(player,"Achievement: First Weapon") == false ) then
      outputChatBox ("New Achievement! You bought your first weapon!",source,0,255,0)
      setAccountData (player,"Achievement: First Weapon","true")
     end
  else
    outputChatBox ("You haven't enough money for that.", source, 255, 0, 0, false)
  end
end)
