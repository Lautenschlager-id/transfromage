-- Optimization --
local string_fixEntity = string.fixEntity
local string_toNickname = string.toNickname
------------------

local onWhisperMessage = function(self, packet, connection, tribulleId)
	local playerName, community = packet:readUTF(), packet:read32()
	packet:readUTF()
	local message = packet:readUTF()

	--[[@
		@name whisperMessage
		@desc Triggered when the player receives a whisper.
		playerName<string> Who sent the whisper message.
		message<string> The message.
		playerCommunity<int> The community id of @playerName.
	]]
	self.event:emit("whisperMessage", string_toNickname(playerName, true),
		string_fixEntity(message), community)
end,

return { onWhisperMessage, 66 }