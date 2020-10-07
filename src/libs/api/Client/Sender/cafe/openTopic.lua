local Client = require("api/Client/init")

local ByteArray = require("classes/ByteArray")

local identifier = require("api/enum").identifier.cafeLoadData

--[[@
	@name openCafeTopic
	@desc Opens a Café topic.
	@desc You may use this method to reload (or refresh) the topic.
	@param topicId<int> The id of the topic to be opened.
]]
Client.openCafeTopic = function(self, topicId)
	self.mainConnection:send(identifier, ByteArray:new():write32(topicId))
end