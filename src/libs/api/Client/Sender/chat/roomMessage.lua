local Client = require("api/Client/init")

local ByteArray = require("classes/ByteArray")

local identifier = require("api/enum").identifier.roomMessage

--[[@
	@name sendRoomMessage
	@desc Sends a message in the room chat.
	@desc /!\ Note that a message has a limit of 80 characters in the first 24 hours after the account creation, and 255 characters later. You must handle the limit yourself or the bot may get disconnected.
	@param message<string> The message.
]]
Client.sendRoomMessage = function(self, message)
	self:sendEncryptedPacket(ByteArray:new():writeUTF(message), self.bulleConnection, identifier)
end