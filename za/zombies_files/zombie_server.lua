ZombieLimit = get("zombies.MaxZombies")-- HOW MANY ZOMBIES SHOULD EXIST AT MAXIMUM?
ZombieStreaming = get("zombies.StreamMethod") -- 1 to constantly stream zombies, 0 to only allow zombies to spawn via createZombie function, 2 to only allow spawning at set spawnpoints
ZombiePedSkins = {13,22,56,69,70,105,107,127,162,167,188,206,209,212,230,258,264,280,287 }
resourceRoot = getResourceRootElement()
moancount =0
moanlimit = 10

--IDLE BEHAVIOUR OF A ZOMBIE
function Zomb_Idle (ped)
	if isElement(ped) then
		if ( getElementData ( ped, "status" ) == "idle" ) and ( isPedDead ( ped ) == false ) and (getElementData (ped, "zombie") == true) then
			local action = math.random( 1, 6 )
			if action < 4 then -- walk a random direction
				local rdmangle = math.random( 1, 359 )
				setPedRotation( ped, rdmangle )
				setPedAnimation ( ped, "PED", "Player_Sneak", -1, true, true, true)
				setTimer ( Zomb_Idle, 7000, 1, ped )
			elseif action == 4 then -- get on the ground
				setPedAnimation ( ped, "MEDIC", "cpr", -1, false, true, true)
				setTimer ( Zomb_Idle, 4000, 1, ped )
			elseif action == 5 then -- stand still doing nothing
				setPedAnimation ( ped )
				setTimer ( Zomb_Idle, 4000, 1, ped )
			end
		end
	end
end

--BEHAVIOUR WHILE CHASING PLAYERS
function Zomb_chase (ped, Zx, Zy, Zz )
	if isElement(ped) then
		if (getElementData ( ped, "status" ) == "chasing") and (getElementData (ped, "zombie") == true) then
			local x, y, z = getElementPosition( ped )
			if (getElementData ( ped, "target" ) == nil) then
				local Px = getElementData ( ped, "Tx" )
				local Py = getElementData ( ped, "Ty" )
				local Pz = getElementData ( ped, "Tz" )
				local Pdistance = (getDistanceBetweenPoints3D( Px, Py, Pz, x, y, z ))
				if (Pdistance < 1.5 ) then
					setTimer ( function (ped) if ( isElement ( ped ) ) then setElementData ( ped, "status", "idle" ) end end, 2000, 1, ped )
				end
			end
			local distance = (getDistanceBetweenPoints3D( x, y, z, Zx, Zy, Zz ))			
			if (distance < 1 ) then -- IF THE PED HASNT MOVED
				if (getElementData ( ped, "target" ) == nil) then
					local giveup = math.random( 1, 15 )
					if giveup == 1 then
						setElementData ( ped, "status", "idle" )
					else
						local action = math.random( 1, 2 )
						if action == 1 then
							setPedAnimation ( ped )
							triggerClientEvent ( "Zomb_Punch", getRootElement(), ped )
							setTimer ( function (ped) if ( isElement ( ped ) ) then setPedAnimation ( ped, "ped", "run_old", -1, true, true, true ) end end, 800, 1, ped )
							setTimer ( Zomb_chase, 2000, 1, ped, x, y, z )
						elseif action == 2 then
							setPedAnimation ( ped )
							triggerClientEvent ( "Zomb_Jump", getRootElement(), ped )
							setTimer ( Zomb_chase, 3500, 1, ped, x, y, z )
						end
					end
				else 
					local Ptarget = (getElementData ( ped, "target" ))
					if isElement(Ptarget) then
						local Px, Py, Pz = getElementPosition( Ptarget )
						local Pdistance = (getDistanceBetweenPoints3D( Px, Py, Pz, Zx, Zy, Zz ))
						if (Pdistance < 1.2 ) then -- ATTACK A PLAYER IF THEY ARE CLOSE
							if ( isPedDead ( Ptarget ) ) then --EAT A DEAD PLAYER
								setPedAnimation ( ped )
								setPedAnimation ( ped, "MEDIC", "cpr", -1, false, true, false)
								setTimer ( function (ped) if ( isElement ( ped ) ) then setElementData ( ped, "status", "idle" ) end end, 10000, 1, ped )
								
							else
								local action = math.random( 1, 6 )
								if action == 1 then
									setPedAnimation ( ped)
									triggerClientEvent ( "Zomb_Jump", getRootElement(), ped )
									setTimer ( Zomb_chase, 2000, 1, ped, x, y, z )
								else
									setPedAnimation ( ped)
									triggerClientEvent ( "Zomb_Punch", getRootElement(), ped )
									setTimer ( function (ped) if ( isElement ( ped ) ) then setPedAnimation ( ped, "ped", "run_old", -1, true, true, true ) end end, 800, 1, ped )
									setTimer ( Zomb_chase, 2000, 1, ped, x, y, z )
								end
							end
						else
							if ( isPedDead (Ptarget) ) then
							setTimer ( function (ped) if ( isElement ( ped ) ) then setElementData ( ped, "status", "idle" ) end end, 2000, 1, ped )
							else
								local action = math.random( 1, 2 )
								if action == 1 then
									setPedAnimation ( ped)
									triggerClientEvent ( "Zomb_Punch", getRootElement(), ped )
									setTimer ( function (ped) if ( isElement ( ped ) ) then setPedAnimation ( ped, "ped", "run_old", -1, true, true, true ) end end, 800, 1, ped )
									setTimer ( Zomb_chase, 2000, 1, ped, x, y, z )
								elseif action == 2 then
									setPedAnimation ( ped)
									triggerClientEvent ( "Zomb_Jump", getRootElement(), ped )
									setTimer ( Zomb_chase, 2000, 1, ped, x, y, z )
								end
							end
						end
					else
						setElementData ( ped, "status", "idle" )
					end
				end
			else
				setPedAnimation ( ped, "ped", "run_old", -1, true, true, true) --KEEP WALKING
				setTimer ( Zomb_chase, 1000, 1, ped, x, y, z ) --CHECK AGAIN
			end
		end
	end
