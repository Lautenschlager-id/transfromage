------------------------------------------- Optimization -------------------------------------------
local string_fixEntity = string.fixEntity
local string_toNickname = string.toNickname
----------------------------------------------------------------------------------------------------

local onRoomMessage = function(self, packet, connection, identifiers)
	local playerName, message = packet:readUTF(), string_fixEntity(packet:readUTF())

	--[[@
		@name roomMessage
		@desc Triggered when the room receives a new user message.
		@param playerName<string> The player who sent the message.
		@param message<string> The message.
	]]
	self.event:emit("roomMessage", string_toNickname(playerName, true), string_fixEntity(message))
end

return { onRoomMessage, 6, 6 }