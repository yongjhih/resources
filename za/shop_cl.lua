shopWindow = guiCreateWindow(367,105,334,435,"Ammu-Nation",false)
guiSetVisible (shopWindow, false)
guiSetAlpha(shopWindow,1)
guiWindowSetSizable(shopWindow,false)
guiWindowSetMovable(shopWindow,false)
weapGrid = guiCreateGridList(4,25,325,360,false,shopWindow)
guiGridListSetSelectionMode(weapGrid,0)
weapColumn = guiGridListAddColumn(weapGrid,"Weapon",0.5)
costColumn = guiGridListAddColumn(weapGrid,"$",0.3)
weapButton = guiCreateButton(4,400,155,30,"Buy Weapon",false,shopWindow)
local weapons = {{31,3000},{4,5000},{5,50},{6,100},{7,100},{8,1000},{9,5000},{22,500},{23,2700},{24,4000},{25,4200},{26,9000},{27,8000},{28,6500},{29,7000},{30,3500},{32,7800},{33,11000},{34,16000},{16,20000}}
for i,v in ipairs (weapons) do
    local itemName = getWeaponNameFromID (v[1])
    local row = guiGridListAddRow (weapGrid)
    guiGridListSetItemText (weapGrid, row, 1, itemName, false, true)
    guiGridListSetItemText (weapGrid, row, 2, tostring(v[2]), false, true)
end
guiSetAlpha(weapGrid,1)
closeButton = guiCreateButton(175,400,160,30,"Close Shop",false,shopWindow)

function closeShop()
	if guiGetVisible(shopWindow) then 
		guiSetVisible(shopWindow,false)
		showCursor(false)
	end
end
addEventHandler ("onClientGUIClick", closeButton, closeShop)

addEvent ("viewGUI", true)
function viewGUI ()
  if (getLocalPlayer() == source) then
    guiSetVisible (shopWindow, true)
    showCursor (true)
  end
end
addEventHandler ("viewGUI", getRootElement(), viewGUI)

function onClientWeapBuy (button, state, absoluteX, absoluteYe)
  if (source == weapButton) then
    if (guiGridListGetSelectedItem (weapGrid)) then
      local itemName = guiGridListGetItemText (weapGrid, guiGridListGetSelectedItem (weapGrid), 1)
      local itemID = getWeaponIDFromName (itemName)
      local itemCost = guiGridListGetItemText (weapGrid, guiGridListGetSelectedItem (weapGrid), 2)
      triggerServerEvent ("weapBuy", getLocalPlayer(), itemID, itemCost, itemName)
    end
  end
end
addEventHandler ("onClientGUIClick", weapButton, onClientWeapBuy)
