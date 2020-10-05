local Client = require("api/Client/init")

------------------------------------------- Optimization -------------------------------------------
local bulleIdentifier = require("api/enum").identifier.bulle
local packetCipher = require("libs/utils/encode").packetCipher
----------------------------------------------------------------------------------------------------

local sendEncryptedPacket = function(self, packet, connection, identifier)
	packet = self._isOfficialBot and packet or packetCipher(self, packet, connection.packetID)
	connection:send(identifier, packet)
end

Client.sendTribulle = function(self, packet)
	sendEncryptedPacket(self, packet, self.mainConnection, bulleIdentifier)
end

Client.sendEncryptedPacket = sendEncryptedPacket