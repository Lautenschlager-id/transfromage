local Client = require("api/Client/init")

local ByteArray = require("classes/ByteArray")

local identifier = require("api/enum").identifier.cafeData

--[[@
	@name reloadCafe
	@desc Reloads the Café data.
]]
Client.reloadCafe = function(self)
	self.mainConnection:send(identifier, ByteArray:new())
end