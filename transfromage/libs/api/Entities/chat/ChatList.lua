local Chat = require("./Chat")

------------------------------------------- Optimization -------------------------------------------
local next         = next
local setmetatable = setmetatable
local string_sub   = string.sub
local tonumber     = tonumber
----------------------------------------------------------------------------------------------------

local ChatList = table.setNewClass("ChatList")

ChatList.__len = function(self)
	return self._count
end

ChatList.__pairs = function(self)
	local indexes, counter = { }, 0
	for k, v in next, self do
		if not tonumber(k) and string_sub(k, 1, 1) ~= '_' then
			counter = counter + 1
			indexes[counter] = v
		end
	end

	local i, chat = 0
	return function()
		i = i + 1

		chat = indexes[i]
		if chat then
			return chat.name, chat
		end
	end
end

ChatList.new = function(self, client)
	return setmetatable({
		_count = 0,
		_currentFingerprint = 0,

		_client = client
	}, self)
end

ChatList.get = function(self, chatName)
	if not self[chatName] then
		self._currentFingerprint = (self._currentFingerprint + 1) % 0xFFFFFFFF

		self[chatName] = Chat:new(self._client, chatName, self._currentFingerprint)
		self[self._currentFingerprint] = self[chatName]

		self._count = self._count + 1
	end

	return self[chatName]
end

return ChatList