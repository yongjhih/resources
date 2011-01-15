myZombies = { }
--helmetzombies = { 27, 51, 52, 99, 27, 137, 153, 167, 205, 260, 277, 278, 279, 284, 285 }
helmetzombies = { 264,277,287 }
resourceRoot = getResourceRootElement()
ComboKillCount = 0
ComboKillReset = 3
myCombokill = { }

--FORCES ZOMBIES TO MOVE ALONG AFTER THEIR TARGET PLAYER DIES
function playerdead ()
	setTimer ( Zomb_release, 4000, 1 )
end
addEventHandler ( "onClientPlayerWasted", getLocalPlayer(), playerdead )

function Zomb_release ()
	for k, ped in pairs( myZombies ) do
		if (isElement(ped)) then
			if (getElementData (ped, "zombie") == true) then
				setElementData ( ped, "target", nil )
				setElementData ( ped, "status", "idle" )
				table.remove(myZombies,k)
			end
		end
	end
end

--REMOVES A ZOMBIE FROM INFLUENCE AFTER ITS KILLED
function pedkilled ( killer, weapon, bodypart )
	if (getElementData (source, "zombie") == true) and (getElementData (source, "status") ~= "dead" ) then
		setElementData ( source, "target", nil )
		setElementData ( source, "status", "dead" )
	end
end
addEventHandler ( "onClientPedWasted", getRootElement(), pedkilled )

