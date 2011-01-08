CONTROL_MARGIN_RIGHT = 5
LINE_MARGIN = 5
LINE_HEIGHT = 16

g_Root = getRootElement()
g_ResRoot = getResourceRootElement(getThisResource())
g_Me = getLocalPlayer()
server = createServerCallInterface()

---------------------------
-- Set skin window
---------------------------
function skinInit()
	setControlNumber(wndSkin, 'skinid', getElementModel(g_Me))
end

function showSkinID(leaf)
	if leaf.id then
		setControlNumber(wndSkin, 'skinid', leaf.id)
	end
end

function applySkin()
	local skinID = getControlNumber(wndSkin, 'skinid')
	if skinID then
		server.setMySkin(skinID)
		fadeCamera(true)
	end
end

wndSkin = {
	'wnd',
	text = 'Set skin',
	width = 250,
	x = -20,
	y = 0.3,
	controls = {
		{
			'lst',
			id='skinlist',
			width=230,
			height=290,
			columns={
				{text='Skin', attr='name'}
			},
			rows={xml='skins.xml', attrs={'id', 'name'}},
			onitemclick=showSkinID,
			onitemdoubleclick=applySkin
		},
		{'txt', id='skinid', text='', width=50},
		{'btn', id='set', onclick=applySkin},
		{'btn', id='close', closeswindow=true}
	},
	oncreate = skinInit
}

function setSkinCommand(cmd, skin)
	skin = skin and tonumber(skin)
	if skin then
		server.setMySkin(skin)
		fadeCamera(true)
		closeWindow(wndSpawnMap)
		closeWindow(wndSetPos)
	end
end
addCommandHandler('setskin', setSkinCommand)
addCommandHandler('ss', setSkinCommand)

---------------------------
--- Set animation window
---------------------------

function applyAnimation(leaf)
	if type(leaf) ~= 'table' then
		leaf = getSelectedGridListLeaf(wndAnim, 'animlist')
		if not leaf then
			return
		end
	end
	server.setPedAnimation(g_Me, leaf.parent.name, leaf.name, true, true)
end

function stopAnimation()
	server.setPedAnimation(g_Me, false)
end

wndAnim = {
	'wnd',
	text = 'Set animation',
	width = 250,
	x = -20,
	y = 0.3,
	controls = {
		{
			'lst',
			id='animlist',
			width=230,
			height=290,
			columns={
				{text='Animation', attr='name'}
			},
			rows={xml='animations.xml', attrs={'name'}},
			expandlastlevel=false,
			onitemdoubleclick=applyAnimation
		},
		{'btn', id='set', onclick=applyAnimation},
		{'btn', id='stop', onclick=stopAnimation},
		{'btn', id='close', closeswindow=true}
	}
}

addCommandHandler('anim',
	function(command, lib, name)
		server.setPedAnimation(g_Me, lib, name, true, true)
	end
)

---------------------------
-- Weapon window
---------------------------

function addWeapon(leaf, amount)
	if type(leaf) ~= 'table' then
		leaf = getSelectedGridListLeaf(wndWeapon, 'weaplist')
		amount = getControlNumber(wndWeapon, 'amount')
		if not amount or not leaf then
			return
		end
	end
	server.giveMeWeapon(leaf.id, amount)
end

wndWeapon = {
	'wnd',
	text = 'Give weapon',
	width = 250,
	controls = {
		{
			'lst',
			id='weaplist',
			width=230,
			height=280,
			columns={
				{text='Weapon', attr='name'}
			},
			rows={xml='weapons.xml', attrs={'id', 'name'}},
			onitemdoubleclick=function(leaf) addWeapon(leaf, 500) end
		},
		{'br'},
		{'txt', id='amount', text='500', width=60},
		{'btn', id='add', onclick=addWeapon},
		{'btn', id='close', closeswindow=true}
	}
}

function giveWeaponCommand(cmd, weapon, amount)
	weapon = tonumber(weapon) or getWeaponIDFromName(weapon)
	if not weapon then
		return
	end
	amount = amount and tonumber(amount) or 500
	server.giveMeWeapon(weapon, amount)
end
addCommandHandler('give', giveWeaponCommand)
addCommandHandler('wp', giveWeaponCommand)

---------------------------
-- Fighting style
---------------------------

addCommandHandler('setstyle',
	function(cmd, style)
		style = style and tonumber(style)
		if style then
			server.setPedFightingStyle(g_Me, style)
		end
	end
)

---------------------------
-- Clothes window
---------------------------
function clothesInit()
	if getElementModel(g_Me) ~= 0 then
		errMsg('You must have the CJ skin set in order to apply clothes.')
		closeWindow(wndClothes)
		return
	end
	if not g_Clothes then
		triggerServerEvent('onClothesInit', g_Me)
	end
end

addEvent('onClientClothesInit', true)
addEventHandler('onClientClothesInit', g_Root,
	function(clothes)
		g_Clothes = clothes.allClothes
		for i,typeGroup in ipairs(g_Clothes) do
			for j,cloth in ipairs(typeGroup.children) do
				if not cloth.name then
					cloth.name = cloth.model .. ' - ' .. cloth.texture
				end
				cloth.wearing =
					clothes.playerClothes[typeGroup.type] and
					clothes.playerClothes[typeGroup.type].texture == cloth.texture and
					clothes.playerClothes[typeGroup.type].model == cloth.model
					or false
			end
			table.sort(typeGroup.children, function(a, b) return a.name < b.name end)
		end
		bindGridListToTable(wndClothes, 'clothes', g_Clothes, false)
	end
)

function clothListClick(cloth)
	setControlText(wndClothes, 'addremove', cloth.wearing and 'remove' or 'add')
end

