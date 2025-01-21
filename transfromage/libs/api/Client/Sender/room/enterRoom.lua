local Client = require("api/Client/init")

local ByteArray = require("classes/ByteArray")

local identifier = require("api/enum").identifier.room

--[[@
	@name enterRoom
	@desc Enters in a room.
	@param roomName<string> The name of the room.
	@param isSalonAuto?<boolean> Whether the change room must be /salonauto or not. @default false
]]
client.enterRoom = function(self, roomName, roomPassword, isSalonAuto)
	if not roomPassword then roomPassword = '' end
	self.mainConnection:send(identifier,
		ByteArray:new():writeUTF(''):writeUTF(roomName):writeUTF(roomPassword):writeBool(isSalonAuto))
end