end

--SET THE DIRECTION OF THE ZOMBIE
function setangle ()
	local thezombies = getElementsByType ( "ped" )
	for theKey,ped in ipairs(thezombies) do
		if isElement(ped) then
			if (getElementData (ped, "zombie") == true) then
				if ( getElementData ( ped, "status" ) == "chasing" ) then
					if ( getElementData ( ped, "target" ) ~= nil ) then
						local ptarget = getElementData ( ped, "target" )
						if isElement(ptarget) then
							x, y, z = getElementPosition( ptarget )
							px, py, pz = getElementPosition( ped )
						else
							setElementData ( ped, "status", "idle" )
							x, y, z = getElementPosition( ped )
							px, py, pz = getElementPosition( ped )
						end
					elseif ( getElementData ( ped, "target" ) == nil ) then --IF THE PED IS AFTER THE PLAYERS LAST KNOWN WHEREABOUTS
						x = getElementData ( ped, "Tx" )
						y = getElementData ( ped, "Ty" )
						z = getElementData ( ped, "Tz" )
						px, py, pz = getElementPosition( ped )
					end
					zombangle = ( 360 - math.deg ( math.atan2 ( ( x - px ), ( y - py ) ) ) ) % 360 --MAGIC SPELL TO MAKE PEDS LOOK AT YOU
					setPedRotation( ped, zombangle )
				end
			end
		end
	end
end