function applyClothes(cloth)
	if not cloth then
		cloth = getSelectedGridListLeaf(wndClothes, 'clothes')
		if not cloth then
			return
		end
	end
	if cloth.wearing then
		cloth.wearing = false
		setControlText(wndClothes, 'addremove', 'add')
		server.removePlayerClothes(g_Me, cloth.parent.type)
	else
		local prevClothIndex = table.find(cloth.siblings, 'wearing', true)
		if prevClothIndex then
			cloth.siblings[prevClothIndex].wearing = false
		end
		cloth.wearing = true
		setControlText(wndClothes, 'addremove', 'remove')
		server.addPedClothes(g_Me, cloth.texture, cloth.model, cloth.parent.type)
	end
end

wndClothes = {
	'wnd',
	text = 'Clothes',
	x = -20,
	y = 0.3,
	width = 350,
	controls = {
		{
			'lst',
			id='clothes',
			width=330,
			height=390,
			columns={
				{text='Clothes', attr='name', width=0.6},
				{text='Wearing', attr='wearing', enablemodify=true, width=0.3}
			},
			rows={
				{name='Retrieving clothes list...'}
			},
			onitemclick=clothListClick,
			onitemdoubleclick=applyClothes
		},
		{'br'},
		{'btn', text='add', id='addremove', width=60, onclick=applyClothes},
		{'btn', id='close', closeswindow=true}
	},
	oncreate = clothesInit
}

function addClothesCommand(cmd, type, model, texture)
	type = type and tonumber(type)
	if type and model and texture then
		server.addPedClothes(g_Me, texture, model, type)
	end
end
addCommandHandler('addclothes', addClothesCommand)
addCommandHandler('ac', addClothesCommand)

function removeClothesCommand(cmd, type)
	type = type and tonumber(type)
	if type then
		server.removePlayerClothes(g_Me, type)
	end
end
addCommandHandler('removeclothes', removeClothesCommand)
addCommandHandler('rc', removeClothesCommand)

---------------------------
-- Player gravity window
---------------------------
function playerGravInit()
	triggerServerEvent('onPlayerGravInit', g_Me)
end

addEvent('onClientPlayerGravInit', true)
addEventHandler('onClientPlayerGravInit', g_Root,
	function(curgravity)
		setControlText(wndGravity, 'gravval', string.sub(tostring(curgravity), 1, 6))
	end
)

function selectPlayerGrav(leaf)
	setControlNumber(wndGravity, 'gravval', leaf.value)
end

function applyPlayerGrav()
	local grav = getControlNumber(wndGravity, 'gravval')
	if grav then
		server.setPedGravity(g_Me, grav)
	end
	closeWindow(wndGravity)
end

function setGravityCommand(cmd, grav)
	grav = grav and tonumber(grav)
	if grav then
		server.setPedGravity(g_Me, tonumber(grav))
	end
end
addCommandHandler('setgravity', setGravityCommand)
addCommandHandler('grav', setGravityCommand)

wndGravity = {
	'wnd',
	text = 'Set gravity',
	width = 300,
	controls = {
		{
			'lst',
			id='gravlist',
			width=280,
			height=200,
			columns={
				{text='Gravity', attr='name'}
			},
			rows={
				{name='Space', value=0},
				{name='Moon', value=0.001},
				{name='Normal', value=0.008},
				{name='Strong', value=0.015}
			},
			onitemclick=selectPlayerGrav,
			onitemdoubleclick=applyPlayerGrav
		},
		{'lbl', text='Exact value: '},
		{'txt', id='gravval', text='', width=80},
		{'br'},
		{'btn', id='ok', onclick=applyPlayerGrav},
		{'btn', id='cancel', closeswindow=true}
	},
	oncreate = playerGravInit
}

---------------------------
-- Warp to player window
---------------------------

function warpInit()
	local players = table.map(getElementsByType('player'), function(p) return { name = getPlayerName(p) } end)
	table.sort(players, function(a, b) return a.name < b.name end)
	bindGridListToTable(wndWarp, 'playerlist', players, true)
end

function warpTo(leaf)
	if not leaf then
		leaf = getSelectedGridListLeaf(wndWarp, 'playerlist')
		if not leaf then
			return
		end
	end
	local player = getPlayerFromNick(leaf.name)
	if player then
		server.warpMe(player)
	end
	closeWindow(wndWarp)
end

wndWarp = {
	'wnd',
	text = 'Warp to player',
	width = 300,
	controls = {
		{
			'lst',
			id='playerlist',
			width=280,
			height=330,
			columns={
				{text='Player', attr='name'}
			},
			onitemdoubleclick=warpTo
		},
		{'btn', id='warp', onclick=warpTo},
		{'btn', id='cancel', closeswindow=true}
	},
	oncreate = warpInit
}

function warpToCommand(cmd, player)
	if player then
		player = getPlayerFromNick(player)
		if player then
			server.warpMe(player)
		end
	else
		createWindow(wndWarp)
	end
end

addCommandHandler('warpto', warpToCommand)
addCommandHandler('wt', warpToCommand)

---------------------------
-- Stats window
---------------------------

function initStats()
	applyToLeaves(getGridListCache(wndStats, 'statslist'), function(leaf) leaf.value = getPedStat(g_Me, leaf.id) end)
end

function selectStat(leaf)
	setControlNumber(wndStats, 'statval', leaf.value)
end

function maxStat(leaf)
	setControlNumber(wndStats, 'statval', 1000)
	applyStat()
end

function applyStat()
	local leaf = getSelectedGridListLeaf(wndStats, 'statslist')
	if not leaf then
		return
	end
	local value = getControlNumber(wndStats, 'statval')
	if not value then
		return
	end
	leaf.value = value
	server.setPedStat(g_Me, leaf.id, value)
end

