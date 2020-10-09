local enum = require("api/enum")
local onReceive = require("api/Client/Listener/_internal/receive")

------------------------------------------- Optimization -------------------------------------------
local enum_timers       = enum.timers
local timer_setInterval = require("timer").setInterval
----------------------------------------------------------------------------------------------------

--[[@
	@name receive
	@desc Creates a new timer attached to a connection object to receive packets and parse them.
	@param self<client> A Client object.
	@param connectionName<string> The name of the Connection object to get the timer attached to.
]]
local packetListener = function(client, connection)
	connection._listenLoop = timer_setInterval(enum_timers.listenerLoop, onReceive, client,
		connection)
end

return packetListener