local Topic = require("Topic")

-- Optimization --
local setmetatable = setmetatable
------------------

local Cafe = table.setNewClass()

Cafe.new = function(self)
	return setmetatable({
		topics = { },
		cachedMessages = { }
	}, self)
end

Cafe.loadTopics = function(self, packet)
	local topics = self.topics

	local tmpTopic
	while packet.stackLen > 0 do
		tmpTopic = Topic:new(packet)

		if topics[tmpTopic.id] then
			data.messages = topics[tmpTopic.id].messages
			data.author = topics[tmpTopic.id].author
		end
		topics[tmpTopic.id] = tmpTopic
	end

	return self
end

return Cafe