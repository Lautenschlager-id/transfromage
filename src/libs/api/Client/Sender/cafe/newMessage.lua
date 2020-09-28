local Client = require("Client/init")
local ByteArray = require("classes/ByteArray")

-- Optimization --
local string_gsub = string.gsub
------------------

local identifier = require("api/enum").identifier.cafeSendMessage

--[[@
	@name sendCafeMessage
	@desc Sends a message in a Café topic.
	@desc /!\ The method does not handle the Café's cooldown system: 300 seconds if the last post is from the same account, otherwise 10 seconds.
	@param topicId<int> The id of the topic where the message will be posted.
	@param message<string> The message to be posted.
]]
Client.sendCafeMessage = function(self, topicId, message)
	message = string_gsub(message, "\r\n", '\r')
	self.mainConnection:send(identifier, ByteArray:new():write32(topicId):writeUTF(message))
end