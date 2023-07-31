------------------------------------------- Optimization -------------------------------------------
local string_toNickname = string.toNickname
----------------------------------------------------------------------------------------------------

local onFriendConnection = function(self, packet, connection, tribulleId)
	--[[@
		@name friendConnection
		@desc Triggered when a friend connects to the game.
		@param playerName<string> The player name.
	]]
	self.event:emit("friendConnection", string_toNickname(packet:readUTF(), true))
end

return { onFriendConnection, 32 }