wndStats = {
	'wnd',
	text = 'Stats',
	width = 300,
	x = -20,
	y = 0.3,
	controls = {
		{
			'lst',
			id='statslist',
			width=280,
			columns={
				{text='Stat', attr='name', width=0.6},
				{text='Value', attr='value', width=0.3, enablemodify=true}
			},
			rows={xml='stats.xml', attrs={'name', 'id'}},
			onitemclick=selectStat,
			onitemdoubleclick=maxStat
		},
		{'txt', id='statval', text='', width=60},
		{'btn', id='set', onclick=applyStat},
		{'btn', id='close', closeswindow=true}
	},
	oncreate = initStats
}

---------------------------
-- Jetpack toggle
---------------------------
function toggleJetPack()
	if not doesPedHaveJetPack(g_Me) then
		server.givePedJetPack(g_Me)
		guiCheckBoxSetSelected(getControl(wndMain, 'jetpack'), true)
	else
		server.removePedJetPack(g_Me)
		guiCheckBoxSetSelected(getControl(wndMain, 'jetpack'), false)
	end
end

bindKey('j', 'down', toggleJetPack)

addCommandHandler('jetpack', toggleJetPack)
addCommandHandler('jp', toggleJetPack)


---------------------------
-- Fall off bike toggle
---------------------------
function toggleFallOffBike()
	setPedCanBeKnockedOffBike(g_Me, guiCheckBoxGetSelected(getControl(wndMain, 'falloff')))
end

---------------------------
-- Set position window
---------------------------
do
	local screenWidth, screenHeight = guiGetScreenSize()
	if screenHeight < 700 then
		g_MapSide = 450
	else
		g_MapSide = 700
	end
end

function setPosInit()
	local x, y, z = getElementPosition(g_Me)
	setControlNumbers(wndSetPos, { x = x, y = y, z = z })
	
	addEventHandler('onClientRender', g_Root, updatePlayerBlips)
end

function fillInPosition(relX, relY)
	local x = relX*6000 - 3000
	local y = 3000 - relY*6000
	local hit, hitX, hitY, hitZ
	hit, hitX, hitY, hitZ = processLineOfSight(x, y, 3000, x, y, -3000)
	setControlNumbers(wndSetPos, { x = x, y = y, z = hitZ or 0 })
end

function setPosClick()
	setPlayerPosition(getControlNumbers(wndSetPos, {'x', 'y', 'z'}))
	closeWindow(wndSetPos)
end

function setPlayerPosition(x, y, z)
	local elem = getPedOccupiedVehicle(g_Me)
	local distanceToGround
	local isVehicle
	if elem then
		if getPlayerOccupiedSeat(g_Me) ~= 0 then
			errMsg('Only the driver of the vehicle can set its position.')
			return
		end
		distanceToGround = getElementDistanceFromCentreOfMassToBaseOfModel(elem) + 3
		isVehicle = true
	else
		elem = g_Me
		distanceToGround = 0.4
		isVehicle = false
	end
	local hit, hitX, hitY, hitZ = processLineOfSight(x, y, 3000, x, y, -3000)
	if not hit then
		if isVehicle then
			server.fadeVehiclePassengersCamera(false)
		else
			fadeCamera(false)
		end
		setTimer(setCameraMatrix, 1000, 1, x, y, z)
		local grav = getGravity()
		setGravity(0.001)
		g_TeleportTimer = setTimer(
			function()
				local hit, groundX, groundY, groundZ = processLineOfSight(x, y, 3000, x, y, -3000)
				if hit then
					local waterZ = getWaterLevel(x, y, 100)
					z = (waterZ and math.max(groundZ, waterZ) or groundZ) + distanceToGround
					if isPlayerDead(g_Me) then
						server.spawnMe(x, y, z)
					else
						setElementPosition(elem, x, y, z)
					end
					setCameraPlayerMode()
					setGravity(grav)
					if isVehicle then
						server.fadeVehiclePassengersCamera(true)
					else
						fadeCamera(true)
					end
					killTimer(g_TeleportTimer)
					g_TeleportTimer = nil
				end
			end,
			500,
			0
		)
	else
		if isPlayerDead(g_Me) then
			server.spawnMe(x, y, z + distanceToGround)
		else
			setElementPosition(elem, x, y, z + distanceToGround)
			if isVehicle then
				setTimer(setElementVelocity, 100, 1, elem, 0, 0, 0)
				setTimer(setVehicleTurnVelocity, 100, 1, elem, 0, 0, 0)
			end
		end
	end
end

function updatePlayerBlips()
	if not g_PlayerData then
		return
	end
	local wnd = isWindowOpen(wndSpawnMap) and wndSpawnMap or wndSetPos
	local mapControl = getControl(wnd, 'map')
	for elem,player in pairs(g_PlayerData) do
		if not player.gui.mapBlip then
			player.gui.mapBlip = guiCreateStaticImage(0, 0, 9, 9, elem == g_Me and 'localplayerblip.png' or 'playerblip.png', false, mapControl)
			player.gui.mapLabelShadow = guiCreateLabel(0, 0, 100, 14, player.name, false, mapControl)
			local labelWidth = guiLabelGetTextExtent(player.gui.mapLabelShadow)
			guiSetSize(player.gui.mapLabelShadow, labelWidth, 14, false)
			guiSetFont(player.gui.mapLabelShadow, 'default-bold-small')
			guiLabelSetColor(player.gui.mapLabelShadow, 255, 255, 255)
			player.gui.mapLabel = guiCreateLabel(0, 0, labelWidth, 14, player.name, false, mapControl)
			guiSetFont(player.gui.mapLabel, 'default-bold-small')
			guiLabelSetColor(player.gui.mapLabel, 0, 0, 0)
			for i,name in ipairs({'mapBlip', 'mapLabelShadow'}) do
				addEventHandler('onClientGUIDoubleClick', player.gui[name],
					function()
						server.warpMe(elem)
						closeWindow(wnd)
					end,
					false
				)
			end
		end
		local x, y = getElementPosition(elem)
		x = math.floor((x + 3000) * g_MapSide / 6000) - 4
		y = math.floor((3000 - y) * g_MapSide / 6000) - 4
		guiSetPosition(player.gui.mapBlip, x, y, false)
		guiSetPosition(player.gui.mapLabelShadow, x + 14, y - 4, false)
		guiSetPosition(player.gui.mapLabel, x + 13, y - 5, false)
	end
