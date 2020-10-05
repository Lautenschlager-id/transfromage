local Client = require("api/Client/init")
local ByteArray = require("classes/ByteArray")

local identifier = require("api/enum").identifier.cafeLike

--[[@
	@name likeCafeMessage
	@desc Likes/Dislikes a message in a Café topic.
	@desc /!\ The method does not handle the Café's cooldown system: 300 seconds to react in a message.
	@param topicId<int> The id of the topic where the message is located.
	@param messageId<int> The id of the message that will receive the reaction.
	@param dislike?<boolean> Whether the reaction must be a dislike or not. @default false
]]
Client.likeCafeMessage = function(self, topicId, messageId, dislike)
	self.mainConnection:send(identifier,
		ByteArray:new():write32(topicId):write32(messageId):writeBool(not dislike))
end