--THIS CHECKS ALL ZOMBIES EVERY SECOND TO SEE IF THEY ARE IN SIGHT
function zombie_check ()
	if (getElementData (getLocalPlayer (), "zombie") ~= true) then
		local zombies = getElementsByType ( "ped" )
		local Px,Py,Pz = getElementPosition( getLocalPlayer () )
		if isPedDucked ( getLocalPlayer ()) then
			local Pz = Pz-1
		end		
		for theKey,theZomb in ipairs(zombies) do
			if (isElement(theZomb)) then
				if (getElementData (theZomb, "zombie") == true) then
					if ( getElementData ( theZomb, "status" ) == "idle" ) then --CHECKS IF AN IDLE ZOMBIE IS IN SIGHT
						local Zx,Zy,Zz = getElementPosition( theZomb )
						local isclear = isLineOfSightClear (Px, Py, Pz+1, Zx, Zy, Zz +1, true, false, false, true, false, false, false, false ) 
						local distance = (getDistanceBetweenPoints3D (Px, Py, Pz, Zx, Zy, Zz))
						if (isclear == true) and (distance < 45) and ( isPlayerDead ( getLocalPlayer () ) == false ) then
							isthere = "no"
							for k, ped in pairs( myZombies ) do
								if ped == theZomb then
									isthere = "yes"
								end
							end
							if isthere == "no" then
								setElementData ( theZomb, "status", "chasing" )
								setElementData ( theZomb, "target", getLocalPlayer () )
								table.insert( myZombies, theZomb ) --ADDS ZOMBIE TO PLAYERS COLLECTION
								zombieradiusalert (theZomb)
							end
						end
					elseif (getElementData(theZomb,"status") == "chasing") and (getElementData(theZomb,"target") == nil) then --CHECKS IF AN AGGRESSIVE LOST ZOMBIE IS IN SIGHT
						local Zx,Zy,Zz = getElementPosition( theZomb )
						local isclear = isLineOfSightClear (Px, Py, Pz+1, Zx, Zy, Zz +1, true, false, false, true, false, false, false, false) 
						local distance = (getDistanceBetweenPoints3D (Px, Py, Pz, Zx, Zy, Zz))
						if (isclear == true) and (distance < 45) and ( isPlayerDead ( getLocalPlayer () ) == false ) then
							setElementData ( theZomb, "target", getLocalPlayer () )
							isthere = "no"
							for k, ped in pairs( myZombies ) do
								if ped == theZomb then
									isthere = "yes"
								end
							end
							if isthere == "no" then
								table.insert( myZombies, theZomb ) --ADDS THE WAYWARD ZOMBIE TO THE PLAYERS COLLECTION
							end
						end
					elseif ( getElementData ( theZomb, "target" ) == getLocalPlayer () ) then --CHECKS IF AN ALREADY AGGRESSIVE ZOMBIE IS IN SIGHT
						local Zx,Zy,Zz = getElementPosition( theZomb )
						local isclear = isLineOfSightClear (Px, Py, Pz+1, Zx, Zy, Zz +1, true, false, false, true, false, false, false, false) 
						local distance = (getDistanceBetweenPoints3D (Px, Py, Pz, Zx, Zy, Zz))
						if (isclear == false) or (distance > 45) then --IF YOUR ZOMBIE LOST YOU, MAKES IT REMEMBER YOUR LAST COORDS
							setElementData ( theZomb, "target", nil )
							setElementData ( theZomb, "Tx", oldPx )
							setElementData ( theZomb, "Ty", oldPy )
							setElementData ( theZomb, "Tz", oldPz )
						end
					end
				else
					local thePed = theZomb
					local pedzombies = getElementsByType ( "ped" )
					local Ppx,Ppy,Ppz = getElementPosition(thePed)
					for theKey,thePedZomb in ipairs(pedzombies) do
						if (isElement(thePedZomb)) then
							if (getElementData (thePedZomb, "zombie") == true) then
								if ( getElementData ( thePedZomb, "status" ) == "idle" ) then --CHECKS IF AN IDLE ZOMBIE IS IN SIGHT
									local Zx,Zy,Zz = getElementPosition( thePedZomb )
									local isclear = isLineOfSightClear (Ppx, Ppy, Ppz+1, Zx, Zy, Zz +1, true, false, false, true, false, false, false, false ) 
									local distance = (getDistanceBetweenPoints3D (Ppx, Ppy, Ppz, Zx, Zy, Zz))
									if (isclear == true) and (distance < 45) and ( getElementHealth ( thePed) > 0) then
										setElementData ( thePedZomb, "status", "chasing" )
										setElementData ( thePedZomb, "target", theped )
										setElementData ( thePedZomb, "Tx", Ppx )
										setElementData ( thePedZomb, "Ty", Ppy )
										setElementData ( thePedZomb, "Tz", Ppz )
										zombieradiusalert (thePedZomb)
									end
								elseif ( getElementData ( thePedZomb, "status" ) == "chasing" ) and ( getElementData ( thePedZomb, "target" ) == nil) then --CHECKS IF AN AGGRESSIVE LOST ZOMBIE IS IN SIGHT OF THE PED
									local Zx,Zy,Zz = getElementPosition( thePedZomb )
									local isclear = isLineOfSightClear (Ppx, Ppy, Ppz+1, Zx, Zy, Zz +1, true, false, false, true, false, false, false, false) 
									local distance = (getDistanceBetweenPoints3D (Ppx, Ppy, Ppz, Zx, Zy, Zz))
									if (isclear == true) and (distance < 45) and ( getElementHealth ( thePed) > 0) then
										setElementData ( thePedZomb, "target", thePed )
										setElementData ( thePedZomb, "Tx", Ppx )
										setElementData ( thePedZomb, "Ty", Ppy )
										setElementData ( thePedZomb, "Tz", Ppz )
									end
								elseif ( getElementData ( thePedZomb, "target" ) == thePed ) then --CHECKS IF AN ALREADY AGGRESSIVE ZOMBIE IS IN SIGHT OF THE PED
									local Zx,Zy,Zz = getElementPosition( thePedZomb )
									local isclear = isLineOfSightClear (Ppx, Ppy, Ppz+1, Zx, Zy, Zz +1, true, false, false, true, false, false, false, false) 
									local distance = (getDistanceBetweenPoints3D (Ppx, Ppy, Ppz, Zx, Zy, Zz))
									if (isclear == false) or (distance > 45) then --IF YOUR ZOMBIE LOST THE PED, MAKES IT REMEMBER the peds LAST COORDS
										setElementData ( thePedZomb, "target", nil )
										setElementData ( thePedZomb, "Tx", Ppx )
										setElementData ( thePedZomb, "Ty", Ppy )
										setElementData ( thePedZomb, "Tz", Ppz )
									end
								end		
							end
						end
					end		
				end
			end
		end
		for k, ped in pairs( myZombies ) do
			if (isElement(ped) == false) then
				table.remove( myZombies, k)
			end
		end
	end
	oldPx,oldPy,oldPz = getElementPosition( getLocalPlayer () )
end

--INITAL SETUP
function clientoutbreak()
	MainClientTimer1 = setTimer ( zombie_check, 1000, 0)  --STARTS THE TIMER TO CHECK FOR ZOMBIES
end

function clientsetupstarter(startedresource)
	if startedresource == getThisResource() then
		setTimer ( clientsetup, 1234, 1)
	end
	setTimer ( clientoutbreak, 2222, 1)