end

addEventHandler('onClientPlayerChangeNick', g_Root,
	function(oldNick, newNick)
		local player = g_PlayerData[source]
		player.name = newNick
		if player.gui.mapLabel then
			guiSetText(player.gui.mapLabelShadow, newNick)
			guiSetText(player.gui.mapLabel, newNick)
			local labelWidth = guiLabelGetTextExtent(player.gui.mapLabelShadow)
			guiSetSize(player.gui.mapLabelShadow, labelWidth, 14, false)
			guiSetSize(player.gui.mapLabel, labelWidth, 14, false)
		end
	end
)

function closePositionWindow()
	removeEventHandler('onClientRender', g_Root, updatePlayerBlips)
end

wndSetPos = {
	'wnd',
	text = 'Set position',
	width = g_MapSide + 20,
	controls = {
		{'img', id='map', src='map.png', width=g_MapSide, height=g_MapSide, onclick=fillInPosition, ondoubleclick=setPosClick},
		{'txt', id='x', text='', width=60},
		{'txt', id='y', text='', width=60},
		{'txt', id='z', text='', width=60},
		{'btn', id='ok', onclick=setPosClick},
		{'btn', id='cancel', closeswindow=true}
	},
	oncreate = setPosInit,
	onclose = closePositionWindow
}

function getPosCommand(cmd, playerName)
	local player, sentenceStart
	
	if playerName then
		player = getPlayerFromNick(playerName)
		if not player then
			errMsg('There is no player named "' .. playerName .. '".')
			return
		end
		playerName = getPlayerName(player)		-- make sure case is correct
		sentenceStart = playerName .. ' is '
	else
		player = g_Me
		sentenceStart = 'You are '
	end
	
	local px, py, pz = getElementPosition(player)
	local vehicle = getPedOccupiedVehicle(player)
	if vehicle then
		outputChatBox(sentenceStart .. 'in a ' .. getVehicleName(vehicle), 0, 255, 0)
	else
		outputChatBox(sentenceStart .. 'on foot', 0, 255, 0)
	end
	outputChatBox(sentenceStart .. 'at (' .. px .. ', ' .. py .. ', ' .. pz .. ')', 0, 255, 0)
end
addCommandHandler('getpos', getPosCommand)
addCommandHandler('gp', getPosCommand)

function setPosCommand(cmd, x, y, z)
	local px, py, pz = getElementPosition(g_Me)
	if not x or x == '-' or not tonumber(x) then
		x = px
	end
	if not y or y == '-' or not tonumber(y) then
		y = py
	end
	if not z or z == '-' or not tonumber(z) then
		z = pz
	end
	setPlayerPosition(tonumber(x), tonumber(y), tonumber(z))
end
addCommandHandler('setpos', setPosCommand)
addCommandHandler('sp', setPosCommand)

---------------------------
-- Spawn map window
---------------------------
function warpMapInit()
	addEventHandler('onClientRender', g_Root, updatePlayerBlips)
end

function spawnMapDoubleClick(relX, relY)
	setPlayerPosition(relX*6000 - 3000, 3000 - relY*6000, 0)
	closeWindow(wndSpawnMap)
end

function closeSpawnMap()
	showCursor(false)
	removeEventHandler('onClientRender', g_Root, updatePlayerBlips)
	for elem,data in pairs(g_PlayerData) do
		for i,name in ipairs({'mapBlip', 'mapLabelShadow', 'mapLabel'}) do
			if data.gui[name] then
				destroyElement(data.gui[name])
				data.gui[name] = nil
			end
		end
	end
end

wndSpawnMap = {
	'wnd',
	text = 'Select spawn position',
	width = g_MapSide + 20,
	controls = {
		{'img', id='map', src='map.png', width=g_MapSide, height=g_MapSide, ondoubleclick=spawnMapDoubleClick},
		{'lbl', text='Welcome to freeroam. Double click a location on the map to spawn.', width=g_MapSide-60, align='center'},
		{'btn', id='close', closeswindow=true}
	},
	oncreate = warpMapInit,
	onclose = closeSpawnMap
}

---------------------------
-- Interior window
---------------------------

function setInterior(leaf)
	server.setElementInterior(g_Me, leaf.world)
	local vehicle = getPedOccupiedVehicle(g_Me)
	if vehicle then
		server.setElementInterior(vehicle, leaf.world)
		for i=0,getVehicleMaxPassengers(vehicle) do
			local player = getVehicleOccupant(vehicle, i)
			if player and player ~= g_Me then
				server.setElementInterior(player, leaf.world)
				server.setCameraInterior(player, leaf.world)
			end
		end
	end
	setCameraInterior(leaf.world)
	setPlayerPosition(leaf.posX, leaf.posY, leaf.posZ + 1)
	closeWindow(wndSetInterior)
end

wndSetInterior = {
	'wnd',
	text = 'Set interior',
	width = 250,
	controls = {
		{
			'lst',
			id='interiors',
			width=230,
			height=300,
			columns={
				{text='Interior', attr='name'}
			},
			rows={xml='interiors.xml', attrs={'name', 'posX', 'posY', 'posZ', 'world'}},
			onitemdoubleclick=setInterior
		},
		{'btn', id='close', closeswindow=true}
	}
}

