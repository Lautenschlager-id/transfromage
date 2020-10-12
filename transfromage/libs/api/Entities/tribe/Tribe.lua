local Member = require("./Member")

------------------------------------------- Optimization -------------------------------------------
local setmetatable = setmetatable
----------------------------------------------------------------------------------------------------

local Tribe = table.setNewClass("Tribe")

Tribe.new = function(self, client, packet, id)
	local data = {
		members = { },
		roles = { },

		_client = client
	}

	data.name = packet:readUTF()
	data.id = id or packet:read32()
	data.greetingMessage = packet:readUTF()
	data.map = packet:read32()

	data = setmetatable(data, self)

	if id then
		client.tribe = data
	end

	return data
end

Tribe.retrieveMembers = function(self, packet)
	local client = self._client
	local members = self.members

	for m = 1, packet:read16() do
		members[m] = Member:new(client, packet)
	end

	return members
end

Tribe.retrieveRoles = function(self)
	local roles = self.roles

	for r = 1, packet:read16() do
		roles[packet:readUTF()] = packet:read32()
	end

	return roles
end

Tribe.joinHouse = function(self)
	return self._client:joinTribeHouse()
end

Tribe.kickMember = function(self, memberName)
	return self._client:kickTribeMember(memberName)
end

Tribe.openInterface = function(self, includeOfflineMembers)
	return self._client:openTribeInterface(includeOfflineMembers)
end

Tribe.recruitPlayer = function(self, playerName)
	return self._client:recruitPlayer(playerName)
end

Tribe.setGreetingMessage = function(self, message)
	return self._client:setTribeGreetingMessage(message)
end

Tribe.setMemberRole = function(memberName, roleId)
	return self._client:setTribeMemberRole(memberName, roleId)
end

return Tribe