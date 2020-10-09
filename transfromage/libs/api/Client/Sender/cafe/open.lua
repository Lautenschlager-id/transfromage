local Client = require("api/Client/init")

local ByteArray = require("classes/ByteArray")

local identifier = require("api/enum").identifier.cafeState

--[[@
	@name openCafe
	@desc Toggles the current Café state (open / close).
	@desc It will send @see Client.reloadCafe automatically if close is false.
	@param close?<boolean> If the Café should be closed. @default false
]]
Client.openCafe = function(self, close)
	close = not close

	self.mainConnection:send(identifier, ByteArray:new():writeBool(close))

	if close then -- open = reload
		self:reloadCafe()
	end
end