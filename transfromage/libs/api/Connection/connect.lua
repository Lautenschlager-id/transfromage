local Connection = require("./init")

local enum = require("api/enum")

------------------------------------------- Optimization -------------------------------------------
local enum_error           = enum.error
local enum_errorLevel      = enum.errorLevel
local enum_ports           = enum.setting.port
local enum_timer           = enum.timer
local error                = error
local net_createConnection = require("net").createConnection
local timer_setTimeout     = require("timer").setTimeout
----------------------------------------------------------------------------------------------------

local tryPortConnection = function(connection, hasPort, ip, lastSocket)
	if not connection.isOpen then
		lastSocket:destroy()

		if not hasPort then
			connection.portIndex = connection.portIndex + 1
			if connection.portIndex <= #enum_ports then
				return connection:connect(ip)
			end
		end
		return error(enum_error.timeout, enum_errorLevel.high)
	end
end

--[[@
	@name connect
	@desc Creates a socket to connect to the server of the game.
	@param ip<string> The server IP.
	@param port?<int> The server port. If nil, all the available ports are going to be used until one gets connected.
]]
Connection.connect = function(self, ip, port)
	local hasPort = not not port
	if not hasPort then
		port = enum_ports[self.portIndex]
	end

	local socket
	socket = net_createConnection(port, ip, function()
		self.socket = socket

		self.ip = ip
		self.isOpen = true

		--[[@
			@name _socketConnection
			@desc Triggered when the socket gets connected.
			@param connection<connection> The connection.
			@param port<int> The port where the socket got connected.
		]]
		self._client.event:emit("_socketConnection", self, port)
	end)

	socket:on("data", function(data)
		self.Buffer:push(data)
	end)

	socket:once("end", function()
		self.isOpen = false
		self._client.event:emit("disconnection", self)
	end)

	timer_setTimeout(enum_timer.socketTimeout, tryPortConnection, self, hasPort, ip, socket)
end