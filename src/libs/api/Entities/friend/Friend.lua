------------------------------------------- Optimization -------------------------------------------
local setmetatable = setmetatable
local string_toNickname = string.toNickname
----------------------------------------------------------------------------------------------------

local Friend = table.setNewClass()

Friend.new = function(self, packet)
	local data = { }

	data.id = packet:read32()

	data.playerName = string_toNickname(packet:readUTF())

 	data.gender = packet:read8()

 	packet:read32() -- id again

	data.isFriend = packet:readBool()
	data.isConnected = packet:readBool()

	data.gameId = packet:read32()

	data.roomName = packet:readUTF()

	data.lastConnection = packet:read32()

	return setmetatable(data, self)
end

return Friend