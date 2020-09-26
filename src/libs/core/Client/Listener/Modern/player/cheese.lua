local onPlayerGetCheese = function(self, packet, connection, identifiers)
	local player = self.playerList[packet:read32()]
	if not player then return end

	player.hasCheese = packet:readBool()

	--[[@
		@name playerGetCheese
		@desc Triggered when a player gets (or loses) the cheese.
		@param playerData<table> The data of the player.
		@param hasCheese<boolean> Whether the player has cheese or not.
		@struct @playerdata {
			playerName = "", -- The nickname of the player.
			id = 0, -- The temporary id of the player during the section.
			isShaman = false, -- Whether the player is shaman or not.
			isDead = false, -- Whether the player is dead or alive.
			score = 0, -- The current player's score.
			hasCheese = false, -- Whether the player has cheese or not.
			title = 0, -- The player's title id.
			titleStars = 0, -- The number of stars the player's title has.
			gender = 0, -- The player's gender. Enum in enum.gender.
			look = "", -- The current outfit string code of the player.
			mouseColor = 0, -- The color of the player. It is set to -1 if it's the default color.
			shamanColor = 0, -- The color of the player as shaman.
			nameColor = 0, -- The color of the nickname of the player.
			isSouris = false, -- Whether the player is souris or not.
			isVampire = false, -- Whether the player is vampire or not.
			hasWon = false, -- Whether the player has entered the hole in the round or not.
			winPosition = 0, -- The position where the player entered the hole. It is set to -1 if it has not won yet.
			winTimeElapsed = 0, -- Time elapsed until the player enters the hole. It is set to -1 if it has not won yet.
			isFacingRight = false, -- Whether the player is facing right.
			movingRight = false, -- Whether the player is moving right.
			movingLeft = false, -- Whether the player is moving left.
			isBlueShaman = false, -- Whether the player is the blue shaman.
			isPinkShaman = false, -- Whether the player is the pink shaman.
			x = 0, -- Player's X coordinate in the map.
			y = 0, -- Player's X coordinate in the map.
			vx = 0, -- Player's X speed in the map.
			vy = 0, -- Player's Y speed in the map.
			isDucking = false, -- Whether the player is ducking.
			isJumping = false, -- Whether the player is jumping.
			_pos = 0 -- The position of the player in the array list. This value should never be changed manually.
		}
	]]
	self.event:emit("playerGetCheese", player, player.hasCheese)
end

return { 144, 6, onPlayerGetCheese }