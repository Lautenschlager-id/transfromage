local Client = require("Client/init")
local ByteArray = require("classes/ByteArray")

--[[@
	@name closeChat
	@desc Leaves a #chat.
	@param chatName<string> The name of the chat.
]]
Client.closeChat = function(self, chatName)
	self:sendTribulle(ByteArray:new():write16(56):write32(1):writeUTF(chatName))
end