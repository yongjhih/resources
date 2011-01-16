
--[[

    Resource:   bank (written by 50p)
    Version:    2.2
    
    Filename:   bank.script.server.lua

]]


resourceRoot = getResourceRootElement( getThisResource() )
root = getRootElement( )

playersAccount = { }
playerInMarker = { }

table.size = function ( tab )
	local i = 0;
	for k, v in pairs( tab ) do
		i = i + 1;
	end
	return i;
end

function resourceStarted( )
	
    bankInit( )
    executeSQLCreateTable( bankSQLInfo.tab, bankSQLInfo.username.. " TEXT, ".. bankSQLInfo.balance .." INT" )

	for k,v in ipairs( getElementsByType( "player" ) ) do
		local mta_account = getPlayerAccount( v )
        --local regName = executeSQLSelect( bankSQLInfo.tab, bankSQLInfo.username ..", ".. bankSQLInfo.balance, bankSQLInfo.username .." = \"".. getAccountName( mta_account ).. "\"", 1 )
		if mta_account and isGuestAccount( mta_account ) ~= true then
			local player_balance = getAccountData( mta_account, "bank.balance" );
			--outputDebugString( getPlayerName( v ) .. " balance: " .. tostring( player_balance ) );
	        if not player_balance then
                playersAccount[ v ] = Account:new( getAccountName( mta_account ), 0, 1 )
                playerInMarker[ v ] = false
            end
			if player_balance then
				playersAccount[ v ] = Account:open( getAccountName( mta_account ), player_balance )
				playerInMarker[ v ] = false
			end
        else
            playersAccount[ v ] = Account:new( getPlayerName( v ), 0 )
            playerInMarker[ v ] = false
		end
	end
	
end
addEventHandler( "onResourceStart", resourceRoot, resourceStarted )


function resourceStopped( )
	bank_saveAllPlayersMoney()
end
addEventHandler( "onResourceStop", resourceRoot, resourceStopped )

function bank_savePlayerMoney( player, playerAccount )
	if getElementType( player ) == "player" and isGuestAccount( playerAccount ) ~= true then
		setAccountData( playerAccount, "bank.balance", tostring( playersAccount[ player ].balance ) );
        --executeSQLUpdate( bankSQLInfo.tab, bankSQLInfo.balance .." = ".. tostring( playersAccount[ player ].balance ), bankSQLInfo.username .." =\"".. getAccountName( playerAccount ) .. "\"" )
	end
end

function bank_saveAllPlayersMoney()
	for k, v in ipairs( getElementsByType( "player" ) ) do
		bank_savePlayerMoney( v, getPlayerAccount( v ) )
	end
end

function bank_playerJoined()
	--outputChatBox( "This server runs Bank System (v1.5). Type /bs", source, 255, 255, 0 )
	playersAccount[ source ] = Account:new( getPlayerName( source ), 0 )
	--setTimer( spawnPlayer, 1000, 1, source, 2420.7126, 1124.0426, 10.8203 )
    --setTimer( setPlayerRotation, 1100, 1, source, 90 )
	--fadeCamera( source, true )
end
addEventHandler( "onPlayerJoin", root, bank_playerJoined )

function bank_playerQuit()
	local mta_account = getPlayerAccount( source )
	if isGuestAccount( mta_account ) ~= true and getAccountName( mta_account ) == getPlayerName( source ) then
		bank_savePlayerMoney( source, mta_account )
	end
	playersAccount[ source ] = nil
end
addEventHandler( "onPlayerQuit", root, bank_playerQuit )

function bank_playerLogin( oldAccount, currentAccount )
    --local isregistered = executeSQLSelect( bankSQLInfo.tab, bankSQLInfo.username, bankSQLInfo.username.." = \"".. getAccountName( currentAccount ) ..  "\"", 1 )
	if isGuestAccount( oldAccount ) == true and getElementType( source ) == "player" then
		local player_balance = getAccountData( currentAccount, "bank.balance" );
		if player_balance then
			playersAccount[ source ]:setBalance( tonumber( player_balance ) )
            playersAccount[ source ]:setAccountName( getAccountName( currentAccount ) )
			if isPlayerInBank( source ) then
				triggerClientEvent( source, "bank_updateMyBalance", source, tonumber( player_balance ) )
			end
			outputChatBox( "Bank balance: $ " .. tostring( playersAccount[ source ].balance ), source, 255, 255, 0 )
		else
			playersAccount[ source ] = nil;
			playersAccount[ source ] = Account:new( getAccountName( currentAccount ), 0, true );
		end
	end
