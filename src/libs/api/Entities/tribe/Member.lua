-- Optimization --
local setmetatable = setmetatable
local string_toNickname = string.toNickname
------------------

local Member = table.setNewClass()

Member.new = function(self, packet)
	local data = { }

	data.id = packet:read32()
	data.playerName = string_toNickname(packet:readUTF())

	data.gender = packet:readByte()

 	packet:read32() -- id again

	data.lastConnection = packet:read32()

	data.rolePosition = packet:read8()

	data.gameId = packet:read32() -- game id

	data.roomName = packet:readUTF()

	return setmetatable(data, self)
end

return Member