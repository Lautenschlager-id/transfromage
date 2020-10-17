------------------------------------------- Optimization -------------------------------------------
local string_toNickname = string.toNickname
----------------------------------------------------------------------------------------------------

local onWho = function(self, packet, connection, tribulleId)
	local fingerprint = packet:read32()
	local chat = self.chatList[fingerprint]

	packet:read8() -- ?

	local data = { }
	for i = 1, packet:read16() do
		data[i] = string_toNickname(packet:readUTF(), true)
	end

	--[[@
		@name chatWho
		@desc Triggered when the /who command is loaded in a chat.
		@param chatName<string> The name of the chat.
		@param data<table> An array with the nicknames of the current users in the chat.
	]]
	self.event:emit("chatWho", chat.name, data)
end

return { onWho, 59 }