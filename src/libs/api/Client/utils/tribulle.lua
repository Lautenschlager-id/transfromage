local Client = require("Client/init")

local packetCipher = require("libs/utils/encode").packetCipher

local identifier = require("api/enum").identifier.bulle

Client.sendTribulle = function(self, packet)
	packet = self._isOfficialBot and packet or packetCipher(packet, connection.packetID)
	self.mainConnection:send(identifier, packet)
end