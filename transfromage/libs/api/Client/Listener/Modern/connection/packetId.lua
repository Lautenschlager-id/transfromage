local onPacketIDReceive = function(self, packet, connection, identifiers)
	connection.packetID = packet:read8()
end

return { onPacketIDReceive, 44, 22 }