function getPlayerFightStyle ( thePlayer, commandName )

        local playerstyle = getPlayerFightingStyle ( thePlayer )   -- store the fighting style in a variable
        outputChatBox ( tostring(playerstyle), thePlayer )         -- output it to the player
end
addCommandHandler ( "style", getPlayerFightStyle )

function consoleSetFightingStyle ( thePlayer, commandName, id )

        if ( thePlayer and id ) then                                                 -- If player and ID are specified
                local status = setPlayerFightingStyle ( thePlayer, tonumber(id) )    -- set the fighting style
                if ( not status ) then                                               -- if that failed
                        outputConsole ( "Failed to set fighting style.", thePlayer ) -- show a message
                end
        end
end
addCommandHandler ( "setstyle",  consoleSetFightingStyle )