local Client = require("api/Client/init")

local ByteArray = require("classes/ByteArray")

local identifier = require("api/enum").identifier.room

--[[@
	@name enterRoom
	@desc Enters in a room, protected or not.
	@param roomName<string> The name of the room.
	@param roomPassword?<string> The password of the room. @default ''
	@param isSalonAuto?<boolean> Whether the change room must be /salonauto or not. @default false
]]
Client.enterRoom = function(self, roomName, roomPassword, isSalonAuto)
	self.mainConnection:send(identifier, ByteArray:new()
		:writeUTF(''):writeUTF(roomName):writeUTF(roomPassword or ''):writeBool(isSalonAuto))
end

Client.enterPrivateRoom = "enterRoom"