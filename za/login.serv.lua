
function clientAttemptLogin(username,password)
	local userAccount = getAccount(username)
	local tryToLog
	if (client) then
		tryToLog = logIn(client,userAccount,password)
		if (tryToLog) then
			spawnPlayer(client,2314.75+math.random(-1,1), -6.43+math.random(-1,1), 26.74, 180, 285)
			fadeCamera(client,true)
	        setCameraTarget(client, client)
			triggerClientEvent(source,"clientLoginSuccess",getRootElement())
			if (getPlayerMoney(client) < 500) and (exports.bank:getBankAccountBalance (client) < 500) then
			 giveWeapon(client,22,34)
			end
		else
			triggerClientEvent(source,"clientDisplayArea",getRootElement(),"Incorrect password, please try again.")
			triggerClientEvent(source,"clientWrongPassword",getRootElement())
		end
	end
end
addEvent("SubmitLogin",true)
addEventHandler("SubmitLogin",getRootElement(),clientAttemptLogin)

function clientAttemptCreate(username,password)
	if (password ~= nil and password ~= "") then
	    addAccount(username,password)
		local userAccount = getAccount(username)
		local tryToLog
		if (client and userAccount ~= false and userAccount ~= nil) then
			tryToLog = logIn(client,userAccount,password)
			if (tryToLog) then
			spawnPlayer(client,2314.75+math.random(-1,1), -6.43+math.random(-1,1), 26.74, 180, 285)
			fadeCamera(client,true)
	        setCameraTarget(client, client)
            outputChatBox ("Welcome to Zombie Apocalypse!, "..getPlayerName(client))
			if (getPlayerMoney(client) < 500) and (exports.bank:getBankAccountBalance (client) < 500) then
			 giveWeapon(client,22,34)
			end
				triggerClientEvent(source,"clientLoginSuccess",getRootElement())
			else
				triggerClientEvent(source,"clientDisplayArea",getRootElement(),"Unable to log in to new account, try again.")
			end
		else
			triggerClientEvent(source,"clientDisplayArea",getRootElement(),"Unable to create new account, try again.")
		end
	else
		triggerClientEvent(source,"clientDisplayArea",getRootElement(),"Please create a password for your new account.")
	end
end
addEvent("SubmitCreate",true)
addEventHandler("SubmitCreate",getRootElement(),clientAttemptCreate)

function checkValidActHandler(thePlayer)
	local theAccount = getAccount(thePlayer)
	if (theAccount) then
		triggerClientEvent(source,"clientReturningUser",getRootElement())
	else
		triggerClientEvent(source,"clientNewUser",getRootElement())
	end
end
addEvent("checkValidAct",true)
addEventHandler("checkValidAct",getRootElement(),checkValidActHandler)

function removePlayerHandler()
	kickPlayer(source)
end
addEvent("removePlayer",true)
addEventHandler("removePlayer",getRootElement(),removePlayerHandler)