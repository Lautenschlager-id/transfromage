local zlibDecompress = require("miniz").inflate

-- Optimization --
local table_writeBytes = table.writeBytes
------------------

local onNewGame = function(self, packet, connection, identifiers)
	local map = { }
	map.code = packet:read32()

	packet:read16() -- ?
	packet:read8() -- ?
	packet:read16() -- ?

	local xml = packet:read8(packet:read16())
	if self._processXml then
		xml = table_writeBytes(xml)
		if xml ~= '' then
			map.xml = zlibDecompress(xml, 1)
		end
	end
	map.author = packet:readUTF()
	map.perm = packet:read8()
	map.isMirrored = packet:readBool()

	--[[@
		@name newGame
		@desc Triggered when a map is loaded.
		@desc /!\ This event may increase the memory consumption significantly due to the XML processes. Set the variable `_processXml` as false to avoid processing it.
		@param map<table> The new map data.
		@struct @map {
			code = 0, -- The map code.
			xml = "", -- The map XML. May be nil if the map is Vanilla.
			author = "", -- The map author
			perm = 0, -- The perm code of the map.
			isMirrored = false -- Whether the map is mirrored or not.
		}
	]]
	self.event:emit("newGame", map)
end

return { 5, 2, onNewGame }