end
addEventHandler("onClientResourceStart", getRootElement(), clientsetupstarter)

function clientsetup()
	oldPx,oldPy,oldPz = getElementPosition( getLocalPlayer () )
	throatcol = createColSphere ( 0, 0, 0, .2)
	setElementData ( getLocalPlayer(), "Zombie kills", 0 )	
	woodpic = guiCreateStaticImage( .65, .06, .1, .12, "zombiewood.png", true )
	guiSetVisible ( woodpic, false )

--ALL ZOMBIES STFU
	local zombies = getElementsByType ( "ped" )
	for theKey,theZomb in ipairs(zombies) do
		if (isElement(theZomb)) then
			if (getElementData (theZomb, "zombie") == true) then
				setPedVoice(theZomb, "PED_TYPE_DISABLED")
			end
		end
	end
	
--SKIN REPLACEMENTS
	local skin = engineLoadTXD ( "skins/13.txd" ) --bleedin eyes 31 by Slothman
	engineImportTXD ( skin, 13 )
	local skin = engineLoadTXD ( "skins/22.txd" ) -- slashed 12 by Wall-E
	engineImportTXD ( skin, 22 )	
	local skin = engineLoadTXD ( "skins/56.txd" ) --young and blue by Slothman
	engineImportTXD ( skin, 56 )
	local skin = engineLoadTXD ( "skins/68.txd" ) -- shredded preist by Deixell
	engineImportTXD ( skin, 68 )
	local skin = engineLoadTXD ( "skins/69.txd" ) --bleedin eyes in denim by Capitanazop
	engineImportTXD ( skin, 69 )
	local skin = engineLoadTXD ( "skins/70.txd" ) --ultra gory scientist by 50p
	engineImportTXD ( skin, 70 )
	local skin = engineLoadTXD ( "skins/84.txd" ) --guitar wolf (nonzombie) by Slothman
	engineImportTXD ( skin, 84 )
	local skin = engineLoadTXD ( "skins/92.txd" ) -- peeled flesh by xbost
	engineImportTXD ( skin, 92 )
	local skin = engineLoadTXD ( "skins/97.txd" ) -- easterboy by Slothman
	engineImportTXD ( skin, 97 )
	local skin = engineLoadTXD ( "skins/105.txd" ) --Scarred Grove Gangster by Wall-E
	engineImportTXD ( skin, 105 )
	local skin = engineLoadTXD ( "skins/107.txd" ) --ripped and slashed grove by Wall-E
	engineImportTXD ( skin, 107 )
	local skin = engineLoadTXD ( "skins/108.txd" ) -- skeleton thug by Deixell
	engineImportTXD ( skin, 108 )
	local skin = engineLoadTXD ( "skins/111.txd" ) --Frank West from dead rising (nonzombie) by Slothman
	engineImportTXD ( skin, 111 )
	local skin = engineLoadTXD ( "skins/127.txd" ) --flyboy from dawn of the dead by Slothman
	engineImportTXD ( skin, 127 )
	local skin = engineLoadTXD ( "skins/128.txd" ) --holy native by Slothman
	engineImportTXD ( skin, 128 )
	local skin = engineLoadTXD ( "skins/152.txd" ) --bitten schoolgirl by Slothman
	engineImportTXD ( skin, 152 )
	local skin = engineLoadTXD ( "skins/162.txd" ) --shirtless redneck by Slothman
	engineImportTXD ( skin, 162 )
	local skin = engineLoadTXD ( "skins/167.txd" ) --dead chickenman by 50p
	engineImportTXD ( skin, 167 )
	local skin = engineLoadTXD ( "skins/188.txd" ) --burnt greenshirt by Slothman
	engineImportTXD ( skin, 188 )
	local skin = engineLoadTXD ( "skins/192.txd" ) --Alice from resident evil (nonzombie) by Slothman
	engineImportTXD ( skin, 192 )
	local skin = engineLoadTXD ( "skins/206.txd" ) -- faceless zombie by Slothman
	engineImportTXD ( skin, 206 )
	local skin = engineLoadTXD ( "skins/209.txd" ) --Noodle vendor by 50p
	engineImportTXD ( skin, 209 )
	local skin = engineLoadTXD ( "skins/212.txd" ) --brainy hobo by Slothman
	engineImportTXD ( skin, 212 )
	local skin = engineLoadTXD ( "skins/229.txd" ) --infected tourist by Slothman
	engineImportTXD ( skin, 229 )
	local skin = engineLoadTXD ( "skins/230.txd" ) --will work for brains hobo by Slothman
	engineImportTXD ( skin, 230 )
	local skin = engineLoadTXD ( "skins/258.txd" ) --bloody sided suburbanite by Slothman
	engineImportTXD ( skin, 258 )
	local skin = engineLoadTXD ( "skins/264.txd" ) --scary clown by 50p
	engineImportTXD ( skin, 264 )
	local skin = engineLoadTXD ( "skins/274.txd" ) --Ash Williams (nonzombie) by Slothman
	engineImportTXD ( skin, 274 )
	local skin = engineLoadTXD ( "skins/277.txd" ) -- gutted firefighter by Wall-E
	engineImportTXD ( skin, 277 )
	local skin = engineLoadTXD ( "skins/280.txd" ) --infected cop by Lordy
	engineImportTXD ( skin, 280 )
	local skin = engineLoadTXD ( "skins/287.txd" ) --torn army by Deixell
	engineImportTXD ( skin, 287 )
	setTimer( initializeComboKill, 1000, 1)
