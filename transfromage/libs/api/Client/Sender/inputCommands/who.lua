local Client = require("api/Client/init")

local ByteArray = require("classes/ByteArray")

--[[@
	@name chatWho
	@desc Gets the names of players in a specific chat. (/who)
	@param chatName<string> The name of the chat.
]]
Client.chatWho = function(self, chatName, _chatFingerprint)
	_chatFingerprint = _chatFingerprint or self.chatList:get(chatName).fingerprint
	self:sendTribulle(ByteArray:new():write16(58):write32(_chatFingerprint):writeUTF(chatName))
end