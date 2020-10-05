local Client = require("api/Client/init")
local ByteArray = require("classes/ByteArray")

--[[@
	@name sendTribeMessage
	@desc Sends a message to the tribe chat.
	@desc /!\ Note that a message has a limit of 80 characters in the first 24 hours after the account creation, and 255 characters later. You must handle the limit yourself or the bot may get disconnected.
	@param message<string> The message.
]]
Client.sendTribeMessage = function(self, message)
	self:sendTribulle(ByteArray:new():write16(50):write32(3):writeUTF(message))
end