end

--UPDATES PLAYERS COUNT OF AGGRESIVE ZOMBIES
addEventHandler ( "onClientElementDataChange", getRootElement(),
function ( dataName )
	if getElementType ( source ) == "ped" and dataName == "status" then
		local thestatus = (getElementData ( source, "status" ))
		if (thestatus == "idle") or (thestatus == "dead") then		
			for k, ped in pairs( myZombies ) do
				if ped == source and (getElementData (ped, "zombie") == true) then
					setElementData ( ped, "target", nil )
					table.remove( myZombies, k)
					setElementData ( getLocalPlayer(), "dangercount", tonumber(table.getn( myZombies )) )
				end
			end
		end
	end
end )

--MAKES A ZOMBIE JUMP
addEvent( "Zomb_Jump", true )
function Zjump ( ped )
	if (isElement(ped)) then
		setPedControlState( ped, "jump", true )
		setTimer ( function (ped) if ( isElement ( ped ) ) then setPedControlState ( ped, "jump", false) end end, 800, 1, ped )
	end
end
addEventHandler( "Zomb_Jump", getRootElement(), Zjump )

--MAKES A ZOMBIE PUNCH
addEvent( "Zomb_Punch", true )
function Zpunch ( ped )
	if (isElement(ped)) then
		setPedControlState( ped, "fire", true )
		setTimer ( function (ped) if ( isElement ( ped ) ) then setPedControlState ( ped, "fire", false) end end, 800, 1, ped )
	end
end
addEventHandler( "Zomb_Punch", getRootElement(), Zpunch )

--MAKES A ZOMBIE STFU
addEvent( "Zomb_STFU", true )
function Zstfu ( ped )
	if (isElement(ped)) then
		setPedVoice(ped, "PED_TYPE_DISABLED")
	end
end
addEventHandler( "Zomb_STFU", getRootElement(), Zstfu )

--MAKES A ZOMBIE MOAN
addEvent( "Zomb_Moan", true )
function Zmoan ( ped, randnum )
	if (isElement(ped)) then
		local Zx,Zy,Zz = getElementPosition( ped )
		local sound = playSound3D("sounds/mgroan"..randnum..".ogg", Zx, Zy, Zz, false)
		setSoundMaxDistance(sound, 20)
	end
end
addEventHandler( "Zomb_Moan", getRootElement(), Zmoan )

--ZOMBIE HEADSHOTS TO ALL BUT HELMETED ZOMBIES
function zombiedamaged ( attacker, weapon, bodypart )
	if getElementType ( source ) == "ped" then
		if (getElementData (source, "zombie") == true) then
			if ( bodypart == 9 ) then
				helmeted = "no"
				local zskin = getElementModel ( source )
				for k, skin in pairs( helmetzombies ) do
					if skin == zskin then
						helmeted = "yes"
					end
				end
				if helmeted == "no" then
					triggerServerEvent ("headboom", source, source, attacker, weapon, bodypart )
				end
			end
		end
	end
end
addEventHandler ( "onClientPedDamage", getRootElement(), zombiedamaged )

function zombiedkilled(killer, weapon, bodypart)
	if getElementType ( source ) == "ped" then
		if (getElementData (source, "zombie") == true) then
			setElementCollisionsEnabled(source, false)
		end
	end
