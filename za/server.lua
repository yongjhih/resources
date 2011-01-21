addEventHandler("onPlayerJoin",getRootElement(),
function ()
 local player = getPlayerAccount(source)
 local achievement1 = getAccountData(player,"Achievement: First Weapon")
 local achievement2 = getAccountData(player,"Achievement: All Ranks")
 local achievement3 = getAccountData(player,"Achievement: Million Dolar Man")
 local achievement4 = getAccountData(player,"Achievement: All Achievements")

 if achievement1 == nil or achievement1 == "" then
   setAccountData(source,"Achievement: First Weapon","false")
 end
 if achievement2 == nil or achievement2 == "" then
   setAccountData(player,"Achievement: All Ranks","false")
 end
 if achievement3 == nil or achievement3 == "" then
   setAccountData(player,"Achievement: Million Dolar Man","false")
 end
 if achievement1 == false then
  if achievement2 == false then
   if achievement3 == false then
    setAccountData(player,"Achievement: All Achievements","false")
    setAccountData(player,"Permisssion to get out","false")
   end
  end
 end 
end)
  
  
  local banquera = createPed (172,2318.3, -15.36, 27.74)
  setPedRotation (banquera,90)
  
  local vendedorArmas = createPed (73,2306.6599,-1.6408,26.7421)
  setPedRotation (vendedorArmas, 270)
  
  puerta = createObject (5856,2304.2231445313,-15.65851020813,27.748359680176)
  markerEntrar = createMarker (2304.2231445313,-15.65851020813,26.748359680176,'cylinder',2,0,0,0,0)
  markerEntrar2 = createMarker (2315.7546386719,0.72728729248047,25.459999084473,'cylinder',3,0,0,0,0)

  limite = createColCuboid (2212.7, -100.83, 0, 360.67, 317, 38)
  
  setWeather (44)
  setTime (0,0)

function entrar1 (hitPlayer,matchingDimesion)
local skin = getElementModel (hitPlayer)
 if skin == 285 then
  moveObject (puerta,1000,2304.2231445313,-12.65851020813,27.748359680176)
 else
  killPed (hitPlayer)
 end
end
addEventHandler ('onMarkerHit', markerEntrar, entrar1)

function entrar2 (hitPlayer,matchingDimesion)
  moveObject (puerta,1000,2304.2231445313,-15.65851020813,27.748359680176)
end
addEventHandler ("onMarkerLeave",markerEntrar, entrar2)

function entrarB1 (hitPlayer,matchingDimesion)
local skin = getElementModel (hitPlayer)
 if not skin == 285 then
  killPed (hitPlayer)
 end
end
addEventHandler ('onMarkerHit', markerEntrar2, entrarB1)

function cruzarLimite (hitPlayer,matchingDimension)
local player = getPlayerAccount(hitPlayer)
 if (getAccountData(player,"Permission to get out") == false) then
  killPed (hitPlayer)
  outputChatBox("Don't try to hack your position! Play fair!",hitPlayer,255,0,0)
 end
end
addEventHandler ("onColShapeLeave",limite,cruzarLimite)


function respawn (player)
    spawnPlayer(player,2314.75+math.random(-1,1), -6.43+math.random(-1,1), 26.74, 180, 285)
	setCameraTarget(player, player)
	if (getPlayerMoney(player) < 500) and (exports.bank:getBankAccountBalance (player) < 500) then
	 giveWeapon (player,22,34,true)
	end
end

addEventHandler("onPlayerWasted", root, 
function (player)
 setPlayerMoney(source,0)
 takeAllWeapons(source)
 setTimer (respawn,3000,1,source)
 fadeCamera(source,true,1,255,255,255)
end)

function announce ()
 outputChatBox ("HELP: Don't forget to save your money in the bank!")
 outputChatBox ("HELP: You can press F1 to show a help page.")
end
setTimer (announce,90000,0)