---------------------------
-- Create vehicle window
---------------------------
function createSelectedVehicle(leaf)
	if not leaf then
		leaf = getSelectedGridListLeaf(wndCreateVehicle, 'vehicles')
		if not leaf then
			return
		end
	end
	server.giveMeVehicles(leaf.id)
end

wndCreateVehicle = {
	'wnd',
	text = 'Create vehicle',
	width = 300,
	controls = {
		{
			'lst',
			id='vehicles',
			width=280,
			height=340,
			columns={
				{text='Vehicle', attr='name'}
			},
			rows={xml='vehicles.xml', attrs={'id', 'name'}},
			onitemdoubleclick=createSelectedVehicle
		},
		{'btn', id='create', onclick=createSelectedVehicle},
		{'btn', id='close', closeswindow=true}
	}
}

function createVehicleCommand(cmd, ...)
	local vehID
	local vehiclesToCreate = {}
	local args = { ... }
	for i,v in ipairs(args) do
		vehID = tonumber(v)
		if not vehID then
			vehID = getVehicleModelFromName(v)
		end
		if vehID then
			table.insert(vehiclesToCreate, vehID)
		end
	end
	server.giveMeVehicles(vehiclesToCreate)
end
addCommandHandler('createvehicle', createVehicleCommand)
addCommandHandler('cv', createVehicleCommand)

---------------------------
-- Repair vehicle
---------------------------
function repairVehicle()
	local vehicle = getPedOccupiedVehicle(g_Me)
	if vehicle then
		server.fixVehicle(vehicle)
	end
end

addCommandHandler('repair', repairVehicle)
addCommandHandler('rp', repairVehicle)

---------------------------
-- Flip vehicle
---------------------------
function flipVehicle()
	local vehicle = getPedOccupiedVehicle(g_Me)
	if vehicle then
		local rX, rY, rZ = getElementRotation(vehicle)
		server['set' .. 'VehicleRotation'](vehicle, 0, 0, (rX > 90 and rX < 270) and (rZ + 180) or rZ)
	end
end

addCommandHandler('flip', flipVehicle)
addCommandHandler('f', flipVehicle)

---------------------------
-- Vehicle upgrades
---------------------------
function upgradesInit()
	local vehicle = getPedOccupiedVehicle(g_Me)
	if not vehicle then
		errMsg('Please enter a vehicle to change the upgrades of.')
		closeWindow(wndUpgrades)
		return
	end
	local installedUpgrades = getVehicleUpgrades(vehicle)
	local compatibleUpgrades = {}
	local slotName, group
	for i,upgrade in ipairs(getVehicleCompatibleUpgrades(vehicle)) do
		slotName = getVehicleUpgradeSlotName(upgrade)
		group = table.find(compatibleUpgrades, 'name', slotName)
		if not group then
			group = { 'group', name = slotName, children = {} }
			table.insert(compatibleUpgrades, group)
		else
			group = compatibleUpgrades[group]
		end
		table.insert(group.children, { id = upgrade, installed = table.find(installedUpgrades, upgrade) ~= false })
	end
	table.sort(compatibleUpgrades, function(a, b) return a.name < b.name end)
	bindGridListToTable(wndUpgrades, 'upgradelist', compatibleUpgrades, true)
end

function selectUpgrade(leaf)
	setControlText(wndUpgrades, 'addremove', leaf.installed and 'remove' or 'add')
end

function addRemoveUpgrade(selUpgrade)
	-- Add or remove selected upgrade
	local vehicle = getPedOccupiedVehicle(g_Me)
	if not vehicle then
		return
	end
	
	if not selUpgrade then
		selUpgrade = getSelectedGridListLeaf(wndUpgrades, 'upgradelist')
		if not selUpgrade then
			return
		end
	end
	
	if selUpgrade.installed then
		-- remove upgrade
		selUpgrade.installed = false
		setControlText(wndUpgrades, 'addremove', 'add')
		server.removeVehicleUpgrade(vehicle, selUpgrade.id)
	else
		-- add upgrade
		local prevUpgradeIndex = table.find(selUpgrade.siblings, 'installed', true)
		if prevUpgradeIndex then
			selUpgrade.siblings[prevUpgradeIndex].installed = false
		end
		selUpgrade.installed = true
		setControlText(wndUpgrades, 'addremove', 'remove')
		server.addVehicleUpgrade(vehicle, selUpgrade.id)
	end
end

wndUpgrades = {
	'wnd',
	text = 'Vehicle upgrades',
	width = 300,
	x = -20,
	y = 0.3,
	controls = {
		{
			'lst',
			id='upgradelist',
			width=280,
			height=340,
			columns={
				{text='Upgrade', attr='id', width=0.6},
				{text='Installed', attr='installed', width=0.3, enablemodify=true}
			},
			onitemclick=selectUpgrade,
			onitemdoubleclick=addRemoveUpgrade
		},
		{'btn', id='addremove', text='add', width=60, onclick=addRemoveUpgrade},
		{'btn', id='ok', closeswindow=true}
	},
	oncreate = upgradesInit
}

function addUpgradeCommand(cmd, upgrade)
	local vehicle = getPedOccupiedVehicle(g_Me)
	if vehicle and upgrade then
		server.addVehicleUpgrade(vehicle, tonumber(upgrade) or 0)
	end
end
addCommandHandler('addupgrade', addUpgradeCommand)
addCommandHandler('au', addUpgradeCommand)

function removeUpgradeCommand(cmd, upgrade)
	local vehicle = getPedOccupiedVehicle(g_Me)
	if vehicle and upgrade then
		server.removeVehicleUpgrade(vehicle, tonumber(upgrade) or 0)
	end
end
addCommandHandler('removeupgrade', removeUpgradeCommand)
addCommandHandler('ru', removeUpgradeCommand)