end
addEventHandler ( "onClientPedWasted", getRootElement(), zombiedkilled )

--CAUSES MORE DAMAGE TO PLAYER WHEN ATTACKED BY A ZOMBIE
function zombieattack ( attacker, weapon, bodypart )
	if (attacker) then
		if getElementType ( attacker ) == "ped" then
			if (getElementData (attacker, "zombie") == true) then
				local playerHealth = getElementHealth ( getLocalPlayer() )
				if playerHealth > 15 then
					setElementHealth ( source, playerHealth - 15 )
				else
					triggerServerEvent ("playereaten", source, source, attacker, weapon, bodypart )
				end
			end
		end
	end
end
addEventHandler ( "onClientPlayerDamage", getLocalPlayer(), zombieattack )

--WOOD GUI
function showwoodpic ( theElement, matchingDimension )
	if ( theElement == getLocalPlayer() ) and (getElementData ( source, "purpose" ) == "zombiewood" ) then
		guiSetVisible ( woodpic, true )
	end
end
addEventHandler ( "onClientColShapeHit", getRootElement(), showwoodpic )

function hidewoodpic ( theElement, matchingDimension )
	if ( theElement == getLocalPlayer() ) and (getElementData ( source, "purpose" ) == "zombiewood" ) then
		guiSetVisible ( woodpic, false )
	end
end
addEventHandler ( "onClientColShapeLeave", getRootElement(), hidewoodpic )

--ZOMBIES ATTACK FROM BEHIND STUFF
function movethroatcol ()
	if isElement(throatcol) then
		local playerrot = getPedRotation ( getLocalPlayer () )
		local radRot = math.rad ( playerrot )
		local radius = 1
		local px,py,pz = getElementPosition( getLocalPlayer () )
		local tx = px + radius * math.sin(radRot)
		local ty = py + -(radius) * math.cos(radRot)
		local tz = pz
		setElementPosition ( throatcol, tx, ty, tz )
	end
end
addEventHandler ( "onClientRender", getRootElement(), movethroatcol )

function choketheplayer ( theElement, matchingDimension )
	if getElementType ( theElement ) == "ped" and ( isPlayerDead ( getLocalPlayer () ) == false ) then
        if ( getElementData ( theElement, "target" ) == getLocalPlayer () ) and (getElementData (theElement, "zombie") == true) then
			local px,py,pz = getElementPosition( getLocalPlayer () )
			setTimer ( checkplayermoved, 600, 1, theElement, px, py, pz)
		end
    end
end
addEventHandler ( "onClientColShapeHit", getRootElement(), choketheplayer )

function checkplayermoved (zomb, px, py, pz)
	if (isElement(zomb)) then
		local nx,ny,nz = getElementPosition( getLocalPlayer () )
		local distance = (getDistanceBetweenPoints3D (px, py, pz, nx, ny, nz))
		if (distance < .7) and ( isPlayerDead ( getLocalPlayer () ) == false ) then
			setElementData ( zomb, "status", "throatslashing" )
		end
	end
end

--ALERTS ANY IDLE ZOMBIES WITHIN A RADIUS OF 10 WHEN GUNSHOTS OCCUR OR OTHER ZOMBIES GET ALERTED
function zombieradiusalert (theElement)
	local Px,Py,Pz = getElementPosition( theElement )
	local zombies = getElementsByType ( "ped" )
	for theKey,theZomb in ipairs(zombies) do
		if (isElement(theZomb)) then
			if (getElementData (theZomb, "zombie") == true) then
				if ( getElementData ( theZomb, "status" ) == "idle" ) then
					local Zx,Zy,Zz = getElementPosition( theZomb )
					local distance = (getDistanceBetweenPoints3D (Px, Py, Pz, Zx, Zy, Zz))
					if (distance < 10) and ( isPlayerDead ( getLocalPlayer () ) == false ) then
						isthere = "no"
						for k, ped in pairs( myZombies ) do
							if ped == theZomb then
								isthere = "yes"
							end
						end
						if isthere == "no" and (getElementData (getLocalPlayer (), "zombie") ~= true) then
							if (getElementType ( theElement ) == "ped") then
								local isclear = isLineOfSightClear (Px, Py, Pz, Zx, Zy, Zz, true, false, false, true, false, false, false, false) 
								if (isclear == true) then
									setElementData ( theZomb, "status", "chasing" )
									setElementData ( theZomb, "target", getLocalPlayer () )
									table.insert( myZombies, theZomb ) --ADDS ZOMBIE TO PLAYERS COLLECTION
								end
							else
								setElementData ( theZomb, "status", "chasing" )
								setElementData ( theZomb, "target", getLocalPlayer () )
								table.insert( myZombies, theZomb ) --ADDS ZOMBIE TO PLAYERS COLLECTION
							end
						end
					end
				end
			end
		end
	end