end
addEventHandler( "onPlayerLogin", root, bank_playerLogin )

function bank_playerLogout( oldAccount, currentAccount )
	if isGuestAccount( currentAccount ) == true and isGuestAccount( oldAccount ) ~= true and getAccountName( oldAccount ) == playersAccount[ source ]:accountname() then
		bank_savePlayerMoney( source, oldAccount )
		playersAccount[ source ]:setBalance( 0 )
        playersAccount[ source ]:setAccountName( getPlayerName( source ) )
		playerInMarker[ source ] = false
		outputChatBox( "You have successfully logged out. Your bank balance has been saved!", source, 0, 255, 0 )
	end
end
addEventHandler( "onPlayerLogout", root, bank_playerLogout )

function bank_helpCommand( player )
	outputChatBox( "You can withdraw/deposit money in City Planing Dept., Las Venturas.", player, 255, 255, 0 )
	outputChatBox( "Available commands:/withdraw <amount> & /deposit <amount>", player, 255, 255, 0 )
end
addCommandHandler( "bs", bank_helpCommand )

function bank_withdrawDepositCommand( player, command, money )
	local money_int = tonumber( money )
	if command == "deposit" then
		if isPlayerInBank( player ) then
			if getPlayerMoney( player ) >= money_int then
					playersAccount[ player ]:deposit( money_int )
                    bank_savePlayerMoney( player, getPlayerAccount( player ) )
					outputChatBox( "Your current balance is $".. tostring( playersAccount[ player ].balance )..".", player, 255, 255, 0 )
					outputChatBox( "Money ($".. tostring( money_int ) ..") succesfully deposited.", player, 255, 255, 0 )
					takePlayerMoney( player, money_int )
			else
				outputChatBox( "Insufficient founds.", player, 250, 0, 0 )
			end
		else
			outputChatBox( "You must be at Bank's marker to use this command.", player )
		end	
	elseif command == "withdraw" then
		if isPlayerInBank( player ) then
			if playersAccount[ player ].balance < money_int then
				outputChatBox( "Insufficient founds.", player )
			else
                bank_savePlayerMoney( player, getPlayerAccount( player ) )
				outputChatBox( "You've withdrawn $"..tostring( money_int )..".", player, 255, 255, 0 )
				playersAccount[ player ]:withdraw( money_int, player )
				givePlayerMoney( player, money_int )
				outputChatBox( "Your current balance is $".. tostring( playersAccount[ player ].balance )..".", player, 255, 255, 0 )
			end
		else
			outputChatBox( "You must be at Bank's marker to use this command.", player )
		end
	end
end
addCommandHandler( "withdraw", bank_withdrawDepositCommand )
addCommandHandler( "deposit", bank_withdrawDepositCommand )

