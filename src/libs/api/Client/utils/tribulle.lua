local Client = require("Client/init")

local packetCipher = require("libs/utils/encode").packetCipher

local bulleIdentifier = require("api/enum").identifier.bulle

local sendEncryptedPacket = function(self, packet, connection, identifier)
	packet = self._isOfficialBot and packet or packetCipher(packet, connection.packetID)
	connection:send(identifier, packet)
end

Client.sendTribulle = function(self, packet)
	sendEncryptedPacket(self, packet, self.mainConnection, bulleIdentifier)
end

Client.sendEncryptedPacket = sendEncryptedPacket