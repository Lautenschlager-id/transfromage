local Map = require("api/Entities/room/Map")

------------------------------------------- Optimization -------------------------------------------
local setmetatable     = setmetatable
local string_byte      = string.byte
local string_fixEntity = string.fixEntity
local string_sub       = string.sub
----------------------------------------------------------------------------------------------------

local Room = table.setNewClass("Room")

Room.new = function(self, packet)
	local room = setmetatable({
		name = nil,
		language = nil,

		isOfficial = nil,
		isTribeHouse = nil,

		map = nil
	}, self)

	if packet then
		room.isOfficial = packet:readBool()

		room.name = packet:readUTF()
		room.language = packet:readUTF()

		room.isTribeHouse = string_byte(room.name, 2) == 3
		if room.isTribeHouse then
			room.name = string_sub(room.name, 3)
		else
			room.name = string_fixEntity(room.name)
		end
	end

	return room
end

Room.newMap = function(self, packet, decryptXML)
	self.map = Map:new(packet, decryptXML)
	return self.map
end

return Room