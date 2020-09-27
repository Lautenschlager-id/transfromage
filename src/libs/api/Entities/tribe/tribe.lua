-- Optimization --
local setmetatable = setmetatable
------------------

local Tribe = table.setNewClass()

Tribe.new = function(self, packet)
	local data = { }

	data.name = packet:readUTF()
	data.id = packet:read32()
	data.greetingMessage = packet:readUTF()
	data.map = packet:read32()

	return setmetatable(data, self)
end

return Tribe