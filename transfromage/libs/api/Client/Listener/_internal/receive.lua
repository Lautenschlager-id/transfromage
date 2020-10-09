local modernListener = require("api/Client/Listener/Modern/init")

local ByteArray = require("classes/ByteArray")

--[[@
	@name parsePacket
	@desc Handles the received packets by triggering their listeners.
	@param self<client> A Client object.
	@param connection<connection> A Connection object attached to @self.
	@param packet<byteArray> THe packet to be parsed.
]]
local triggerPacketCallback = function(client, connection, identifiers, packet)
	local callback = modernListener[identifiers[1]]
	callback = callback and callback[identifiers[2]]

	if callback then
		return callback(client, packet, connection, identifiers)
	end

	--[[@
		@name missedPacket
		@desc Triggered when an identifier is not handled by the system.
		@param identifiers<table> The C, CC identifiers that were not handled.
		@param packet<byteArray> The Byte Array object with the packet that was not handled.
		@param connection<connection> The connection object.
	]]
	client.event:emit("missedPacket", identifiers, packet, connection)
end

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
		client.event:emit("receive", connection, identifiers, ByteArray:new(packet.stack))
	end
	triggerPacketCallback(client, connection, identifiers, packet)
end

return onReceive