---------------------------
-- Toggle lights
---------------------------
function forceLightsOn()
	local vehicle = getPedOccupiedVehicle(g_Me)
	if not vehicle then
		return
	end
	if guiCheckBoxGetSelected(getControl(wndMain, 'lightson')) then
		server.setVehicleOverrideLights(vehicle, 2)
		guiCheckBoxSetSelected(getControl(wndMain, 'lightsoff'), false)
	else
		server.setVehicleOverrideLights(vehicle, 0)
	end
end

function forceLightsOff()
	local vehicle = getPedOccupiedVehicle(g_Me)
	if not vehicle then
		return
	end
	if guiCheckBoxGetSelected(getControl(wndMain, 'lightsoff')) then
		server.setVehicleOverrideLights(vehicle, 1)
		guiCheckBoxSetSelected(getControl(wndMain, 'lightson'), false)
	else
		server.setVehicleOverrideLights(vehicle, 0)
	end
end


---------------------------
-- Color
---------------------------
function colorInit()
	local vehicle = getPedOccupiedVehicle(g_Me)
	if not vehicle then
		errMsg('You need to be in a car to change its colors.')
		closeWindow(wndColor)
		return
	end
	guiRadioButtonSetSelected(getControl(wndColor, 'colorslot1'), true)
	local color1 = getVehicleColor(vehicle)
	setColorSelection(color1)
end

function colorSlotSelect()
	local colors = { getVehicleColor(getPedOccupiedVehicle(g_Me)) }
	for i=1,2 do
		if guiRadioButtonGetSelected(getControl(wndColor, 'colorslot' .. i)) then
			setColorSelection(colors[i])
			break
		end
	end
end

function applyColor(relX, relY)
	local vehicle = getPedOccupiedVehicle(g_Me)
	if not vehicle then
		return
	end
	
	local xIndex = math.floor(relX / (1/11))
	local yIndex = math.floor(relY / (1/12))
	local colorID = yIndex*11 + xIndex
	if colorID > 126 then
		return
	end
	
	local colors = { getVehicleColor(vehicle) }
	for i=1,2 do
		if guiRadioButtonGetSelected(getControl(wndColor, 'colorslot' .. i)) then
			colors[i] = colorID
			break
		end
	end
	server.setVehicleColor(vehicle, unpack(colors))
	
	setColorSelection(colorID)
end

function setColorSelection(colorID)
	local xIndex = math.fmod(colorID, 11)
	local yIndex = math.floor(colorID/11)
	guiSetPosition(
		getControl(wndColor, 'vehiclecolor', 'selection'),
		xIndex/11 + (1/11)/2 - (9/440)/2,
		yIndex/12 + (1/12)/2 - (9/480)/2,
		true
	)
end

wndColor = {
	'wnd',
	text = 'Vehicle colors',
	width = 460,
	controls = {
		{'img',
			src='vehiclecolors.png',
			id='vehiclecolor',
			width=440,
			height=480,
			controls={
				{'img', src='colorselect.png', id='selection', width=9, height=9}
			},
			onclick=applyColor,
			ondoubleclick=function() closeWindow(wndColor) end
		},
		{'lbl', text='Color slot:'},
		{'rad', id='colorslot1', text='1', onclick=colorSlotSelect},
		{'rad', id='colorslot2', text='2', onclick=colorSlotSelect},
		{'btn', id='close', closeswindow=true}
	},
	oncreate = colorInit
}

function setColorCommand(cmd, ...)
	local vehicle = getPedOccupiedVehicle(g_Me)
	if not vehicle then
		return
	end
	local colors = { getVehicleColor(vehicle) }
	local args = { ... }
	for i=1,4 do
		colors[i] = args[i] and tonumber(args[i]) or colors[i]
	end
	server.setVehicleColor(vehicle, unpack(colors))
end
addCommandHandler('color', setColorCommand)
addCommandHandler('cl', setColorCommand)

---------------------------
-- Paintjob
---------------------------

function paintjobInit()
	local vehicle = getPedOccupiedVehicle(g_Me)
	if not vehicle then
		errMsg('You need to be in a car to change its paintjob.')
		closeWindow(wndPaintjob)
		return
	end
	local paint = getVehiclePaintjob(vehicle)
	if paint then
		guiGridListSetSelectedItem(getControl(wndPaintjob, 'paintjoblist'), paint+1)
	end
end

function applyPaintjob(paint)
	server.setVehiclePaintjob(getPedOccupiedVehicle(g_Me), paint.id)
end

wndPaintjob = {
	'wnd',
	text = 'Car paintjob',
	width = 220,
	x = -20,
	y = 0.3,
	controls = {
		{
			'lst',
			id='paintjoblist',
			width=200,
			height=130,
			columns={
				{text='Paintjob ID', attr='id'}
			},
			rows={
				{id=0},
				{id=1},
				{id=2},
				{id=3}
			},
			onitemclick=applyPaintjob,
			ondoubleclick=function() closeWindow(wndPaintjob) end
		},
		{'btn', id='close', closeswindow=true},
	},
	oncreate = paintjobInit
}

function setPaintjobCommand(cmd, paint)
	local vehicle = getPedOccupiedVehicle(g_Me)
	paint = paint and tonumber(paint)
	if not paint or not vehicle then
		return
	end
	server.setVehiclePaintjob(vehicle, paint)
end
addCommandHandler('paintjob', setPaintjobCommand)
addCommandHandler('pj', setPaintjobCommand)

---------------------------
-- Time
---------------------------
function timeInit()
	local hours, minutes = getTime()
	setControlNumbers(wndTime, { hours = hours, minutes = minutes })
end

function selectTime(leaf)
	setControlNumbers(wndTime, { hours = leaf.h, minutes = leaf.m })
end

