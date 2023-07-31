local timer = require("timer")

local enum = require("api/enum")
local onReceive = require("api/Client/Listener/_internal/receive")

------------------------------------------- Optimization -------------------------------------------
local enum_timer          = enum.timer
local timer_clearInterval = timer.clearInterval
local timer_setInterval   = timer.setInterval
----------------------------------------------------------------------------------------------------

local tryListeningSetup = function(self, client, connectionFieldName)
	local connection = client[connectionFieldName]
	if not (connection and connection.isOpen and not connection._listenLoop) then return end

	connection._listenLoop = timer_setInterval(enum_timer.listenerLoop, onReceive, client,
		connection)

	timer_clearInterval(self[1])
end

--[[@
	@name receive
	@desc Creates a new timer attached to a connection object to receive packets and parse them.
	@param self<client> A Client object.
	@param connectionName<string> The name of the Connection object to get the timer attached to.
]]
local packetListener = function(client, connectionFieldName)
	local self = { }
	self[1] = timer_setInterval(50, tryListeningSetup, self, client, connectionFieldName)
end

return packetListener