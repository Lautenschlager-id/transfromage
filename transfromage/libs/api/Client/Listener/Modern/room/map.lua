local onNewGame = function(self, packet, connection, identifiers)
	local map = self.room:newMap(packet, self._decryptXML)

	--[[@
		@name newGame
		@desc Triggered when a map is loaded.
		@desc /!\ This event may increase the memory consumption significantly due to the XML processes. Set the variable `_processXml` as false to avoid processing it.
		@param map<table> The new map data.
		@struct @map {
			code = 0, -- The map code.
			xml = "", -- The map XML. May be nil if the map is Vanilla.
			author = "", -- The map author
			perm = 0, -- The perm code of the map.
			isMirrored = false -- Whether the map is mirrored or not.
		}
	]]
	self.event:emit("newGame", map)
end

return { onNewGame, 5, 2 }