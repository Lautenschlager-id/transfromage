local Topic = require("./Topic")

------------------------------------------- Optimization -------------------------------------------
local setmetatable = setmetatable
----------------------------------------------------------------------------------------------------

local Cafe = table.setNewClass("Cafe")

Cafe.new = function(self, client)
	return setmetatable({
		topics = { },
		topicsById = { },

		cachedMessages = { },

		_client = client
	}, self)
end

Cafe.loadTopics = function(self, packet)
	local client  = self._client
	local topics = self.topics
	local topicsById = self.topicsById

	packet:readBool() -- ?
	packet:readBool() -- ?

	local totalTopics = 0

	local topicId, tmpTopic
	while packet.stackLen > 0 do
		topicId = packet:read32()

		tmpTopic = topics[topicId]
		if tmpTopic then
			tmpTopic:update(packet)
		else
			tmpTopic = Topic:new(client, packet, topicId)

			totalTopics = totalTopics + 1
			topics[totalTopics] = tmpTopic

			topicsById[topicId] = tmpTopic
		end
	end

	return self
end

Cafe.open = function(self)
	return self._client:openCafe(false)
end

Cafe.close = function(self)
	return self._client:openCafe(true)
end

Cafe.reload = function(self)
	return self._client:reloadCafe()
end

Cafe.openTopic = function(self, topic)
	if type(topic) == "table" then
		topic = topic.id
	end
	return self._client:openCafeTopic(topic)
end

return Cafe