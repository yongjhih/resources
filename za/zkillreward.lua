addEventHandler ("onPlayerJoin",getRootElement(),
function (client)
local player = getPlayerAccount(client)
 look = nil
    if hasObjectPermissionTo( client, 'general.adminpanel', false ) then
       setAccountData (player,"Permission to get out","true")
    end
end)

addEvent("onZombieWasted")
addEventHandler( "onZombieWasted", getRootElement(),
          function (killer)
          
local achievement1 = getAccountData(player,"Achievement: First Weapon")
local achievement2 = getAccountData(player,"Achievement: All Ranks")
local achievement3 = getAccountData(player,"Achievement: Million Dolar Man")
local achievement4 = getAccountData(player,"Achievement: All Achievements")

              local player = getPlayerAccount ( killer )
              local myRank = getAccountData(player,"rank")
              local zombieKills = getAccountData(player, "zombieKills")
              
              if (myRank == "" or myRank == nil or myRank == false) then
               myRank = "Coward"
              end
              if (zombieKills == "" or zombieKills == nil or zombieKills == false) then
               zombieKills = 0
              end
              if look == nil then
               look = 0
               display = textCreateDisplay()
               textDisplayAddObserver (display,killer)
               kills = textCreateTextItem ("Kills: "..zombieKills,0.8,0.5,"medium",255,255,255,255,1.5)
               rank = textCreateTextItem ("Rank: "..myRank,0.8,0.53,"medium",255,255,255,255,1.5)
               textDisplayAddText (display,kills)
               textDisplayAddText (display,rank)
              elseif look == 0 then
               textItemSetText (kills,"Kills: "..zombieKills)
               textItemSetText (rank,"Rank: "..myRank)
               textItemSetText (kills,"Kills: "..zombieKills)
               textItemSetText (rank,"Rank: "..myRank)
              end
              if (getPlayerMoney(killer) >= 100000) then
               setAccountData (player,"Achievement: Million Dolar Man","true")
              end
              
              if achievement1 == true then
               if achievement2 == false then
                if achievement3 == false then
                   setAccountData(player,"Achievement: All Achievements","true")
                 end
                end
              end 
              
              if getAccountData(player,"Achievement: All Achievements") then
               setAccountData (player,"Permission to get out","true")
              end
              

              
              givePlayerMoney (killer, 25)
              setAccountData (player,"zombieKills",zombieKills+1)
              
              if (getAccountData (player,"zombieKills") == 10) then
                  setAccountData (player,"rank","Noob")
                  outputChatBox ("New rank! "..getPlayerName(killer).." is now a Noob. He has killed 10 zombies.")
                  outputChatBox ("Congratulations for your first rank! You get $500 as reward.",killer,0,255,0)
                  givePlayerMoney (killer,500)
              elseif (getAccountData (player,"zombieKills") == 100) then
                  setAccountData (player,"rank","Beginner")
                  outputChatBox ("New rank! "..getPlayerName(killer).." is now a Beginner. He has killed 100 zombies.")
                  outputChatBox ("Congratulations for your new rank! You get $1000 as reward.",killer,0,255,0)
                  givePlayerMoney (killer,1000)
              elseif (getAccountData (player,"zombieKills") == 1000) then
                  setAccountData (player,"rank","Medium")
                  outputChatBox ("New rank! "..getPlayerName(killer).." is now a Medium. He has killed 1000 zombies.")
                  outputChatBox ("Congratulations for your new rank! You get $5000 as reward.",killer,0,255,0)
                  givePlayerMoney (killer,5000)
              elseif (getAccountData (player,"zombieKills") == 10000) then
                  setAccountData (player,"rank","Experiencied")
                  outputChatBox ("New rank! "..getPlayerName(killer).." is now an Expert. He has killed 10000 zombies.")
                  outputChatBox ("Congratulations for your new rank! You get $50000 as reward.",killer,0,255,0)
                  givePlayerMoney (killer,50000)
              elseif (getAccountData (player,"zombieKills") == 100000) then
                  setAccountData (player,"rank","Assassin")
                  outputChatBox ("New rank! "..getPlayerName(killer).." is now an Assassin. He has killed 1000000 zombies.")
                  outputChatBox ("Congratulations for your new rank! You get $500000 as reward.",killer,0,255,0)
                  givePlayerMoney (killer,500000)
              elseif (getAccountData (player,"zombieKills") == 1000000) then
                  setAccountData (player,"rank","God")
                  outputChatBox ("New rank! "..getPlayerName(killer).." is now a God. He has killed one million zombies!!!")
                  outputChatBox ("Congratulations! You have reached last rank! You get one million of dolars as reward!",killer,0,255,0)
                  givePlayerMoney (killer,1000000)
              end
          end
      )