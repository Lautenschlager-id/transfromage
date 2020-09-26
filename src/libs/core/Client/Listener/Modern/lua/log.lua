local onLua = function(self, packet, connection, identifiers)
	--[[@
		@name lua
		@desc Triggered when the #lua chat receives a log message.
		@param log<string> The log message.
	]]
	self.event:emit("lua", packet:readUTF())
end

return {
	{ 29, 6, onLua }
}