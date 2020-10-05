local Client = require("api/Client/init")
local ByteArray = require("classes/ByteArray")

--[[@
	@name chatWho
	@desc Gets the names of players in a specific chat. (/who)
	@param chatName<string> The name of the chat.
]]
Client.chatWho = function(self, chatName)
	self._whoFingerprint = (self._whoFingerprint + 1) % 0xFFFFFFFF
	self._whoList[self._whoFingerprint] = chatName

	self:sendTribulle(ByteArray:new():write16(58):write32(self._whoFingerprint):writeUTF(chatName))
end