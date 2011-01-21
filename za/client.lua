addEventHandler ("onClientResourceStart",getRootElement(),
function ()
helpWnd = guiCreateWindow(126,122,559,325,"Zombie Apocalypse - Help Page",false)
guiSetAlpha(helpWnd,1)
guiWindowSetMovable(helpWnd,false)
guiWindowSetSizable(helpWnd,false)
helpText = guiCreateMemo(9,25,541,250,"==================Zombie Apocalypse Release 0.9.5====================\n=================By (BIG_PAJA)Benxamix2 / Benxamix2==================\n==========================================================\n\nZombies based-in gamemode.\n\nIn this gamemode, your objetive is to survive, earning money and unlocking achievements.\n\nYou start with a Colt 45 with 34 bullets. With that only weapon, you must as much zombies as you can. Every killed zombie gives you $25. If you get $500, then you will be able to buy a Colt 45 in the shop. If you die before you get those $500, don't cry! You will receive a Colt 45 and you will must get them anyway.\n\nThis gamemode includes a Rank System. When you kill a determinated amount of zombies, you get a new rank! For example, 10 killed zombies give you the \"Noob\" Rank. On start, your rank is \"Coward\". Can you get the last rank? Go out and try it!",false,helpWnd)
guiMemoSetReadOnly(helpText,true)
closeButton = guiCreateButton(9,283,539,31,"Close Help Page",false,helpWnd)
guiSetVisible(helpWnd,false)

addEventHandler ("onClientGUIClick", closeButton,closeHelp)
bindKey("F1","down",showHelp)

end
)

function showHelp ()
 guiSetVisible (helpWnd,true)
 showCursor(true)
 unbindKey("F1","down",showHelp)
 bindKey("F1","down",closeHelp)
end
function closeHelp ()
 guiSetVisible (helpWnd,false)
 showCursor(false)
 unbindKey("F1","down",closeHelp)
 bindKey("F1","down",showHelp)
end