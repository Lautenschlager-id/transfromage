local handlePlayers = function(client)
	return client._handlePlayers and client.playerList._count > 0
end

return handlePlayers