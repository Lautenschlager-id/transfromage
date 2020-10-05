local Connection = require("./init")

------------------------------------------- Optimization -------------------------------------------
local timer_clearInterval  = require("timer").clearInterval
----------------------------------------------------------------------------------------------------

--[[@
	@name close
	@desc Ends the socket connection.
]]
Connection.close = function(self)
	if not self.socket then return end

	timer_clearInterval(self._listenLoop)

	self.isOpen = false
	self.port = 1
	self.socket:destroy()
	self.packetID = 0

	--[[@
		@name disconnection
		@desc Triggered when a connection dies or fails.
		@param connection<connection> The connection object.
	]]
	self.event:emit("disconnection", self)
end