function applyTime()
	local hours, minutes = getControlNumbers(wndTime, { 'hours', 'minutes' })
	server.setTime(hours, minutes)
	closeWindow(wndTime)
end

wndTime = {
	'wnd',
	text = 'Set time',
	width = 220,
	controls = {
		{
			'lst',
			id='timelist',
			width=200,
			height=150,
			columns={
				{text='Time', attr='name'}
			},
			rows={
				{name='Midnight',  h=0, m=0},
				{name='Dawn',      h=5, m=0},
				{name='Morning',   h=9, m=0},
				{name='Noon',      h=12, m=0},
				{name='Afternoon', h=15, m=0},
				{name='Evening',   h=20, m=0},
				{name='Night',     h=22, m=0}
			},
			onitemclick=selectTime,
			ondoubleclick=applyTime
		},
		{'txt', id='hours', text='', width=40},
		{'lbl', text=':'},
		{'txt', id='minutes', text='', width=40},
		{'btn', id='ok', onclick=applyTime},
		{'btn', id='cancel', closeswindow=true}
	},
	oncreate = timeInit
}

function setTimeCommand(cmd, hours, minutes)
	if not hours then
		return
	end
	local curHours, curMinutes = getTime()
	hours = tonumber(hours) or curHours
	minutes = minutes and tonumber(minutes) or curMinutes
	setTime(hours, minutes)
end
addCommandHandler('settime', setTimeCommand)
addCommandHandler('st', setTimeCommand)

function toggleFreezeTime()
	local state = guiCheckBoxGetSelected(getControl(wndMain, 'freezetime'))
	guiCheckBoxSetSelected(getControl(wndMain, 'freezetime'), not state)
	server.setTimeFrozen(state)
end

function setTimeFrozen(state, h, m, w)
	guiCheckBoxSetSelected(getControl(wndMain, 'freezetime'), state)
	if state then
		if not g_TimeFreezeTimer then
			g_TimeFreezeTimer = setTimer(function() setTime(h, m) setWeather(w) end, 5000, 0)
			setMinuteDuration(9001)
		end
	else
		if g_TimeFreezeTimer then
			killTimer(g_TimeFreezeTimer)
			g_TimeFreezeTimer = nil
		end
		setMinuteDuration(1000)
	end
end

---------------------------
-- Weather
---------------------------
function applyWeather(leaf)
	if not leaf then
		leaf = getSelectedGridListLeaf(wndWeather, 'weatherlist')
		if not leaf then
			return
		end
	end
	server.setWeather(leaf.id)
	closeWindow(wndWeather)
end

wndWeather = {
	'wnd',
	text = 'Set weather',
	width = 250,
	controls = {
		{
			'lst',
			id='weatherlist',
			width=230,
			height=290,
			columns = {
				{text='Weather type', attr='name'}
			},
			rows={xml='weather.xml', attrs={'id', 'name'}},
			onitemdoubleclick=applyWeather
		},
		{'btn', id='ok', onclick=applyWeather},
		{'btn', id='cancel', closeswindow=true}
	}
}

function setWeatherCommand(cmd, weather)
	weather = weather and tonumber(weather)
	if weather then
		setWeather(weather)
	end
end
addCommandHandler('setweather', setWeatherCommand)
addCommandHandler('sw', setWeatherCommand)

---------------------------
-- Game speed
---------------------------
function gameSpeedInit()
	setControlNumber(wndGameSpeed, 'speed', getGameSpeed())
end

function selectGameSpeed(leaf)
	setControlNumber(wndGameSpeed, 'speed', leaf.id)
end

function applyGameSpeed()
	speed = getControlNumber(wndGameSpeed, 'speed')
	if speed then
		server.setMyGameSpeed(speed)
	end
	closeWindow(wndGameSpeed)
end

wndGameSpeed = {
	'wnd',
	text = 'Set game speed',
	width = 220,
	controls = {
		{
			'lst',
			id='speedlist',
			width=200,
			height=150,
			columns={
				{text='Speed', attr='name'}
			},
			rows={
				{id=3, name='3x'},
				{id=2, name='2x'},
				{id=1, name='1x'},
				{id=0.5, name='0.5x'}
			},
			onitemclick=selectGameSpeed,
			ondoubleclick=applyGameSpeed
		},
		{'txt', id='speed', text='', width=40},
		{'btn', id='ok', onclick=applyGameSpeed},
		{'btn', id='cancel', closeswindow=true}
	},
	oncreate = gameSpeedInit
}

function setGameSpeedCommand(cmd, speed)
	speed = speed and tonumber(speed)
	if speed then
		server.setMyGameSpeed(speed)
	end
end

addCommandHandler('setgamespeed', setGameSpeedCommand)
addCommandHandler('speed', setGameSpeedCommand)

---------------------------
-- Main window
---------------------------

function updateGUI(updateVehicle)
	-- update position
	local x, y, z = getElementPosition(g_Me)
	setControlNumbers(wndMain, {xpos=math.ceil(x), ypos=math.ceil(y), zpos=math.ceil(z)})
	
	-- update jetpack toggle
	guiCheckBoxSetSelected( getControl(wndMain, 'jetpack'), doesPedHaveJetPack(g_Me) )
	
	if updateVehicle then
		-- update current vehicle
		local vehicle = getPedOccupiedVehicle(g_Me)
		if vehicle then
			setControlText(wndMain, 'curvehicle', getVehicleName(vehicle))
		else
			setControlText(wndMain, 'curvehicle', 'On foot')
		end
	end
end

function mainWndShow()
	if not getPedOccupiedVehicle(g_Me) then
		hideControls(wndMain, 'repair', 'flip', 'upgrades', 'color', 'paintjob', 'lightson', 'lightsoff')
	end
	updateTimer = updateTimer or setTimer(updateGUI, 2000, 0)
	updateGUI(true)
