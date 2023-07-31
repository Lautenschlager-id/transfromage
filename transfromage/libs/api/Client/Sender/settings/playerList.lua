local Client = require("api/Client/init")

--[[@
	@name handlePlayers
	@desc Toggles the field _\_handle\_players_ of the instance.
	@desc If 'true', the following events are going to be handled: _playerGetCheese_, _playerVampire_, _playerWon_, _playerLeft_, _playerDied_, _newPlayer_, _refreshPlayerList_, _updatePlayer_, _playerEmote_.
	@param handle?<boolean> Whether the bot should handle the player events. The default value is the inverse of the current value. The instance starts the field as 'false'.
	@returns boolean Whether the bot will handle the player events.
]]
Client.handlePlayers = function(self, handle)
	if handle == nil then
		self._handlePlayers = not self._handlePlayers
	else
		self._handlePlayers = handle
	end

	return self._handlePlayers
end