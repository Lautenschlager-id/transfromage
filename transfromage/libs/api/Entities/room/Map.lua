------------------------------------------- Optimization -------------------------------------------
local setmetatable     = setmetatable
local table_writeBytes = table.writeBytes
local zlibDecompress   = require("miniz").inflate
----------------------------------------------------------------------------------------------------

local Map = table.setNewClass("Map")

Map.new = function(self, packet, decryptXML)
	local map = { }
	map.code = packet:read32()

	packet:read16() -- ?
	packet:read8() -- ?
	packet:read16() -- ?

	local xml = packet:read8(packet:read16())
	if decryptXML then
		xml = table_writeBytes(xml)
		if xml ~= '' then
			map.xml = zlibDecompress(xml, 1)
		end
	end
	map.author = packet:readUTF()
	map.permCode = packet:read8()
	map.isMirrored = packet:readBool()

	return setmetatable(map, self)
end

return Map