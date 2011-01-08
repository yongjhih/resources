--[[addEvent( "bindKeys", true )

addEventHandler( "bindKeys", getRootElement(),
	function(  )
	    local players = getElementsByType( "player" )
	    for k,player in ipairs( players ) do
	        if player == source then
				bindKey( player, ";", "down", lock_unlockDoor )
	        end
	    end
	end
)

-----------------------------
addEvent( "unbindKeys", true )

addEventHandler( "unbindKeys", getRootElement(),
	function(  )
	    local players = getElementsByType( "player" )
	    for k,player in ipairs( players ) do
	        if player == source then
				unbindKey( player, ";", "down", lock_unlockDoor )
	        end
	    end
	end
)


-----------------------------
function lock_unlockDoor( player )
	local veh = getPlayerOccupiedVehicle( player )
	local lock = isVehicleLocked( veh )
	if veh and lock == false then
	    setVehicleLocked( veh, true )
	    --outputDebugString( getClientName( player ).." LOCKed his car" )
	elseif veh and lock == true then
	    setVehicleLocked( veh, false )
	    --outputDebugString( getClientName( player ).." OPENed his car" )
	end
end

]]

-----------------------------
local g_MaxVehSpeedInKMPH = { }
addEventHandler( "onResourceStart", getRootElement(), 
	function( theRes )
		if theRes == getThisResource() then
			local file = fileOpen( "handling.txt" )
			local buf
			if not fileIsEOF( file ) then
				buf = fileRead( file, fileGetSize( file ) )
				local parts = Split( buf, "\n" )
				for k, v in ipairs( parts ) do
					g_MaxVehSpeedInKMPH[ k ] = tonumber( string.sub( parts[ k ], string.find( parts[ k ], "%d+", 75 ) ) )
				end
			end
			fileClose( file )
		end
	end
)

-----------------------------
addEvent( "som_ClientResourceStarted", true )
addEventHandler( "som_ClientResourceStarted", getRootElement(), 
	function()
		triggerClientEvent( source, "som_LoadVehsMaxSpeed", source, g_MaxVehSpeedInKMPH )
	end
)

-- function copied from: http://lua-users.org/wiki/StringRecipes
function Split(str, delim, maxNb)
    -- Eliminate bad cases...
    if string.find(str, delim) == nil then
        return { str }
    end
    if maxNb == nil or maxNb < 1 then
        maxNb = 0    -- No limit
    end
    local result = {}
    local pat = "(.-)" .. delim .. "()"
    local nb = 0
    local lastPos
    for part, pos in string.gfind(str, pat) do
        nb = nb + 1
        result[nb] = part
        lastPos = pos
        if nb == maxNb then break end
    end
    -- Handle the last field
    if nb ~= maxNb then
        result[nb + 1] = string.sub(str, lastPos)
    end
    return result
end