--SETS THE ZOMBIE ACTIVITY WHEN STATUS CHANGES
addEventHandler ( "onElementDataChange", getRootElement(),
function ( dataName )
	if getElementType ( source ) == "ped" and dataName == "status" then
		if (getElementData (source, "zombie") == true) then
			if ( isPedDead ( source ) == false ) then
				if (getElementData ( source, "status" ) ==  "chasing" ) then
					local Zx, Zy, Zz = getElementPosition( source )
					setTimer ( Zomb_chase, 1000, 1, source, Zx, Zy, Zz )
					local newtarget = (getElementData ( source, "target" ))
					if isElement (newtarget) then
						if getElementType ( newtarget ) == "player" then
							setElementSyncer ( source, newtarget )
						end
					end
					if moancount < moanlimit then
						moancount = moancount+1
						local randnum = math.random( 1, 10 )
						triggerClientEvent ( "Zomb_Moan", getRootElement(), source, randnum )
						setTimer ( ReduceMoancount, 800, 1 )
					end
				elseif (getElementData ( source, "status" ) ==  "idle" ) then
					setTimer ( Zomb_Idle, 1000, 1, source)
				elseif (getElementData ( source, "status" ) ==  "throatslashing" ) then
					local tx,ty,tz = getElementPosition( source )
					local ptarget = getElementData ( source, "target" )
					if isElement(ptarget) then
						local vx,vy,vz = getElementPosition( ptarget )
						local zombdistance = (getDistanceBetweenPoints3D (tx, ty, tz, vx, vy, vz))
						if (zombdistance < .8) then
							setPedAnimation ( source, "knife", "KILL_Knife_Player", -1, false, false, true)
							setPedAnimation ( ptarget, "knife", "KILL_Knife_Ped_Damage", -1, false, false, true)
							setTimer ( Playerthroatbitten, 2300, 1, ptarget, source) 
							setTimer ( function (source) if ( isElement ( source ) ) then setElementData ( source, "status", "idle" ) end end, 5000, 1, source )
						else
							setElementData ( source, "status", "idle" )
						end
					else
						setElementData ( source, "status", "idle" )
					end
				end
			elseif (getElementData ( source, "status" ) ==  "dead" ) then
				setTimer ( Zomb_delete, 10000, 1, source)
			end
		end
	end
end)

--RESOURCE START/INITIAL SETUP
function outbreak(startedResource)
	local allplayers = getElementsByType ( "player" )
	for pKey,thep in ipairs(allplayers) do
		setElementData ( thep, "dangercount", 0 )
	end	
	newZombieLimit = get("" .. getResourceName(startedResource) .. ".Zlimit")
	if newZombieLimit ~= false then
		if newZombieLimit > ZombieLimit then 
			newZombieLimit = ZombieLimit
		end
	else
		newZombieLimit = ZombieLimit
	end
	MainTimer1 = setTimer ( setangle, 400, 0) -- KEEPS ZOMBIES FACING THE RIGHT DIRECTION
	WoodTimer = setTimer ( WoodSetup, 2000, 1) -- CHECKS FOR BARRIERS
	if ZombieStreaming == 1 then
		MainTimer2 = setTimer ( SpawnZombie, 2500, 0 ) --Spawns zombies in random locations
		MainTimer3 = setTimer ( clearFarZombies, 3000, 0) --KEEPS ALL THE ZOMBIES CLOSE TO PLAYERS	
	elseif ZombieStreaming == 2 then
		MainTimer2 = setTimer ( SpawnpointZombie, 2500, 0 ) --spawns zombies in zombie spawnpoints
		MainTimer3 = setTimer ( clearFarZombies, 3000, 0) --KEEPS ALL THE ZOMBIES CLOSE TO PLAYERS		
	end
end
addEventHandler("onResourceStart", getRootElement(), outbreak)

function player_Joined()
	setElementData ( source, "dangercount", 0 )
end
addEventHandler ( "onPlayerJoin", getRootElement(), player_Joined )

function WoodSetup()
	local allobjects = getElementsByType ( "object" ) --SETS UP ALL THE WOOD BARRIERS
	for objectKey, objectValue in ipairs(allobjects) do
		if ( getElementData ( objectValue, "purpose" ) =="zombiewood" ) then
			setElementDimension ( objectValue, 26 )
			local x,y,z = getElementPosition( objectValue )
			local thecol = createColSphere ( x, y, z, 1.6 )
			setElementData ( thecol, "purpose", "zombiewood" )
			setElementParent ( thecol, objectValue )
		end
	end	
