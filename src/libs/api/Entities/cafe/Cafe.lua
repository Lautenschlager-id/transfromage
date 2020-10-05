local Topic = require("./Topic")

------------------------------------------- Optimization -------------------------------------------
local setmetatable = setmetatable
----------------------------------------------------------------------------------------------------

local Cafe = table.setNewClass()

Cafe.new = function(self)
	return setmetatable({
		topics = { },
		cachedMessages = { }
	}, self)
end

Cafe.loadTopics = function(self, packet)
	local topics = self.topics

	local topicId, tmpTopic
	while packet.stackLen > 0 do
		topicId = packet:read32()

		tmpTopic = topics[topicId]
		if tmpTopic then
			tmpTopic:update(packet)
		else
			topics[topicId] = Topic:new(packet, topicId)
		end
	end

	return self
end

return Cafe