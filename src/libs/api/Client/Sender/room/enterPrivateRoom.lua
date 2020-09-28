local Client = require("Client/init")
local ByteArray = require("classes/ByteArray")

local identifier = require("api/enum").identifier.roomPassword

--[[@
	@name enterPrivateRoom
	@desc Enters in a room protected with password.
	@param roomName<string> The name of the room.
	@param roomPassword<string> The password of the room.
]]
Client.enterPrivateRoom = function(self, roomName, roomPassword)
	self.mainConnection:send(identifier, ByteArray:new():writeUTF(roomPassword):writeUTF(roomName))
end