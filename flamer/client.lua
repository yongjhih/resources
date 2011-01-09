function scriptCreateFire ( commandName )
      local luckyBugger = getLocalPlayer() -- get the local player
      local x, y, z = getElementPosition ( luckyBugger ) -- retrive the player's position
      createFire ( x + 5 , y, z , 20) -- create the fire in the player's position but with x +5
end
--Attach the 'scriptCreateFire' function to the "flame" command
addCommandHandler ( "flame", scriptCreateFire ) -- /flame is the command to activate the script 