local onUpdatePlayer = function(self, packet, connection, identifiers)
	self.playerList:updatePlayer(packet, self.event)
end

return { 144, 2, onUpdatePlayer }