end

function ReduceMoancount()
	moancount = moancount-1
end

function zombiestartup()
	call(getResourceFromName("scoreboard"), "addScoreboardColumn", "Zombie kills") --ADDS TO SCOREBOARD
end
addEventHandler("onResourceStart", resourceRoot, zombiestartup)

--CLEARS A DEAD ZOMBIE
function Zomb_delete (ped)
	if isElement(ped) then
		if (getElementData (ped, "zombie") == true) then
			destroyElement ( ped )
		end
	end
end

--HEADSHOTS
addEvent( "headboom", true )
function Zheadhit ( ped,attacker, weapon, bodypart)
	if (getElementData (ped, "zombie") == true) then
		killPed ( ped, attacker, weapon, bodypart )
		setPedHeadless  ( ped, true )
	end
end
addEventHandler( "headboom", getRootElement(), Zheadhit )

--KILL FROM ZOMBIE ATTACK
addEvent( "playereaten", true )
function Playerinfected ( player, attacker, weapon, bodypart)
    killPed ( player, attacker, weapon, bodypart )
end
addEventHandler( "playereaten", getRootElement(), Playerinfected )

--CHECKS FOR ZOMBIE GRABBING FROM BEHIND
function Playerthroatbitten ( player, attacker)
	local Zx, Zy, Zz = getElementPosition( attacker )
	local Px, Py, Pz = getElementPosition( player )
	local distance = (getDistanceBetweenPoints3D( Px, Py, Pz, Zx, Zy, Zz ))
	if (distance < 1) then
		killPed ( player, attacker, weapon, bodypart )
	else
		setPedAnimation (player)
	end
end

--ADJUSTS PLAYERS ZOMBIE KILL SCORE
function deanimated( ammo, attacker, weapon, bodypart )
	if (attacker) then
		if (getElementType ( attacker ) == "player") and (getElementType ( source ) == "ped") then
			if (getElementData (source, "zombie") == true) then
				local oldZcount = getElementData ( attacker, "Zombie kills" )
				setElementData ( attacker, "Zombie kills", oldZcount+1  )
				triggerEvent ( "onZombieWasted", source, attacker, weapon, bodypart )
			end
		end
	end
end
addEventHandler("onPedWasted", resourceRoot, deanimated)

--STUFF TO ALLOW PLAYERS TO PLACE BOARDS
function boarditup( player, key, keyState )
	local rightspot = 0
	local allcols = getElementsByType ( "colshape" )
	for ColKey,theCol in ipairs(allcols) do
		if (getElementData ( theCol, "purpose" ) == "zombiewood" ) then
			if (isElementWithinColShape ( player, theCol )) then
				local rightcol = theCol
				local Cx, Cy, Cz = getElementPosition( rightcol )
				local Bx, By, Bz = getElementPosition( player )
				woodangle = ( 360 - math.deg ( math.atan2 ( ( Cx - Bx ), ( Cy - By ) ) ) ) % 360
				setPedRotation( player, woodangle )
				setPedAnimation(player, "riot", "RIOT_PUNCHES", 3000, true, true, true )
				local wx, wy, wz = getElementPosition( player )
				setTimer( doneboarding, 2000, 1, player, rightcol, wx, wy, wz )
			end
		end
	end
end
addCommandHandler ( "construct", boarditup )
	
function doneboarding(player, rightcol, wx, wy, wz)
	setPedAnimation(player)
	local newx, newy, newz = getElementPosition( player )
	local distance = (getDistanceBetweenPoints3D( wx, wy, wz, newx, newy, newz ))			
	if (distance < .7 ) then
		newwood = getElementParent ( rightcol )
		setElementDimension ( newwood, 25 )
		setTimer( setElementDimension, 50, 1, newwood, 0)
	end
