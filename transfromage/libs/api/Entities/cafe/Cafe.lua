local Topic = require("./Topic")

------------------------------------------- Optimization -------------------------------------------
local setmetatable = setmetatable
----------------------------------------------------------------------------------------------------

local Cafe = table.setNewClass("Cafe")

Cafe.new = function(self, client)
	return setmetatable({
		topics = { },
		cachedMessages = { },

		_client = client
	}, self)
end

Cafe.loadTopics = function(self, packet)
	local client  = self._client
	local topics = self.topics

	local topicId, tmpTopic
	while packet.stackLen > 0 do
		topicId = packet:read32()

		tmpTopic = topics[topicId]
		if tmpTopic then
			tmpTopic:update(packet)
		else
			topics[topicId] = Topic:new(client, packet, topicId, client)
		end
	end

	return self
end

Cafe.open = function(self)
	return self._client:openCafe(true)
end

Cafe.close = function(self)
	return self._client:openCafe(false)
end

Cafe.reload = function(self)
	return self._client:reloadCafe()
end

Cafe.openTopic = function(self, topicId)
	return self._client:openCafeTopic(topicId)
end

return Cafe