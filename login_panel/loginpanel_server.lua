--------------------------
-- Login panel by NeXTreme
--------------------------


-- Login handling
function loginPlayer(username,password,enableKickPlayer,attemptedLogins,maxLoginAttempts)
	if not (username == "") then
		if not (password == "") then
			local account = getAccount ( username, password )
			if ( account ~= false ) then
				logIn (source, account, password)
				outputChatBox ("#0000FF* #FFFFFFYou have sucessfully logged in!",source,255,255,255,true)
				setTimer(outputChatBox,700,1,"#0000FF* #FFFFFFTo enable auto-login, use #ABCDEF/enableauto#FFFFFF!",source,255,255,255,true)
				triggerClientEvent (source,"hideLoginWindow",getRootElement())
			else
				if enableKickPlayer == true then
					if (attemptedLogins >= maxLoginAttempts-1) then
						outputChatBox ("#0000FF* #FFFFFFError! Wrong username and/or password!",source,255,255,255,true)
						setTimer(outputChatBox,500,1,"#0000FF* #FFFFFFWarning! Maximum login attempts reached! [#008AFF"..attemptedLogins+1 .."/"..maxLoginAttempts.."#FFFFFF]",source,255,255,255,true)
						setTimer(outputChatBox,1000,1,"#0000FF* #FFFFFFYou will be kicked in #008AFF5 seconds#FFFFFF!",source,255,255,255,true)
						setTimer(kickPlayer,5000,1,source,"Failed to login")
					else
						outputChatBox ("#0000FF* #FFFFFFError! Wrong username and/or password!",source,255,255,255,true)
						setTimer(outputChatBox,500,1,"#0000FF* #FFFFFFLogin attempts: [#008AFF"..attemptedLogins+1 .."/"..maxLoginAttempts.."#FFFFFF]",source,255,255,255,true)
						triggerClientEvent(source,"onRequestIncreaseAttempts",source)
					end
				else
					outputChatBox ("#0000FF* #FFFFFFError! Wrong username and/or password!",source,255,255,255,true)
				end
			end
		else
			outputChatBox ("#0000FF* #FFFFFFError! Please enter your password!",source,255,255,255,true)
		end
	else
		outputChatBox ("#0000FF* #FFFFFFError! Please enter your username!",source,255,255,255,true)
	end
end



-- Registration here
function registerPlayer(username,password,passwordConfirm)
	if not (username == "") then
		if not (password == "") then
			if not (passwordConfirm == "") then
				if password == passwordConfirm then
					local account = getAccount (username,password)
					if (account == false) then
						local accountAdded = addAccount(tostring(username),tostring(password))
						if (accountAdded) then
							triggerClientEvent(source,"hideRegisterWindow",getRootElement())
							outputChatBox ("#0000FF* #FFFFFFYou have sucessfuly registered! [Username: #ABCDEF" .. username .. " #FF0000| #FFFFFFPassword: #ABCDEF" .. password .. "#FFFFFF]",source,255,255,255,true )
							setTimer(outputChatBox,800,1,"#0000FF* #FFFFFFYou can now login with your new account.",source,255,255,255,true )
						else
							outputChatBox ("#0000FF* #FFFFFFAn unknown error has occured! Please choose a different username/password and try again.",source,255,255,255,true )
						end
					else
						outputChatBox ("#0000FF* #FFFFFFError! An account with this username already exists!",source,255,255,255,true )
					end
				else
					outputChatBox ("#0000FF* #FFFFFFError! Passwords do not match!",source,255,255,255,true)
				end
			else
				outputChatBox ("#0000FF* #FFFFFFError! Please confirm your password!",source,255,255,255,true)
			end
		else
			outputChatBox ("#0000FF* #FFFFFFError! Please enter a password!",source,255,255,255,true)
		end
	else
		outputChatBox ("#0000FF* #FFFFFFError! Please enter a username you would like to register with!",source,255,255,255,true)
	end
end



-- Auto-login handling
function autologinPlayer(username,password)
	if not (username == "") then
		if not (password == "") then
			local account = getAccount ( username, password )
			if not (account == false) then
				logIn (source, account, password)
				outputChatBox("#0000FF* #FFFFFFYou have been automatically logged in.",source,255,255,255,true)
				setTimer(outputChatBox,1000,1,"#0000FF* #FFFFFFTo disable auto-login, use #ABCDEF/disableauto.",source,255,255,255,true)
				triggerClientEvent ( source, "hideLoginWindow", getRootElement())
			else
				outputChatBox ("#FF0000* #FFFFFFAuto-login error - Username & password do not match",source,255,255,255,true)
			end
		else
			outputChatBox ("#FF0000* #FFFFFFAuto-login error - Failed to retrieve password",source,255,255,255,true)
		end
	else
		outputChatBox ("#FF0000* #FFFFFFAuto-login error - Failed to retrieve username",source,255,255,255,true)
	end
end



-- When the player logs out, trigger the client event to check if the login panel will request them to login again
function logoutHandler()
	triggerClientEvent(source,"onRequestDisplayPanel",source)
end
addEventHandler("onPlayerLogout",getRootElement(),logoutHandler)






addEvent("onRequestLogin",true)
addEvent("onRequestRegister",true)
addEvent("onRequestAutologin",true)
addEventHandler("onRequestLogin",getRootElement(),loginPlayer)
addEventHandler("onRequestRegister",getRootElement(),registerPlayer)
addEventHandler("onRequestAutologin",getRootElement(),autologinPlayer)

