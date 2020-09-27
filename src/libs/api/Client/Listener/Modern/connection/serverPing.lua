-- Optimization --
local os_time = os.time
------------------

local onServerPing = function(self, packet, connection, identifiers)
	--[[@
		@name ping
		@desc Triggered when a server heartbeat is received.
		@param time<int> The current time.
	]]
	self.event:emit("serverPing", os_time())
end

return { 28, 6, onServerPing }