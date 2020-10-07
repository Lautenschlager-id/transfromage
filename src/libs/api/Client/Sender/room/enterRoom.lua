local Client = require("api/Client/init")

local ByteArray = require("classes/ByteArray")

local identifier = require("api/enum").identifier.room

--[[@
	@name enterRoom
	@desc Enters in a room.
	@param roomName<string> The name of the room.
	@param isSalonAuto?<boolean> Whether the change room must be /salonauto or not. @default false
]]
Client.enterRoom = function(self, roomName, isSalonAuto)
	self.mainConnection:send(identifier,
		ByteArray:new():writeUTF(''):writeUTF(roomName):writeBool(isSalonAuto))
end