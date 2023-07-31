------------------------------------------- Optimization -------------------------------------------
local string_toNickname = string.toNickname
----------------------------------------------------------------------------------------------------

local onTribeMemberConnection = function(self, packet, connection, tribulleId)
	local memberName = packet:readUTF()

	--[[@
		@name tribeMemberConnection
		@desc Triggered when a tribe member connects to the game.
		@param memberName<string> The member name.
	]]
	self.event:emit("tribeMemberConnection", string_toNickname(memberName, true))
end

return { onTribeMemberConnection, 88 }