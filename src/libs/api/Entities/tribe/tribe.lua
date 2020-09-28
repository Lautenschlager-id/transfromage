local Member = require("Entities/tribe/Member")

-- Optimization --
local setmetatable = setmetatable
------------------

local Tribe = table.setNewClass()

Tribe.new = function(self, packet, id)
	local data = {
		members = { },
		roles = { }
	}

	data.name = packet:readUTF()
	data.id = id or packet:read32()
	data.greetingMessage = packet:readUTF()
	data.map = packet:read32()

	return setmetatable(data, self)
end

Tribe.retrieveMembers = function(self, packet)
	local members = self.members

	for m = 1, packet:read16() do
		members[m] = Member:new(packet)
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

return Tribe