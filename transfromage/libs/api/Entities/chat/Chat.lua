------------------------------------------- Optimization -------------------------------------------
local setmetatable = setmetatable
----------------------------------------------------------------------------------------------------

local Chat = table.setNewClass("Chat")

Chat.new = function(self, client, name, fingerprint)
	return setmetatable({
		name = name,
		fingerprint = fingerprint,

		isOpen = false,

		_client = client
	}, self)
end

Chat.open = function(self)
	return self._client:joinChat(self.name)
end

Chat.sendMessage = function(self, message)
	if not self.isOpen then
		self._client:joinChat(self.name)
	end

	return self._client:sendChatMessage(self.name, message)
end

Chat.close = function(self)
	return self._client:closeChat(self.name)
end

Chat.who = function(self)
	return self._client:chatWho(self.name, self.fingerprint)
end

return Chat