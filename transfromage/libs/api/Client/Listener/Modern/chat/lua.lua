local onLuaMessage = function(self, packet, connection, identifiers)
	self.event:emit("luaMessage", packet:readUTF())
end

return { onLuaMessage, 6, 9 }