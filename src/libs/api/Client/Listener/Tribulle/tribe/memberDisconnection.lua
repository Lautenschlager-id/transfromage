-- Optimization --
local string_toNickname = string.toNickname
------------------

local onTribeMemberDisconnection = function(self, packet, connection, tribulleId)
	local memberName = packet:readUTF()

	--[[@
		@name tribeMemberDisconnection
		@desc Triggered when a tribe member disconnects from the game.
		@param memberName<string> The member name.
	]]
	self.event:emit("tribeMemberDisconnection", string_toNickname(memberName, true))
end

return { 90, onTribeMemberDisconnection }