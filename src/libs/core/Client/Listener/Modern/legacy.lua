local legacyListener = require("../Legacy/init")

-- Optimization --
local string_byte = string.byte
local string_split = string.split
local table_remove = table.remove
------------------

local onOldPacket = function(self, packet, connection, identifiers)
	local data = string_split(packet:readUTF(), '\x01', true)
	local oldIdentifiers = { string_byte(table_remove(data, 1), 1, 2) }

	local oldPacketCallback = legacyReceiver[oldIdentifiers[1]]
	oldPacketCallback = oldPacketCallback and oldPacketCallback[oldIdentifiers[2]]

	if oldPacketCallback then
		return oldPacketCallback(self, data, connection, oldIdentifiers)
	end

	--[[@
		@name missedOldPacket
		@desc Triggered when an old packet is not handled by the old packet parser.
		@param oldIdentifiers<table> The oldC, oldCC identifiers that were not handled.
		@param data<table> The data that was not handled.
		@param connection<connection> The connection object.
	]]
	self.event:emit("missedOldPacket", oldIdentifiers, data, connection)
end

return {
	{ 1, 1, onOldPacket }
}