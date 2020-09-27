local onPacketIDReceive = function(self, packet, connection, identifiers)
	connection.packetID = packet:read8()
end

return { 44, 22, onPacketIDReceive }