end

function mainWndClose()
	killTimer(updateTimer)
	updateTimer = nil
end

function onEnterVehicle(vehicle)
	setControlText(wndMain, 'curvehicle', getVehicleName(vehicle))
	showControls(wndMain, 'repair', 'flip', 'upgrades', 'color', 'paintjob', 'lightson', 'lightsoff')
	guiCheckBoxSetSelected(getControl(wndMain, 'lightson'), getVehicleOverrideLights(vehicle) == 2)
	guiCheckBoxSetSelected(getControl(wndMain, 'lightsoff'), getVehicleOverrideLights(vehicle) == 1)
end

function onExitVehicle(vehicle)
	setControlText(wndMain, 'curvehicle', 'On foot')
	hideControls(wndMain, 'repair', 'flip', 'upgrades', 'color', 'paintjob', 'lightson', 'lightsoff')
	closeWindow(wndUpgrades)
	closeWindow(wndColor)
end

function killLocalPlayer()
	server.killPed(g_Me)
end

function alphaCommand(command, alpha)
	alpha = alpha and tonumber(alpha)
	if alpha then
		server.setElementAlpha(g_Me, alpha)
	end
end
addCommandHandler('alpha', alphaCommand)
addCommandHandler('ap', alphaCommand)

addCommandHandler('kill', killLocalPlayer)

wndMain = {
	'wnd',
	text = 'FR GUI',
	x = 10,
	y = 150,
	width = 280,
	controls = {
		{'lbl', text='Local player'},
		{'br'},
		{'btn', id='kill', onclick=killLocalPlayer},
		{'btn', id='skin', window=wndSkin},
		{'btn', id='anim', window=wndAnim},
		{'btn', id='weapon', window=wndWeapon},
		{'btn', id='clothes', window=wndClothes},
		{'btn', id='playergrav', text='grav', window=wndGravity},
		{'btn', id='warp', window=wndWarp},
		{'btn', id='stats', window=wndStats},
		{'br'},
		{'chk', id='jetpack', onclick=toggleJetPack},
		{'chk', id='falloff', text='fall off bike', onclick=toggleFallOffBike},
		{'br'},
		
		{'lbl', text='Pos:'},
		{'lbl', id='xpos', text='x', width=45},
		{'lbl', id='ypos', text='y', width=45},
		{'lbl', id='zpos', text='z', width=45},
		{'btn', id='setpos', text='map', window=wndSetPos},
		{'btn', id='setinterior', text='int', window=wndSetInterior},
		{'br'},
		{'br'},
		
		{'lbl', text='Vehicles'},
		{'br'},
		{'lbl', text='Current:'},
		{'lbl', id='curvehicle'},
		{'br'},
		{'btn', id='createvehicle', window=wndCreateVehicle, text='create'},
		{'btn', id='repair', onclick=repairVehicle},
		{'btn', id='flip', onclick=flipVehicle},
		{'btn', id='upgrades', window=wndUpgrades},
		{'btn', id='color', window=wndColor},
		{'btn', id='paintjob', window=wndPaintjob},
		{'br'},
		{'chk', id='lightson', text='Lights on', onclick=forceLightsOn},
		{'chk', id='lightsoff', text='Lights off', onclick=forceLightsOff},
		{'br'},
		{'br'},
		
		{'lbl', text='Environment'},
		{'br'},
		{'btn', id='time', window=wndTime},
		{'chk', id='freezetime', text='freeze', onclick=toggleFreezeTime},
		{'btn', id='weather', window=wndWeather},
		{'btn', id='speed', window=wndGameSpeed}
	},
	oncreate = mainWndShow,
	onclose = mainWndClose
}

function errMsg(msg)
	outputChatBox(msg, 255, 0, 0)
end

addEventHandler('onClientResourceStart', g_ResRoot,
	function()
		fadeCamera(true)
		setTimer(getPlayers, 1000, 1)
		
		bindKey('f1', 'down', toggleFRWindow)
		createWindow(wndMain)
		hideAllWindows()
		guiCheckBoxSetSelected(getControl(wndMain, 'jetpack'), doesPedHaveJetPack(g_Me))
		guiCheckBoxSetSelected(getControl(wndMain, 'falloff'), canPedBeKnockedOffBike(g_Me))
		setJetpackMaxHeight ( 9001 )
		triggerServerEvent('onLoadedAtClient', g_ResRoot, g_Me)
	end
)

function showWelcomeMap()
	createWindow(wndSpawnMap)
	showCursor(true)
end

function showMap()
	createWindow(wndSetPos)
	showCursor(true)
end

function toggleFRWindow()
	if isWindowOpen(wndMain) then
		showCursor(false)
		hideAllWindows()
	else
		showCursor(true)
		showAllWindows()
	end
end

addCommandHandler('fr', toggleFRWindow)

function getPlayers()
	g_PlayerData = {}
	table.each(getElementsByType('player'), joinHandler)
end

function joinHandler(player)
	g_PlayerData[player or source] = { name = getPlayerName(player or source), gui = {} }
end
addEventHandler('onClientPlayerJoin', g_Root, joinHandler)

addEventHandler('onClientPlayerQuit', g_Root,
	function()
		table.each(g_PlayerData[source].gui, destroyElement)
		g_PlayerData[source] = nil
	end
)

addEventHandler('onClientPlayerWasted', g_Me,
	function()
		onExitVehicle(g_Me)
	end
)

addEventHandler('onClientPlayerVehicleEnter', g_Me, onEnterVehicle)
addEventHandler('onClientPlayerVehicleExit', g_Me, onExitVehicle)

addEventHandler('onClientResourceStop', g_ResRoot,
	function()
		showCursor(false)
		setPedAnimation(g_Me, false)
	end
)
