local Message = require("./Message")

------------------------------------------- Optimization -------------------------------------------
local os_time      = os.time
local setmetatable = setmetatable
----------------------------------------------------------------------------------------------------

local Topic = table.setNewClass("CafeTopic")

Topic.new = function(self, client, packet, id)
	local data = {
		_client = client
	}

	if packet then
		data.id = id or packet:read32()
		Topic.update(data, packet)
	elseif id then
		data.id = id
	end

	return setmetatable(data, self)
end

Topic.update = function(self, packet)
	self.title = packet:readUTF()
	self.authorId = packet:read32()
	self.posts = packet:read32()
	self.lastUserName = packet:readUTF()
	self.timestamp = os_time() - packet:read32()

	return self
end

Topic.retrieveMessages = function(self, packet)
	local client = self._client

	local tmpMsg
	local messages, totalMessages = { }, 0
	local messagesById = { }

	while packet.stackLen > 0 do
		tmpMsg = Message:new(client, self.id, packet)

		totalMessages = totalMessages + 1
		messages[totalMessages] = tmpMsg

		messagesById[tmpMsg.id] = tmpMsg
	end

	self.messages = messages
	self.messagesById = messagesById
	self.author = messages[1].author

	return self
end

Topic.newMessage = function(self, message)
	return self._client:sendCafeMessage(self.id, message)
end

return Topic