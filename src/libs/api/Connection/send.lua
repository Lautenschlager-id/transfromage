local Connection = require("./init")

local ByteArray = require("classes/ByteArray")

------------------------------------------- Optimization -------------------------------------------
local bit_band             = bit.band
local bit_bor              = bit.bor
local bit_rshift           = bit.rshift
local enum_setting         = require("api/enum").setting
local table_add            = table.add
local table_fuse           = table.fuse
local table_writeBytes     = table.writeBytes
----------------------------------------------------------------------------------------------------

--[[@
	@name send
	@desc Sends a packet to the server.
	@param identifiers<table> The packet identifiers in the format (C, CC).
	@param alphaPacket<ByteArray> The packet ByteArray to be sent to the server.
]]
Connection.send = function(self, identifiers, alphaPacket)
	local betaPacket = ByteArray:new(table_fuse(identifiers, alphaPacket.stack))

	local stackLen = betaPacket.stackLen
	local stackType = bit_rshift(stackLen, 7)

	local gammaPacket = ByteArray:new()
	while stackType ~= 0 do
		gammaPacket:write8(bit_bor(bit_band(stackLen, 0x7F), 0x80)) -- s&0x7F | 0x80
		stackLen = stackType
		stackType = bit_rshift(stackLen, 7)
	end
	gammaPacket:write8(bit_band(stackLen, 0x7F))

	gammaPacket:write8(self.packetID)
	self.packetID = (self.packetID + 1) % 100

	table_add(gammaPacket.stack, betaPacket.stack)

	local written = self.socket and self.socket:write(table_writeBytes(gammaPacket.stack))
	if not written then
		self.isOpen = false
		if self.ip ~= enum_setting.mainIp then -- Avoids that 'disconnection' gets triggered twice when it is the main instance.
			self.event:emit("disconnection", self)
			return
		end
	end

	--[[@
		@name send
		@desc Triggered when the client sends packets to the server.
		@param identifiers<table> The C, CC identifiers sent in the request.
		@param packet<ByteArray> The Byte Array object that was sent.
	]]
	self.event:emit("send", identifiers, alphaPacket)
end