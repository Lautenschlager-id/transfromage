local Player = require("./Player")

------------------------------------------- Optimization -------------------------------------------
local setmetatable = setmetatable
local table_remove = table.remove
local updateFlag   = require("api/enum").updatePlayer.general
----------------------------------------------------------------------------------------------------

local PlayerList = table.setNewClass("PlayerList")

PlayerList.__len = function(self)
	return self._count
end

PlayerList.__pairs = function(self)
	local indexes = { }
	for i = 1, self._count do
		indexes[i] = self[i]
	end

	local i, player = 0
	return function()
		i = i + 1

		player = indexes[i]
		if player then
			return player.playerName, player
		end
	end
end

PlayerList.new = function(self, client)
	return setmetatable({
		_count = 0,

		_client = client
	}, self)
end

PlayerList.updatePlayer = function(self, packet)
	local playerName = packet:readUTF()

	local playerData = self[playerName]
	if playerData then -- Already exists
		local oldPlayerData = playerData:copy()
		playerData:update(packet)

		--[[@
			@name updatePlayer
			@desc Triggered when a player field is updated.
			@param playerData<table> The data of the player.
			@param oldPlayerData<table> The data of the player before the new values.
			@struct @playerdata @oldPlayerData {
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
		self._client.event:emit("updatePlayer", playerData, oldPlayerData, updateFlag)
	else
		playerData = Player:new(playerName)

		self._count = self._count + 1
		playerData._index = self._count

		self[playerName] = playerData
		self[playerData._index] = playerData
		self[playerData.id] = playerData

		--[[@
			@name newPlayer
			@desc Triggered when a player joins the room.
			@param playerData<table> The data of the player.
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
		self._client.event:emit("newPlayer", playerData)
	end
end

PlayerList.deletePlayer = function(self, player)
	-- Removes the numeric reference and decreases 1 for all the next players in the queue.
	local playerIndex = player._index
	table_remove(self, playerIndex)

	self._count = self._count - 1

	local tmpPlayer
	for i = playerIndex, self._count do
		tmpPlayer = self[i]
		if tmpPlayer then
			tmpPlayer._index = tmpPlayer._index - 1
		end
	end

	-- Removes other references
	self[player.playerName] = nil
	self[player.id] = nil
end

return PlayerList