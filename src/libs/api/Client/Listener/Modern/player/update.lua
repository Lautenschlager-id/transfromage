local handlePlayers = require("Client/utils/handlePlayers")

local onUpdatePlayer = function(self, packet, connection, identifiers)
	if not handlePlayers(self) then return end

	self.playerList:updatePlayer(packet, self.event)
end

return { onUpdatePlayer, 144, 2 }