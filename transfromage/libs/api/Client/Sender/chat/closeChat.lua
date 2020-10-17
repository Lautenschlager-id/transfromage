local Client = require("api/Client/init")

local ByteArray = require("classes/ByteArray")

--[[@
	@name closeChat
	@desc Leaves a #chat.
	@param chatName<string> The name of the chat.
]]
Client.closeChat = function(self, chatName)
	self.chatList:get(chatName).isOpen = false
	self:sendTribulle(ByteArray:new():write16(56):write32(1):writeUTF(chatName))
end