end


--SPAWN ZOMBIE (now can be cancelled!)

addEvent( "onZombieSpawn", true )
function RanSpawn_Z ( gx, gy, gz, rot)
	if ( not wasEventCancelled() ) then
		local allzombies = getElementsByType ( "ped" )
		if table.getn ( allzombies ) < newZombieLimit then
			if not rot then
				rot = math.random (1,359)
			end
			randomZskin = math.random ( 1, table.getn ( ZombiePedSkins ) )			
			local zomb = createPed( tonumber( ZombiePedSkins[randomZskin] ), gx, gy, gz )
			setElementData ( zomb, "zombie", true  )
			setTimer ( function (zomb) if ( isElement ( zomb ) ) then setElementData ( zomb, "zombie", true ) end end, 200, 1, zomb )
			setTimer ( function (zomb, rot) if ( isElement ( zomb ) ) then setPedRotation ( zomb, rot ) end end, 500, 1, zomb, rot )
			setTimer ( function (zomb) if ( isElement ( zomb ) ) then setPedAnimation ( zomb, "ped", "run_old", -1, true, true, true ) end end, 1000, 1, zomb )
			setTimer ( function (zomb) if ( isElement ( zomb ) ) then setElementData ( zomb, "status", "idle" ) end end, 3000, 1, zomb )
			triggerClientEvent ( "Zomb_STFU", getRootElement(), zomb )
		end
	end
end
addEventHandler( "onZombieSpawn", getRootElement(), RanSpawn_Z )


--SPAWNS ZOMBIES RANDOMLY NEAR PLAYERS
function SpawnZombie ()
	local pacecount = 0
	while pacecount < 6 do	--5 ZOMBIES AT A TIME TO PREVENT FPS DROP
		local allzombies = getElementsByType ( "ped" )
		if (table.getn( allzombies )+pacecount < newZombieLimit ) and (ZombieStreaming == 1) then	
			local xcoord = 0
			local ycoord = 0
			local xdirection = math.random(1,2)
			if xdirection == 1 then
				xcoord = math.random(15,40)
			else
				xcoord = math.random(-40,-15)
			end
			local ydirection = math.random(1,2)
			if ydirection == 1 then
				ycoord = math.random(15,40)
			else
				ycoord = math.random(-40,-15)
			end
			local liveplayers = getAlivePlayers ()
			if (table.getn( liveplayers ) > 0 ) then
				local lowestcount = 99999
				local lowestguy = nil
				for PKey,thePlayer in ipairs(liveplayers) do
					if (getElementData (thePlayer, "dangercount") < lowestcount) then
						lowestguy = thePlayer
						lowestcount = getElementData (thePlayer, "dangercount")
					end
				end
				pacecount = pacecount+1
				triggerClientEvent ( "Spawn_Placement", lowestguy, ycoord, xcoord )
			else
				pacecount = pacecount+1
			end
		else
			pacecount = pacecount+1
		end
	end
end

