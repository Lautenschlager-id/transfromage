------------------------------------------- Optimization -------------------------------------------
local os_time      = os.time
local setmetatable = setmetatable
local string_gsub  = string.gsub
----------------------------------------------------------------------------------------------------

local Message = table.setNewClass("CafeMessage")

Message.new = function(self, client, topicId, packet)
	local data = {
		topicId = topicId,

		_client = client
	}

	data.id = packet:read32()
	data.authorId = packet:read32()
	data.timestamp = os_time() - packet:read32()
	data.author = packet:readUTF()
	data.content = string_gsub(packet:readUTF(), '\r', "\r\n")
	data.canLike = packet:readBool()
	data.likes = packet:readSigned16()

	return setmetatable(data, self)
end

Message.reply = function(self, message)
	return self._client:sendCafeMessage(self.topicId, message)
end

Message.like = function(self, dislike)
	return self._client:likeCafeMessage(self.topicId, self.id, dislike)
end

return Message