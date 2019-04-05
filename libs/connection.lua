local net = require("net")

local byteArray = require("bArray")
local buffer = require("buffer")
local timer = require("timer")
local enum = require("enum")
if not string.getBytes then
	require("extensions")
end

local connectionHandler = { }
connectionHandler.__index = connectionHandler

connectionHandler.new = function(self, name, event)
	local data = {
		event = (event or { }),
		socket = nil,
		buffer = buffer:new(),
		ip = "",
		packetID = 0,
		port = 1,
		name = name,
		open = false
	}

	return setmetatable(data, connectionHandler)
end

connectionHandler.connect = function(self, ip, port)
	local hasPort = not not port
	if not hasPort then
		port = enum.setting.port[self.port]
	end

	local socket
	socket = net.createConnection(port, ip, function()
		self.socket = socket

		self.ip = ip
		self.open = true

		socket:on("data", function(data)
			self.buffer:push(data)
		end)

		self.event:emit("_socketConnection", self, port)
	end)

	timer.setTimeout(3500, function()
		if not self.open then
			if not hasPort then
				self.port = self.port + 1
				if self.port <= #enum.setting.port then
					return self:connect(ip)
				end
			end
			return error("Socket timed out.", 0)
		end
	end)
end

connectionHandler.receive = function(self)
	if self.buffer:isEmpty() then return end
	local stackLenSize = self.buffer:receive(1)[1]

	if stackLenSize > 0 then
		local byteArr = self.buffer:receive(stackLenSize)
		local stackLen = 0

		for i = 1, #byteArr do
			stackLen = stackLen + bit.lshift(byteArr[i], (8 * (stackLenSize - i)))
		end

		return self.buffer:receive(stackLen)
	end
	return { }
end

connectionHandler.send = function(self, identifiers, alphaPacket)
	local betaPacket
	if type(alphaPacket) == "table" then
		if alphaPacket.stack then
			betaPacket = byteArray:new(table.fuse(identifiers, alphaPacket.stack))
		else
			local bytes = { "0x" .. (string.format("%02x", identifiers[1]) .. string.format("%02x", identifiers[2])), 0x1, table.join(alphaPacket, 0x1) }
			betaPacket = byteArray:new():write8(1, 1):writeUTF(bytes)
		end
	elseif type(alphaPacket) == "string" then
		betaPacket = byteArray:new(table.fuse(identifiers, string.getBytes(alphaPacket)))
	elseif type(alphaPacket) == "number" then
		local arg = { table.unpack(identifiers) }
		arg[#arg + 1] = alphaPacket

		betaPacket = byteArray:new():write8(table.unpack(arg))
	else
		return error("[Send] Unknown packet type.\n\tIdentifiers: " .. table.concat(identifiers, ','), 0)
	end

	local gammaPacket
	local stackLen = #betaPacket.stack
	if stackLen < 256 then
		gammaPacket = byteArray:new():write8(1, stackLen)
	elseif stackLen < 65536 then
		gammaPacket = byteArray:new():write8(2):write16(stackLen)
	elseif stackLen < 16777216 then
		gammaPacket = byteArray:new():write8(3):write24(stackLen)
	else
		return error("[Send] The packet length is too big! (" .. stackLen .. ")\n\tIdentifiers: " .. table.concat(identifiers, ','), 0)
	end

	gammaPacket:write8(self.packetID)
	self.packetID = (self.packetID + 1) % 100

	table.add(gammaPacket.stack, betaPacket.stack)

	local written = self.socket:write(table.writeBytes(gammaPacket.stack))
	if not written then
		self.open = false
		self.event:emit("disconnection", self)
	end

	--[[@
		@desc Triggered when the client sends packets to the server.
		@param identifiers<table> The C, CC identifiers sent in the request.
		@param packet<bArray> The Byte Array object that was sent.
	]]
	self.event:emit("send", identifiers, alphaPacket)
end

return connectionHandler