end

function shootingnoise ( weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElement)
	if alertspacer ~= 1 then
		if (weapon == 9) then
			alertspacer = 1
			setTimer ( resetalertspacer, 5000, 1 )
			zombieradiusalert(getLocalPlayer ())
		elseif (weapon > 21) and (weapon ~= 23) then
			alertspacer = 1
			setTimer ( resetalertspacer, 5000, 1 )
			zombieradiusalert(getLocalPlayer ())
		end
	end
	if hitElement then
		if (getElementType ( hitElement ) == "ped") then
			if (getElementData (hitElement, "zombie") == true) then			
				isthere = "no"
				for k, ped in pairs( myZombies ) do
					if ped == hitElement then
						isthere = "yes"
					end
				end
				if isthere == "no" and (getElementData (getLocalPlayer (), "zombie") ~= true) then
					setElementData ( hitElement, "status", "chasing" )
					setElementData ( hitElement, "target", getLocalPlayer () )
					table.insert( myZombies, hitElement ) --ADDS ZOMBIE TO PLAYERS COLLECTION
					zombieradiusalert (hitElement)
				end
			end
		end
	end
end
addEventHandler ( "onClientPlayerWeaponFire", getLocalPlayer (), shootingnoise )

function resetalertspacer ()
	alertspacer = nil
end

function choketheplayer ( theElement, matchingDimension )
	if getElementType ( theElement ) == "ped" and ( isPlayerDead ( getLocalPlayer () ) == false ) and (getElementData (theElement , "zombie") == true) then
        if ( getElementData ( theElement, "target" ) == getLocalPlayer () ) then
			local px,py,pz = getElementPosition( getLocalPlayer () )
			setTimer ( checkplayermoved, 600, 1, theElement, px, py, pz)
		end
    end
end
addEventHandler ( "onClientPlayerJoin", getRootElement(), choketheplayer )

addEvent( "Spawn_Placement", true )
function Spawn_Place(xcoord, ycoord)
	local x,y,z = getElementPosition( getLocalPlayer() )
	local posx = x+xcoord
	local posy = y+ycoord
	local gz = getGroundPosition ( posx, posy, z+500 )
	triggerServerEvent ("onZombieSpawn", getLocalPlayer(), posx, posy, gz+1 )
end
addEventHandler("Spawn_Placement", getRootElement(), Spawn_Place)



function createText ( )
	local screenWidth, screenHeight = guiGetScreenSize()
	local dcount = tostring(table.getn( myZombies ))
	dxDrawText( dcount, screenWidth-40, 1, screenWidth, screenHeight, tocolor ( 0, 0, 0, 255 ), 1.44, "pricedown" )    -- Draw Zone Name text shadow.
	dxDrawText( dcount, screenWidth-42, 3, screenWidth, screenHeight, tocolor ( 255, 255, 255, 255 ), 1.4, "pricedown" ) -- Draw Zone Name text.
	local StrComboKillCount = tostring(ComboKillCount)
	dxDrawText( StrComboKillCount, screenWidth-160, 1, screenWidth, screenHeight, tocolor ( 0, 0, 0, 255 ), 1.44, "pricedown" )    -- Draw Zone Name text shadow.
	dxDrawText( StrComboKillCount, screenWidth-168, 3, screenWidth, screenHeight, tocolor ( 255, 255, 255, 255 ), 1.4, "pricedown" ) -- Draw Zone Name text.
end
addEventHandler("onClientRender",getRootElement(), createText)

addEvent( "onZombieWasted", true )
function comboKill ( ammo, attacker, weapon, bodypart )
	ComboKillCount = ComboKillCount+1
	triggerEvent ( "onClientRender", createText )
	ComboKillReset = 3
end
addEventHandler("onZombieWasted", getRootElement(), comboKill )

function initializeComboKill( )
	ComboKillReset = ComboKillReset-1
	if (ComboKillReset == 0) then
		ComboKillCount = 0
	end
	triggerEvent ( "onClientRender", createText )
	setTimer( initializeComboKill, 1000, 1)
end

