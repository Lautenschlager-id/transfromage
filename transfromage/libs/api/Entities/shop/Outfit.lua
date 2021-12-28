------------------------------------------- Optimization -------------------------------------------
local setmetatable = setmetatable
----------------------------------------------------------------------------------------------------

local Outfit = table.setNewClass("Outfit")

Outfit.new = function(self)
	return setmetatable({
		id = nil,

		look = nil,

		flags = nil,
	}, self)
end

Outfit.loadFromFashion = function(self, packet)
	self.id = packet:read16()

	self.look = packet:readUTF()

	self.flags = packet:read8()

	return self
end

Outfit.load = function(self, packet, id)
	self.id = id

	self.look = packet:readUTF()

	return self
end

return Outfit