--SPAWNS ZOMBIES IN SPAWNPOINTS NEAR PLAYERS
function SpawnpointZombie ()
	local pacecount = 0
	while pacecount < 6 do	--5 ZOMBIES AT A TIME TO PREVENT FPS DROP
		local allzombies = getElementsByType ( "ped" )
		if (table.getn( allzombies )+pacecount < newZombieLimit ) and (ZombieStreaming == 2) then	
			local liveplayers = getAlivePlayers ()
			if (table.getn( liveplayers ) > 0 ) then
				local lowestcount = 99999
				local lowestguy = nil
				for PKey,thePlayer in ipairs(liveplayers) do --THIS PART GETS THE PLAYER WITH THE LEAST ZOMBIES ATTACKING
					if (getElementData (thePlayer, "dangercount") < lowestcount) then
						lowestguy = thePlayer
						lowestcount = getElementData (thePlayer, "dangercount")
					end
				end
				local zombiespawns = { }
				local possiblezombies = getElementsByType ( "Zombie_spawn" )
				local Px, Py, Pz = getElementPosition( lowestguy )
				for ZombKey,theZomb in ipairs(possiblezombies) do
					local Zx, Zy, Zz = getElementPosition( theZomb )
					local distance = (getDistanceBetweenPoints3D( Px, Py, Pz, Zx, Zy, Zz ))
					if (distance < 8) then
						table.remove( possiblezombies, ZombKey) --IF SPAWN IS TOO CLOSE TO ANY PLAYER
					end
				end
				local Px, Py, Pz = getElementPosition( lowestguy )
				for ZombKey2,theZomb2 in ipairs(possiblezombies) do
					local Zx, Zy, Zz = getElementPosition( theZomb2 )
					local distance = (getDistanceBetweenPoints3D( Px, Py, Pz, Zx, Zy, Zz ))
					if (distance < 60) then --AS LONG AS THE SPAWN IS CLOSE ENOUGH TO A PLAYER
						table.insert( zombiespawns, theZomb2 )
					end
				end
				if (table.getn( zombiespawns ) >0 ) then--IF THE LOWEST PLAYER HAS ANY CLOSE SPAWNS,USE ONE
					local random = math.random ( 1, table.getn ( zombiespawns ) )
					local posX = getElementData(zombiespawns[random], "posX") 
					local posY = getElementData(zombiespawns[random], "posY") 
					local posZ = getElementData(zombiespawns[random], "posZ")
					local rot = getElementData(zombiespawns[random], "rotZ")
					pacecount = pacecount+1
					triggerEvent ( "onZombieSpawn",zombiespawns[random], posX, posY, posZ, rot )			
				else--IF THE LOWEST PLAYERS DOESNT HAVE ANY SPAWNS, THEN SEE IF ANYONE HAS ANY
					local zombiespawns = { }
					local possiblezombies = getElementsByType ( "Zombie_spawn" )
					local allplayers = getAlivePlayers ()
					for theKey,thePlayer in ipairs(allplayers) do
						local Px, Py, Pz = getElementPosition( thePlayer )
						for ZombKey,theZomb in ipairs(possiblezombies) do
							local Zx, Zy, Zz = getElementPosition( theZomb )
							local distance = (getDistanceBetweenPoints3D( Px, Py, Pz, Zx, Zy, Zz ))
							if (distance < 8) then
								table.remove( possiblezombies, ZombKey) --IF SPAWN IS TOO CLOSE TO ANY PLAYER
							end
						end
					end
					for theKey,thePlayer in ipairs(allplayers) do
						local Px, Py, Pz = getElementPosition( thePlayer )
						for ZombKey2,theZomb2 in ipairs(possiblezombies) do
							local Zx, Zy, Zz = getElementPosition( theZomb2 )
							local distance = (getDistanceBetweenPoints3D( Px, Py, Pz, Zx, Zy, Zz ))
							if (distance < 60) then --AS LONG AS THE SPAWN IS CLOSE ENOUGH TO A PLAYER
								table.insert( zombiespawns, theZomb2 )
							end
						end
					end
					if (table.getn( zombiespawns ) >1 ) then
						local random = math.random ( 1, table.getn ( zombiespawns ) )
						local posX = getElementData(zombiespawns[random], "posX") 
						local posY = getElementData(zombiespawns[random], "posY") 
						local posZ = getElementData(zombiespawns[random], "posZ")
						local rot = getElementData(zombiespawns[random], "rotZ")
						pacecount = pacecount+1
						triggerEvent ( "onZombieSpawn",zombiespawns[random], posX, posY, posZ, rot )			
					else
						pacecount = pacecount+1
					end
				end
			else
				pacecount = pacecount+1
			end
		else
			pacecount = pacecount+1
		end
	end
end

