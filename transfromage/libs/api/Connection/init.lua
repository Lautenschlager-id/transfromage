local Buffer = require("classes/Buffer")

------------------------------------------- Optimization -------------------------------------------
local setmetatable = setmetatable
----------------------------------------------------------------------------------------------------

local Connection = table.setNewClass()

--[[@
	@name new
	@desc Creates a new instance of Connection.
	@param name<string> The connection name, for referece.
	@param event<Emitter> An event emitter object.
	@returns connection The new Connection object.
	@struct {
		event = { }, -- The event emitter object, used to trigger events.
		socket = { }, -- The socket object, used to create the connection between the bot and the game.
		buffer = { }, -- The buffer object, used to control the packets flow when received by the socket.
		ip = "", -- IP of the server where the socket is connected. Empty if it is not connected.
		packetID = 0, -- An identifier ID to send the packets in the correct format.
		port = 1, -- The index of one of the ports from the enumeration 'ports'. It gets constant once a port is accepted in the server.
		name = "", -- The name of the connection object, for reference.
		open = false, -- Whether the connection is open or not.
		_isReadingStackLength = true, -- Whether the connection is reading the length of the received packet or not.
		_readStackLength = 0, -- Length read at the moment.
		_lengthBytes = 0 -- Number of bytes read (real value needs a divison by 7).
	}
]]
Connection.new = function(self, name, event)
	return setmetatable({
		name = name,

		isOpen = false,
		socket = nil,
		buffer = Buffer:new(),

		event = event,

		ip = "",
		portIndex = 1,

		packetID = 0,

		_listenLoop = nil,

		_isReadingStackLength = true,
		_lengthBytes = 0,
		_readStackLength = 0,

		_client = nil
	}, self)
end

return Connection