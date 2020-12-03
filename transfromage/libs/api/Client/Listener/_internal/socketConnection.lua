local timer = require("timer")

local ByteArray = require("classes/ByteArray")
local enum = require("api/enum")
local killConnections = require("api/Client/utils/_internal/killConnections")
local packetListener = require("api/Client/utils/_internal/packetListener")

------------------------------------------- Optimization -------------------------------------------
local enum_setting        = enum.setting
local timer_clearInterval = timer.clearInterval
local timer_setInterval   = timer.setInterval
----------------------------------------------------------------------------------------------------

local identifier = enum.identifier.initialize

local disconnectionLoop = function(self, client)
	if not client.mainConnection.isOpen then
		timer_clearInterval(client._heartbeatTimer)
		timer_clearInterval(self[1])
		killConnections(client)
	end
end

local onSocketConnection = function(connection)
	local client = connection._client

	local startPacket = ByteArray:new():write16(enum_setting.gameVersion):write8(8)
	if not client._isOfficialBot then
		startPacket
			:writeUTF("en")
			:writeUTF(client._connectionKey)
	end
	startPacket:writeUTF("Desktop"):writeUTF('-'):write32(0x1FBD):writeUTF('')
		:writeUTF(
			-- ;)
			"4c756120697320616c7761797320626574746572207468616e20507974686f6e2c2069736e27742069743f"
		)
		:writeUTF("A=t&SA=t&SV=t&EV=t&MP3=t&AE=t&VE=t&ACC=t&PR=t&SP=f&SB=f&DEB=f&V=LNX 29,0,\z
		0,140&M=Adobe Linux&R=1920x1080&COL=color&AR=1.0&OS=Linux&ARCH=x86&L=en&IME=t&PR32=t&P\z
		R64=t&LS=en-US&PT=Desktop&AVD=f&LFD=f&WD=f&TLS=t&ML=5.1&DP=72")
		:write32(0):write32(0x6257):writeUTF('')

	client.mainConnection:send(identifier, startPacket)

	packetListener(client, "mainConnection")
	packetListener(client, "bulleConnection")

	local loop = { } -- Has to be a table to be passed as reference...
	loop[1] = timer_setInterval(10, disconnectionLoop, loop, client)
end

return onSocketConnection