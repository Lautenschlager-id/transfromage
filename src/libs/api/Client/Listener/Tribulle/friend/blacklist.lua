local onBlackListLoaded = function(self, packet, connection, tribulleId)
	local blackList = { }

	for p = 1, packet:read16() do
		blackList[p] = packet:readUTF()
	end

	--[[@
		@name blackList
		@desc Triggered when the black list is loaded.
		@param blackList<table> An array of strings of the names that are in the black list.
	]]
	self.event:emit("blackList", blackList)
end

return { 47, onBlackListLoaded }