-- Optimization --
local string_fixEntity = string.fixEntity
local string_toNickname = string.toNickname
------------------

local onChatMessage = function(self, packet, connection, tribulleId)
	local playerName, community = packet:readUTF(), packet:read32()
	local chatName, message = packet:readUTF(), packet:readUTF()

	--[[@
		@name chatMessage
		@desc Triggered when a #chat receives a new message.
		@param chatName<string> The name of the chat.
		@param playerName<string> The player who sent the message.
		@param message<string> The message.
		@param playerCommunity<int> The community id of @playerName.
	]]
	self.event:emit("chatMessage", chatName, string_toNickname(playerName, true),
		string_fixEntity(message), community)
end

return { onChatMessage, 64 }