--DELETES ZOMBIES THAT ARE TOO FAR FROM ANY PLAYERS TO KEEP THEM MORE CONCENTRATED WHILE STREAMING ZOMBIES
function clearFarZombies ()
	if newZombieLimit ~= false then
		local toofarzombies = { }
		local allzombies = getElementsByType ( "ped" )		
		local allplayers = getElementsByType ( "player" )
		for ZombKey,theZomb in ipairs(allzombies) do
			if (getElementData (theZomb, "zombie") == true) then
				far = 1
				local Zx, Zy, Zz = getElementPosition( theZomb )
				for theKey,thePlayer in ipairs(allplayers) do
					local Px, Py, Pz = getElementPosition( thePlayer )
					local distance = (getDistanceBetweenPoints3D( Px, Py, Pz, Zx, Zy, Zz ))
					if (distance < 75) then
						far = 0
					end
				end
				if far == 1 then
					table.insert( toofarzombies, theZomb )
				end
			end
		end
		if (table.getn( toofarzombies ) >1 ) then
			for ZombKey,theZomb in ipairs(toofarzombies) do
				if (getElementData (theZomb, "zombie") == true) then
					Zomb_delete (theZomb)
				end
			end
		end
	end
end

-- DESTROYS UP TO 13 ZOMBIES THAT ARE IDLE WHEN A PLAYER SPAWNS (TO FORCE NEW ZOMBIES TO SPAWN NEAR THE NEW GUY)
function player_Spawn ()
	if ZombieStreaming == 1 or ZombieStreaming == 2 then
		local allzombies = getElementsByType ( "ped" )
		local relocatecount = 0
		for ZombKey,theZomb in ipairs(allzombies) do
			if relocatecount < 14 then
				if ( getElementData ( theZomb, "status" ) == "idle" ) and ( isPedDead ( theZomb ) == false ) and (getElementData (theZomb, "zombie") == true) then
					relocatecount = relocatecount+1
					Zomb_delete (theZomb)
				end
			end
		end
	end
end
addEventHandler ( "onPlayerSpawn", getRootElement(), player_Spawn )

--EXPORTED FUNCTIONS!!!!!!!!!!!!!!
function createZombie ( x, y, z, rot, skin, interior, dimension )
	local allzombies = getElementsByType ( "ped" )
	if (table.getn( allzombies ) < newZombieLimit ) then
	--this part handles the args
		if not x then return false end
		if not y then return false end
		if not z then return false end
		if not rot then
			rot = math.random (1,359)
		end
		if not skin then
			skin = math.random ( 1, table.getn ( ZombiePedSkins ) )
		end
		if not interior then interior = 0 end
		if not dimension then dimension = 0 end
	--this part spawns the ped`
		local zomb = createPed (tonumber(skin),tonumber(x),tonumber(y),tonumber(z))--spawns the ped
	--if successful, this part applies the zombie settings/args
		if (zomb ~= false) then
			setTimer ( setElementInterior, 100, 1, zomb, tonumber(interior)) --sets interior
			setTimer ( setElementDimension, 100, 1, zomb, tonumber(dimension)) --sets dimension
			setElementData ( zomb, "zombie", true  )
			setTimer ( function (zomb) if ( isElement ( zomb ) ) then setElementData ( zomb, "zombie", true ) end end, 200, 1, zomb )
			setTimer ( function (zomb, rot) if ( isElement ( zomb ) ) then setPedRotation ( zomb, rot ) end end, 500, 1, zomb, rot )
			setTimer ( function (zomb) if ( isElement ( zomb ) ) then setElementData ( zomb, "status", "idle" ) end end, 3000, 1, zomb )
			triggerClientEvent ( "Zomb_STFU", getRootElement(), zomb )
			return zomb --returns the zombie element
		else
			return false --returns false if there was a problem
		end
	else
		return false --returns false if there was a problem
	end
end

--check if a ped is a zombie or not
function isPedZombie(ped)
	if (isElement(ped)) then
		if (getElementData (ped, "zombie") == true) then
			return true
		else
			return false
		end
	else
		return false
	end
end
