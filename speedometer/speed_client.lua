
g_root = getRootElement()
g_rootElement = getResourceRootElement( getThisResource() )
g_Player = getLocalPlayer()
g_units = "mph"
g_guiSpeed = { }
g_MaxSpeedInKMPH = { }

-----------------------------
function getActualVelocity( element, x, y, z )
	return (x^2 + y^2 + z^2) ^ 0.5
end

-----------------------------
function updateTheSpeed()
	local veh = getPlayerOccupiedVehicle( g_Player )
	if not veh then
		hideSpeedometer()
		return
	end

	local health = getElementHealth( veh )
	local healthbar_len = 0.54 * ( ( health-251 ) / 750 )
	if healthbar_len <= 0 then
		guiSetSize( g_guiSpeed.healthBar, 0.005, 0.1, true )
		guiSetPosition( g_guiSpeed.healthLine, 0.08, .4, true )
	else
		guiSetSize( g_guiSpeed.healthBar, healthbar_len, 0.1, true )
		guiSetPosition( g_guiSpeed.healthLine, healthbar_len+0.08, .4, true )
	end
	
	local speed = nil
	local speedbar_len = nil
	local max_speed
	if g_units == "mph" then
	    speed = getVehicleSpeed( veh, "mph" )
		max_speed = getVehicleMaxSpeed( veh, "mph" )
		if speed > max_speed then speedbar_len = 0.54 
		else speedbar_len = 0.54 * ( speed / max_speed )
		end
	else
	    speed = getVehicleSpeed( veh, "km/h" )
		max_speed = getVehicleMaxSpeed( veh, "km/h" )
		if speed > max_speed then speedbar_len = 0.54
	    else speedbar_len = 0.54 * ( speed / max_speed )
		end
	end

	if speedbar_len <= 0 then
		guiSetSize( g_guiSpeed.speedBar, 0.005, 0.1, true )
		guiSetPosition( g_guiSpeed.speedLine, 0.08, .6, true )
	else
		guiSetSize( g_guiSpeed.speedBar, speedbar_len, 0.1, true )
		guiSetPosition( g_guiSpeed.speedLine, speedbar_len+0.08, .6, true )
	end
	guiSetText( g_guiSpeed.units_lbl, g_units )
	guiSetText( g_guiSpeed.speed_lbl, tostring( speed ) )
end

-----------------------------
function showSpeedometer()
    if not g_guiSpeed.bg then
		g_guiSpeed.bg = guiCreateStaticImage( .75, .8, .2, .09, "images/speedometer_bg.png", true, g_guiSpeed.bg )
		--g_guiSpeed.door_open = guiCreateStaticImage( .07, .20, .2, .18, "images/door_open.png", true, g_guiSpeed.bg )
		--g_guiSpeed.door_closed = guiCreateStaticImage( .07, .20, .2, .18, "images/door_closed.png", true, g_guiSpeed.bg )
		--g_guiSpeed.lights_on = guiCreateStaticImage( .27, .20, .2, .18, "images/lights_on.png", true, g_guiSpeed.bg )
		--g_guiSpeed.lights_off = guiCreateStaticImage( .27, .20, .2, .18, "images/lights_off.png", true, g_guiSpeed.bg )
		g_guiSpeed.bgBar1 = guiCreateStaticImage( .07, .58, .56, .14, "images/black_dot.png", true, g_guiSpeed.bg )
		g_guiSpeed.bgBar2 = guiCreateStaticImage( .07, .38, .56, .14, "images/black_dot.png", true, g_guiSpeed.bg )
		g_guiSpeed.speedBar = guiCreateStaticImage( 0.08, .6, .01, .1, "images/green_dot.png", true, g_guiSpeed.bg )
		g_guiSpeed.healthBar = guiCreateStaticImage( 0.08, .4, .01, .1, "images/red_dot.png", true, g_guiSpeed.bg )
		g_guiSpeed.speedLine = guiCreateStaticImage( 0.08, .6, .01, .1, "images/yellow_dot.png", true, g_guiSpeed.bg )
		g_guiSpeed.healthLine = guiCreateStaticImage( 0.08, .4, .01, .1, "images/yellow_dot.png", true, g_guiSpeed.bg )
		g_guiSpeed.speed_lbl = guiCreateLabel( .66, .17, 1, 1, "0", true, g_guiSpeed.bg )
		g_guiSpeed.units_lbl = guiCreateLabel( .7, .46, 1, 1, g_units, true, g_guiSpeed.bg )
		if g_guiSpeed.speed_lbl then
			guiLabelSetColor( g_guiSpeed.speed_lbl, 0, 255, 0 )
		end
		if not g_guiSpeed.speedBar then
			outputChatBox( type( g_guiSpeed.speedBar ) )
		end
	end

	guiSetVisible( g_guiSpeed.bg, true )
