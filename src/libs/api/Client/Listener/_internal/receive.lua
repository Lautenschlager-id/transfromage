local ByteArray = require("classes/ByteArray")

local onReceive = function(client, connection)
	if not connection.isOpen then return end

	local packet = connection:receive()
	if not packet then return end

	local identifiers = packet:read8(2)
	if client.event.handlers.receive then -- Don't create a new bytearray if it's not needed
		--[[@
			@name receive
			@desc Creates a new timer attached to a connection object to receive packets and parse them.
			@param self<client> A Client object.
			@param connectionName<string> The name of the Connection object to get the timer attached to.
		]]
		client.event:emit("receive", connection, identifiers, ByteArray:new(packet))
	end
	parsePacket(client, connection, identifiers, packet)
end

return onReceive