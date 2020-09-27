local Friend = require("Entities/friend/Friend")

local onFriendAdd = function(self, packet, connection, tribulleId)
	--[[
		@desc Triggered when a player is added to the friend list.
		@param friend<table> The data of the new friend.
		@struct @friend {
			id = 0, -- The player id.
			playerName = "", -- The player's name.
			gender = 0, -- The player's gender. Enum in enum.gender.
			isFriend = true, -- Whether the player has the account as a friend (added back) or not.
			isConnected = true, -- Whether the player is online or offline.
			gameId = 0, -- The id of the game where the player is connected. Enum in enum.game.
			roomName = "", -- The name of the room the player is in.
			lastConnection = 0 -- Timestamp of when the player was last online.
		}
	]]
	self.event:emit("newFriend", Friend:new(packet))
end

return { 36, onFriendAdd }