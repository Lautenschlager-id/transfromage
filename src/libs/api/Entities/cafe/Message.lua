------------------------------------------- Optimization -------------------------------------------
local os_time      = os.time
local setmetatable = setmetatable
local string_gsub  = string.gsub
----------------------------------------------------------------------------------------------------

local Message = table.setNewClass()

Message.new = function(self, topicId, packet)
	local data = { }

	data.topicId = topicId
	data.id = packet:read32()
	data.authorId = packet:read32()
	data.timestamp = os_time() - packet:read32()
	data.author = packet:readUTF()
	data.content = string_gsub(packet:readUTF(), '\r', "\r\n")
	data.canLike = packet:readBool()
	data.likes = packet:readSigned16()

	return setmetatable(data, self)
end

return Message