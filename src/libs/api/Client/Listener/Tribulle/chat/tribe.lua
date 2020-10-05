------------------------------------------- Optimization -------------------------------------------
local string_fixEntity = string.fixEntity
local string_toNickname = string.toNickname
----------------------------------------------------------------------------------------------------

local onTribeMessage = function(self, packet, connection, tribulleId)
	local memberName, message = packet:readUTF(), packet:readUTF()

	--[[@
		@name tribeMessage
		@desc Triggered when the tribe chat receives a new message.
		@param memberName<string> The member who sent the message.
		@param message<string> The message.
	]]
	self.event:emit("tribeMessage", string_toNickname(memberName, true), string_fixEntity(message))
end

return { onTribeMessage, 65 }