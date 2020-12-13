------------------------------------------- Optimization -------------------------------------------
local setmetatable      = setmetatable
local string_toNickname = string.toNickname
----------------------------------------------------------------------------------------------------

local Friend = table.setNewClass("Friend")

Friend.new = function(self, client, packet)
	local data = {
		_client = client
	}

	data.id = packet:read32()

	data.playerName = string_toNickname(packet:readUTF())

 	data.gender = packet:read8()

	data.hasAvatar = packet:read32() ~= 0

	data.isFriend = packet:readBool()
	data.isConnected = packet:readBool()

	data.gameId = packet:read32()

	data.roomName = packet:readUTF()

	data.lastConnection = packet:read32()

	return setmetatable(data, self)
end

Friend.blacklist = function(self)
	return self._client:blacklistPlayer(self.playerName)
end

Friend.remove = function(self)
	return self._client:removeFriend(self.playerName)
end

return Friend