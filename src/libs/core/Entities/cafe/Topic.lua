local Message = require("Message")

-- Optimization --
local os_time = os.time
local setmetatable = setmetatable
------------------

local Topic = table.setNewClass()

Topic.new = function(self, packet, id)
	local data = { }

	if id then
		data.id = id
	else
		data.id = packet:read32()
		data.title = packet:readUTF()
		data.authorId = packet:read32()
		data.posts = packet:read32()
		data.lastUserName = packet:readUTF()
		data.timestamp = os_time() - packet:read32()
	end

	return setmetatable(data, self)
end

Topic.retrieveMessages = function(self, packet)
	local messages, totalMessages = { }, 0

	while packet.stackLen > 0 do
		totalMessages = totalMessages + 1
		messages[totalMessages] = Message:new(self.id, packet)
	end

	self.messages = messages
	self.author = messages[1].author

	return self
end

return Topic