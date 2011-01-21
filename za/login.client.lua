local localPlayer = getLocalPlayer()
local localPlayerName = getPlayerName(localPlayer)
local localRootElement = getRootElement()
local newUser
local passwordAttempts = 0

function CreateLoginWindow()
	wdwLogin = guiCreateStaticImage(145,68,488,390,"images/login.png",false)

	edtUser = guiCreateEdit(0.25,0.4205,0.5102,0.0846,localPlayerName,true,wdwLogin)
	guiEditSetReadOnly(edtUser,false)
	edtPass = guiCreateEdit(0.248,0.5821,0.5123,0.0821,"",true,wdwLogin)
	guiEditSetMaxLength(edtPass,20)
	guiEditSetMasked(edtPass,true)

	btnLogin = guiCreateButton(0.5143,0.6872,0.2439,0.0872,"login/register",true,wdwLogin)

	guiSetVisible(wdwLogin,false)
	
end

addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()),
	function()
		CreateLoginWindow()
		lblDisplayArea = guiCreateLabel(0.100,0.800,0.800,0.100,"",true)
		guiLabelSetHorizontalAlign(lblDisplayArea,"center",true)
			
		addEventHandler("onClientGUIClick",btnLogin,clientSubmitLogin,false) --Mouseclick on the Login button...
		addEventHandler("onClientGUIAccepted",edtPass,clientEnterLogin,false) --Hitting 'enter' key in password box...

		triggerServerEvent ("checkValidAct",localPlayer,localPlayerName) --Check if they have an account to log in to...
	end
)

function clientNewUserHandler() --Called when no account exists for this players name...
	newUser = true
	guiSetText(lblDisplayArea,"No account exists for your username. Please create a password.")
	if(wdwLogin) then
		guiSetVisible(wdwLogin,true)
		guiBringToFront(edtPass) --Puts the cursor into the password box for typing...
	end
	showCursor(true)
	guiSetInputEnabled(true)
end
addEvent("clientNewUser",true)
addEventHandler("clientNewUser",localRootElement,clientNewUserHandler)

function clientReturningUserHandler() --Called when there is an existing account for this player's name...
	newUser = false
	guiSetText(lblDisplayArea,"You are using a registered nickname - please enter your password.")
	if(wdwLogin) then
		guiSetVisible(wdwLogin,true)
		guiBringToFront(edtPass) --Puts the cursor into the password box for typing...
	end
	showCursor(true)
	guiSetInputEnabled(true)
end
addEvent("clientReturningUser",true)
addEventHandler("clientReturningUser",localRootElement,clientReturningUserHandler)

function clientEnterLogin()
	if(newUser) then
		triggerServerEvent("SubmitCreate",localRootElement,guiGetText(edtUser),guiGetText(edtPass))
	else
		triggerServerEvent("SubmitLogin",localRootElement,guiGetText(edtUser),guiGetText(edtPass))
	end
end

function clientSubmitLogin(button)
	if(button == "left") then
		if(newUser) then
			triggerServerEvent("SubmitCreate",localRootElement,guiGetText(edtUser),guiGetText(edtPass))
		else
			triggerServerEvent("SubmitLogin",localRootElement,guiGetText(edtUser),guiGetText(edtPass))
		end
	end
end

function clientDisplayAreaHandler(theMessage)
	guiSetText(lblDisplayArea,theMessage)
end
addEvent("clientDisplayArea",true)
addEventHandler("clientDisplayArea",localRootElement,clientDisplayAreaHandler)

function clientWrongPasswordHandler(theMessage)
	passwordAttempts = passwordAttempts + 1
	if(passwordAttempts > 3) then
		guiSetText(lblDisplayArea,"Too many incorrect password attempts.  Please disconnect.")
		destroyElement(wdwLogin)
		triggerServerEvent("removePlayer",localPlayer)
	end
end
addEvent("clientWrongPassword",true)
addEventHandler("clientWrongPassword",localRootElement,clientWrongPasswordHandler)

function clientLoginSuccessHandler()
	guiSetInputEnabled(false)
	destroyElement(wdwLogin)
	destroyElement(lblDisplayArea)
	wdwLogin = nil
	newUser = nil
	lblDisplayArea = nil
	passwordAttempts = nil
	localPlayer = nil
	localPlayerName = nil
	localRootElement = nil
	showCursor(false)
end
addEvent("clientLoginSuccess",true)
addEventHandler("clientLoginSuccess",localRootElement,clientLoginSuccessHandler)