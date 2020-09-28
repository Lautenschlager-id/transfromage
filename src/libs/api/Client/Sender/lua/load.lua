local Client = require("Client/init")
local ByteArray = require("classes/ByteArray")

local identifier = require("api/enum").identifier.loadLua

--[[@
	@name loadLua
	@desc Loads a lua script in the room.
	@param script<string> The lua script.
]]
Client.loadLua = function(self, script)
	self.bulleConnection:send(identifier, ByteArray:new():writeBigUTF(script))
end