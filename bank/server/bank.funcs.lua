
--[[

    Resource:   bank (written by 50p)
    Version:    2.2
    
    Filename:   bank.funcs.lua

]]


Account = { }
Account.__index = Account

function Account:new( username, balance, create_db )
	local account = { name = username, balance = balance or 0 }
	setmetatable( account, self )
	self.__index = self
    if create_db == 1 or create_db == true then
        --executeSQLInsert( bankSQLInfo.tab, "\"".. username .."\", 0" )
        local acc = getAccount( username );
        if acc then
        	setAccountData( acc, "bank.balance", balance );
        end
    end
	return account
end

function Account:open( username, balance )
    --local acc = executeSQLSelect( bankSQLInfo.tab, bankSQLInfo.username..", ".. bankSQLInfo.balance, bankSQLInfo.username.." = \"".. username.."\"", 1 )
    local acc = getAccount( username );
    if acc then 
        return Account:new( username, tonumber( balance ) )
    end
    return false
end

function Account:deposit( amount )
	self.balance = self.balance + amount
end

function Account:withdraw( amount, plr, transfer )
	if amount > self.balance then return end
	if plr then
		if transfer then
			self.balance = self.balance - amount
			return;
		end
		local pocket_money = getPlayerMoney( plr );
		local pocketAndWithdrawAmount = pocket_money + amount;
		if pocketAndWithdrawAmount > 99999999 then
			self.balance = ( pocketAndWithdrawAmount - 99999999 );
			setPlayerMoney( plr, 99999999 );
			return
		end
		setPlayerMoney( plr, pocketAndWithdrawAmount );
		self.balance = self.balance - amount
	end
end

function Account:setBalance( amount )
	self.balance = amount
end

function Account:balance()
	return self.balance
end

function Account:accountname()
    return self.name
end

function Account:setAccountName( newname )
    if newname then
        self.name = newname
        return
    end
end

