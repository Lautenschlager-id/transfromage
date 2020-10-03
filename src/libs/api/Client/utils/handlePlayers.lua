local handlePlayers = function(self)
	return self._handlePlayers and self.playerList._count > 0
end

return handlePlayers