local Client = require("api/Client/init")
local ByteArray = require("classes/ByteArray")

--[[@
	@name sendChatMessage
	@desc Sends a message to a #chat.
	@desc /!\ Note that a message has a limit of 80 characters in the first 24 hours after the account creation, and 255 characters later. You must handle the limit yourself or the bot may get disconnected.
	@param chatName<string> The name of the chat.
	@param message<string> The message.
]]
Client.sendChatMessage = function(self, chatName, message)
	self:sendTribulle(ByteArray:new():write16(48):write32(1):writeUTF(chatName):writeUTF(message))
end