------------------------------------------- Optimization -------------------------------------------
local setmetatable      = setmetatable
local string_toNickname = string.toNickname
----------------------------------------------------------------------------------------------------

local Member = table.setNewClass("TribeMember")

Member.new = function(self, client, packet)
	local data = {
		_client = client
	}

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

Member.kick = function(self)
	return self._client:kickTribeMember(self.playerName)
end

Member.setRole = function(self, roleId)
	return self._client:setTribeMemberRole(self.playerName, roleId)
end

return Member