function playerEnterMarker( marker )
	if ( not isPedOnGround ( source ) ) or ( doesPedHaveJetPack ( source ) ) or 
		( isPedInVehicle ( source ) ) or ( getControlState ( source, "aim_weapon" ) ) then return end
		
    for k, v in pairs( banksInfo ) do
    	if marker == banksInfo[ k ].marker then
			local triggered = triggerEvent( "onPlayerEnterBank", source, banksInfo[ k ].marker, banksInfo[ k ].ATM )
			if triggered then
	    		setControlState( source, "forwards", false )
	    		setControlState( source, "backwards", false )
	    		setControlState( source, "left", false )
	    		setControlState( source, "right", false )
	    		--outputChatBox( tostring( playersAccount[ source ].balance ) );
	    		local try = triggerClientEvent( source, "bank_showBankAccountWnd", source, playersAccount[ source ]:accountname(), tostring( playersAccount[ source ].balance ), banksInfo[ k ].name, banksInfo[ k ].marker, banksInfo[ k ].depositAllowed )
	    		if not try then
	    			setTimer( triggerClientEvent, 100, 1, source, "bank_showBankAccountWnd", source, playersAccount[ source ]:accountname(), tostring( playersAccount[ source ].balance ), banksInfo[ k ].name, banksInfo[ k ].marker, banksInfo[ k ].depositAllowed )
	    		end
	    		playerInMarker[ source ] = marker
			end
			break
    	elseif banksInfo[ k ].entrance and marker == banksInfo[ k ].entrance.marker then
    		fadeCamera( source, false, 1 )
    		setTimer( setElementInterior, 1100, 1, source, 
                                                banksInfo[ k ].entrance.teleInterior,
                                                banksInfo[ k ].entrance.teleX,
                                                banksInfo[ k ].entrance.teleY,
                                                banksInfo[ k ].entrance.teleZ )
    		--setTimer( setPedRotation, 1100, 1, source, 90 )
    		setTimer( setPedRotation, 1100, 1, source, 90 )
    		setTimer( fadeCamera, 1100, 1, source, true, 1 )
    		setTimer( setCameraTarget, 1150, 1, source );
            break
    	elseif banksInfo[ k ]._exit and marker == banksInfo[ k ]._exit.marker then
    		fadeCamera( source, false, 1 )
    		setTimer( setElementInterior, 1100, 1, source, 
                                                banksInfo[ k ]._exit.teleInterior,
                                                banksInfo[ k ]._exit.teleX,
                                                banksInfo[ k ]._exit.teleY,
                                                banksInfo[ k ]._exit.teleZ )
    		--setTimer( setPedRotation, 1100, 1,
    		setTimer( setPedRotation, 1100, 1, source, banksInfo[ k ]._exit.teleRot )
    		setTimer( fadeCamera, 1100, 1, source, true, 1 )
    		setTimer( setCameraTarget, 1150, 1, source );
            break
    	end
    end
end
addEventHandler( "onPlayerMarkerHit", root, playerEnterMarker )

function playerLeaveBank( marker )
	if playerInMarker[ source ] then
	    for k, v in ipairs( banksInfo ) do
	        if marker == banksInfo[ k ].marker then
				triggerEvent( "onPlayerLeaveBank", source, marker, banksInfo[ k ].ATM )
	            triggerClientEvent( source, "bank_hideBankAccountWnd", source )
	            playerInMarker[ source ] = false
	            break
	        end
	    end
	end
end
addEventHandler( "onPlayerMarkerLeave", root, playerLeaveBank )


function withdrawMoney( player, money )
	local playerBankID = getBankID( getPlayerBank( player ) )
	if type( money ) == 'number' and playersAccount[ player ].balance < money then
		triggerClientEvent( player, "bank_showWarningMessage", player, "Insufficient founds!" )
	elseif type( money ) == 'string' and money == 'all' then
		money = playersAccount[ player ].balance
		if money > 0 then
			local atm = ( banksInfo[ playerBankID ].ATM and true or false )
			local triggered = triggerEvent( "onPlayerWithdrawMoney", player, getPlayerBank( player ), money, atm )
			if triggered then
				playersAccount[ player ]:withdraw( money, player )
			    bank_savePlayerMoney( player, getPlayerAccount( player ) )
				triggerClientEvent( player, "bank_updateMyBalance", player, playersAccount[ player ].balance )
			end
		else
			triggerClientEvent( player, "bank_showWarningMessage", player, "You have no money in your\naccount!" )
		end
    else
		if money > 0 then
			local atm = ( banksInfo[ playerBankID ].ATM and true or false )
			local triggered = triggerEvent( "onPlayerWithdrawMoney", player, getPlayerBank( player ), money, atm )
			if triggered then
				--outputChatBox( "You've withdrawn $"..tostring( money )..".", player, 255, 255, 0 )
				playersAccount[ player ]:withdraw( money, player )
		        bank_savePlayerMoney( player, getPlayerAccount( player ) )
				triggerClientEvent( player, "bank_updateMyBalance", player, playersAccount[ player ].balance )
			end
		end
	end
end
addEvent( "bank_withdrawMoney", true )
addEventHandler( "bank_withdrawMoney", root, withdrawMoney )


--addCommandHandler( "money", function( plr ) givePlayerMoney( plr, 1 ) end );
addCommandHandler( "transferaccounts",
	function( plr )
		local account = getPlayerAccount( plr );
		if ( ( not isGuestAccount( account ) ) and ( isObjectInACLGroup( "user." .. getAccountName( account ), aclGetGroup( "Admin" ) ) ) ) then
			outputDebugString( getPlayerName( plr ) .. ": Transfering bank accounts from SQL database to MTA accounts system... Please wait." );
			local accountsNum = 0;
			local tickStart = getTickCount( );
			local bank_accounts = executeSQLSelect( bankSQLInfo.tab, bankSQLInfo.username..", " ..bankSQLInfo.balance );
			if bank_accounts then
				for row in pairs( bank_accounts ) do
					local accountName = bank_accounts[ row ][ bankSQLInfo.username ];
					local accountBalance = bank_accounts[ row ][ bankSQLInfo.balance ];
					local mta_account = getAccount( accountName );
					if setAccountData( mta_account, "bank.balance", accountBalance ) then
						accountsNum = accountsNum + 1;
					end
				end
			end
			outputDebugString( getPlayerName( plr ) .. ": All accounts (" .. tostring( accountsNum ) .. ") were moved to accounts system. (" .. tostring( getTickCount() - tickStart ) .."ms)" );
		end
	end
)



function depositMoney( player, money )
	local playerBankID = getBankID( getPlayerBank( player ) )
	if type( money ) == 'number' and getPlayerMoney( player ) >= money then
		local atm = ( banksInfo[ playerBankID ].ATM and true or false )
		local triggered = triggerEvent( "onPlayerDepositMoney", player, getPlayerBank( player ), money, atm )
		if triggered then
			playersAccount[ player ]:deposit( money )
			takePlayerMoney( player, money )
	        bank_savePlayerMoney( player, getPlayerAccount( player ) )
			triggerClientEvent( player, "bank_updateMyBalance", player, playersAccount[ player ].balance )
		end
    elseif type( money ) == 'string' and money == 'all' then
		money = getPlayerMoney( player )
		if money == 0 then 
			triggerClientEvent( player, "bank_showWarningMessage", player, "You have no money to deposit!" )
			return
		end
		local atm = ( banksInfo[ playerBankID ].ATM and true or false )
		local triggered = triggerEvent( "onPlayerDepositMoney", player, getPlayerBank( player ), money, atm )
		if triggered then
			playersAccount[ player ]:deposit( money )
	        takePlayerMoney( player, money )
	        bank_savePlayerMoney( player, getPlayerAccount( player ) )
			triggerClientEvent( player, "bank_updateMyBalance", player, playersAccount[ player ].balance )
		end
	else
		triggerClientEvent( player, "bank_showWarningMessage", player, "Insufficient founds!" )
	end
end
addEvent( "bank_depositMoney", true )
addEventHandler( "bank_depositMoney", root, depositMoney )

function transferMoney( player, receiver, money )
	local playerBankID = getBankID( getPlayerBank( player ) )
	if type( money ) == 'number' and playersAccount[ player ].balance >= money then
		local atm = ( banksInfo[ playerBankID ].ATM and true or false )
		local triggered = triggerEvent( "onPlayerTransferMoney", player, getPlayerBank( player ), money, receiver, atm  )
		if triggered then
			playersAccount[ player ]:withdraw( money, player, true )
			playersAccount[ receiver ]:deposit( money )
			triggerClientEvent( player, "bank_updateMyBalance", player, playersAccount[ player ].balance )
	        bank_savePlayerMoney( player, getPlayerAccount( player ) )
	        bank_savePlayerMoney( receiver, getPlayerAccount( receiver ) )
			if isPlayerInBank( receiver ) then
				triggerClientEvent( receiver, "bank_updateMyBalance", receiver, playersAccount[ receiver ].balance )
			end
		end
    elseif type( money ) == 'string' and money == 'all' then	
	    money = playersAccount[ player ].balance
		local atm = ( banksInfo[ playerBankID ].ATM and true or false )
		local triggered = triggerEvent( "onPlayerTransferMoney", player, getPlayerBank( player ), money, receiver, atm  )
		if triggered then
	        playersAccount[ player ]:withdraw( money, player, true )
	        playersAccount[ receiver ]:deposit( money )
	        bank_savePlayerMoney( player, getPlayerAccount( player ) )
	        bank_savePlayerMoney( receiver, getPlayerAccount( receiver ) )
			triggerClientEvent( player, "bank_updateMyBalance", player, playersAccount[ player ].balance )
			if isPlayerInBank( receiver ) then
				triggerClientEvent( receiver, "bank_updateMyBalance", receiver, playersAccount[ receiver ].balance )
			end
		end
	else
		triggerClientEvent( player, "bank_showWarningMessage", player, "Insufficient founds!" )
	end
end
addEvent( "bank_transferMoney", true )
addEventHandler( "bank_transferMoney", root, transferMoney )

_setPlayerMoney = setPlayerMoney; -- just in case copy the function
function setPlayerMoney( player, money )
	takePlayerMoney( player, getPlayerMoney( player ) );
	givePlayerMoney( player, money );
end

