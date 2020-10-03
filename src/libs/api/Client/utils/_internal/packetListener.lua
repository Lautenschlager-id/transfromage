local timer_setInterval = require("timer").setInterval

local onReceive = require("api/Client/Listener/_internal/receive")

--[[@
	@name receive
	@desc Creates a new timer attached to a connection object to receive packets and parse them.
	@param self<client> A Client object.
	@param connectionName<string> The name of the Connection object to get the timer attached to.
]]
local packetListener = function(client, connection)
	connection._listenLoop = timer_setInterval(10, onReceive, client, connection)
end

return packetListener