--[[	if isVehicleLocked( getPlayerOccupiedVehicle( g_Player ) ) then
		guiSetVisible( g_guiSpeed.door_open, false )
	    guiSetVisible( g_guiSpeed.door_closed, true )
	else
	    guiSetVisible( g_guiSpeed.door_closed, false )
		guiSetVisible( g_guiSpeed.door_open, true )
	end
]]
	addEventHandler( "onClientRender", g_root, updateTheSpeed )
	--bindKey( "l", "down", changeLightsState )
	bindKey( "/", "down", changeUnits )
	--triggerServerEvent( "bindKeys", g_Player )
	--bindKey( ";", "down", lock_unlockDoor_iconchange )
end

-----------------------------
function hideSpeedometer()
	guiSetVisible( g_guiSpeed.bg, false )
	removeEventHandler( "onClientRender", g_root, updateTheSpeed )
	--unbindKey( "l", "down", changeLightsState )
	unbindKey( "/", "down", changeUnits )
	--triggerServerEvent( "unbindKeys", g_Player )
	--unbindKey( ";", "down", lock_unlockDoor_iconchange )
end

-----------------------------
--[[function changeLightsState()
	local veh = getPlayerOccupiedVehicle( g_Player )
	local lights = getVehicleOverrideLights( veh )
	if lights == 1 then
		setVehicleOverrideLights( veh, 2 )
	    guiSetVisible( g_guiSpeed.lights_off, false )
		guiSetVisible( g_guiSpeed.lights_on, true )
	   -- outputDebugString( "lights on" )
	else
		setVehicleOverrideLights( veh, 1 )
	    guiSetVisible( g_guiSpeed.lights_on, false )
		guiSetVisible( g_guiSpeed.lights_off, true )
	   -- outputDebugString( "lights off" )
	end
end]]

-----------------------------
function changeUnits( )
	if g_units == "mph" then g_units = "km/h"
	else g_units = "mph" end
end

-----------------------------
--[[function lock_unlockDoor_iconchange()
	local veh = getPlayerOccupiedVehicle( g_Player )
	local lock = isVehicleLocked( veh )
	if lock then
	    guiSetVisible( g_guiSpeed.door_closed, false )
		guiSetVisible( g_guiSpeed.door_open, true )
	else
		guiSetVisible( g_guiSpeed.door_open, false )
	    guiSetVisible( g_guiSpeed.door_closed, true )
	end
end]]

-----------------------------
addEventHandler( "onClientVehicleEnter", g_root,
	function( thePlayer )
		if thePlayer == g_Player then
			showSpeedometer()
		end
	end
)

-----------------------------
addEventHandler( "onClientVehicleStartExit", g_root,
	function( thePlayer )
		if thePlayer == g_Player then
			hideSpeedometer()
		end
	end
)

-----------------------------
addEventHandler( "onClientResourceStart", g_root,
	function ( )
		triggerServerEvent( "som_ClientResourceStarted", g_Player )
		if isPlayerInVehicle( g_Player ) then
			showSpeedometer()
		end
	end
)

-----------------------------
addEvent( "som_LoadVehsMaxSpeed", true )
addEventHandler( "som_LoadVehsMaxSpeed", g_root,
	function( max_speed_table )
		g_MaxSpeedInKMPH = max_speed_table
	end
)

-----------------------------
function getVehicleSpeed( vehicle, units )
	if getElementType( vehicle ) ~= "vehicle" then return false end
	if units == "km/h" or units == 1 then
		return math.floor( getActualVelocity( vehicle, getElementVelocity( vehicle ) ) * 161 )
	elseif units == "mph" or units == 0 or not units then
		return math.floor( getActualVelocity( vehicle, getElementVelocity( vehicle ) ) * 100 )
	end
end

-----------------------------
function getVehicleMaxSpeed( vehicle, units )
	if type( vehicle ) == "number" and ( vehicle >= 400 and vehicle <= 612 ) then
		local vehid = vehicle - 399
		if units == "mph" then return math.floor( g_MaxSpeedInKMPH[ vehid ] * 1.61 ) end
		return g_MaxSpeedInKMPH[ vehid ]
	elseif getElementType( vehicle ) ~= "vehicle" then
		return false
	elseif units == "km/h" or units == 1 then
		return g_MaxSpeedInKMPH[ getVehicleID( vehicle ) - 399 ]
	elseif units == "mph" or units == 0 or not units then
		return math.floor(g_MaxSpeedInKMPH[ getVehicleID( vehicle ) - 399 ] / 1.61 )
	end
end
