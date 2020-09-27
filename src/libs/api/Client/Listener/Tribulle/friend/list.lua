local Friend = require("Entities/friend/Friend")

local onFriendListLoaded = function(self, packet, connection, tribulleId)
	local soulmate = Friend:new(packet)

	local friendList = { }
	for f = 1, packet:read16() do
		friendList[f] = Friend:new(packet)
	end

	--[[@
		@name friendList
		@desc Triggered when the friend list is loaded.
		@param friendList<table> The data of the players in the account's friend list.
		@param soulmate<table> The separated data of the account's soulmate.
		@struct @friendlist {
			[i] = {
				id = 0, -- The player id.
				playerName = "", -- The player's name.
				gender = 0, -- The player's gender. Enum in enum.gender.
				isFriend = true, -- Whether the player has the account as a friend (added back) or not.
				isConnected = true, -- Whether the player is online or offline.
				gameId = 0, -- The id of the game where the player is connected. Enum in enum.game.
				roomName = "", -- The name of the room the player is in.
				lastConnection = 0 -- Timestamp of when the player was last online.
			}
		}
		@struct @soulmate {
			id = 0, -- The player id.
			playerName = "", -- The soulmate's name.
			gender = 0, -- The soulmate's gender. Enum in enum.gender.
			isFriend = true, -- Whether the soulmate has the account as a friend (added back) or not.
			isConnected = true, -- Whether the soulmate is online or offline.
			gameId = 0, -- The id of the game where the soulmate is connected. Enum in enum.game.
			roomName = "", -- The name of the room the soulmate is in.
			lastConnection = 0 -- Timestamp of when the soulmate was last online.
		}
	]]
	self.event:emit("friendList", friendList, soulmate)
end

return { 34, onFriendListLoaded }