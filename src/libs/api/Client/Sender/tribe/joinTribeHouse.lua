local Client = require("api/Client/init")
local ByteArray = require("classes/ByteArray")

local identifier = require("api/enum").identifier.joinTribeHouse

--[[@
	@name joinTribeHouse
	@desc Joins the tribe house.
	@desc /!\ Note that this method will not cover errors if the account is not in a tribe or does not have permissions.
]]
Client.joinTribeHouse = function(self)
	self.mainConnection:send(identifier, ByteArray:new())
end