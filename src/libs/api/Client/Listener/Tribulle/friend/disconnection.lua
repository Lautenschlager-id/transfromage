-- Optimization --
local string_toNickname = string.toNickname
------------------

local onFriendDisconnection = function(self, packet, connection, tribulleId)
	--[[@
		@name friendDisconnection
		@desc Triggered when a friend disconnects from the game.
		@param playerName<string> The player name.
	]]
	self.event:emit("friendDisconnection", string_toNickname(packet:readUTF(), true))
end

return { 33, onFriendDisconnection }