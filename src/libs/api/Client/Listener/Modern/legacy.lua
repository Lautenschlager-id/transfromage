local legacyListener = require("Client/Listener/Legacy/init")

-- Optimization --
local string_byte = string.byte
local string_split = string.split
local table_remove = table.remove
------------------

local onLegacyPacket = function(self, packet, connection, identifiers)
	local data = string_split(packet:readUTF(), '\x01', true)
	local legacyIdentifiers = { string_byte(table_remove(data, 1), 1, 2) }

	local legacyPacketCallback = legacyReceiver[legacyIdentifiers[1]]
	legacyPacketCallback = legacyPacketCallback and legacyPacketCallback[legacyIdentifiers[2]]

	if legacyPacketCallback then
		return legacyPacketCallback(self, data, connection, legacyIdentifiers)
	end

	--[[@
		@name missedLegacyPacket
		@desc Triggered when an legacy packet is not handled by the legacy packet parser.
		@param legacyIdentifiers<table> The legacyC, legacyCC identifiers that were not handled.
		@param data<table> The data that was not handled.
		@param connection<connection> The connection object.
	]]
	self.event:emit("missedLegacyPacket", legacyIdentifiers, data, connection)
end

return { 1, 1, onLegacyPacket }