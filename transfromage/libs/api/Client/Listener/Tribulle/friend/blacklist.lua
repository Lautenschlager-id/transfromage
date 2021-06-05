------------------------------------------- Optimization -------------------------------------------
local string_toNickname = string.toNickname
----------------------------------------------------------------------------------------------------

local onBlackListLoaded = function(self, packet, connection, tribulleId)
	local blackList = { }

	for p = 1, packet:read16() do
		blackList[p] = string_toNickname(packet:readUTF(), true)
	end

	--[[@
		@name blackList
		@desc Triggered when the black list is loaded.
		@param blackList<table> An array of strings of the names that are in the black list.
	]]
	self.event:emit("blackList", blackList)
end

return { onBlackListLoaded, 47 }