local onFriendRemove = function(self, packet, connection, tribulleId)
	--[[@
		@name removeFriend
		@desc Triggered when a player is removed from the friend list.
		@param playerId<int> The id of the player that was removed.
	]]
	self.event:emit("removeFriend", packet:read32())
end

return { 37, onFriendRemove }