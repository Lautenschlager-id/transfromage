local ByteArray = require("classes/ByteArray")
local Connection = require("api/Connection")
local enum = require("api/enum")

------------------------------------------- Optimization -------------------------------------------
local enum_setting = enum.setting
local string_split = string.split
----------------------------------------------------------------------------------------------------

local identifier = enum.identifier.bulleConnection

local onBulleSwitch = function(self, packet, connection, identifiers)
	local serverTimestamp = packet:read32()

	local uid = packet:read32()
	local pid = packet:read32()

	local bulleIp = packet:readUTF()

	enum_setting.port = string_split(packet:readUTF(), '-', true)

	local oldBulle = self.bulleConnection

	self.bulleConnection = Connection:new(self, "bulle")
	self.bulleConnection:connect(bulleIp, enum_setting.port[self.mainConnection.portIndex])

	self.event:once("_socketConnection", function()
		if oldBulle then
			oldBulle:close()
		else
			-- Triggered on the first bulle connection, i.e., when the account is ready to be used.
			self.event:emit("connection")
		end

		self.bulleConnection:send(identifier,
			ByteArray:new():write32(serverTimestamp):write32(uid):write32(pid))

		--[[@
			@name switchBulleConnection
			@desc Triggered when the bulle connection is switched.
			@param bulleId<int> The ID of the new bulle.
			@param bulleIp<string> The IP of the new bulle.
			@param serverTimestamp<int> The timestamp of the server.
		]]
		self.event:emit("switchBulleConnection", bulleId, bulleIp, serverTimestamp)
	end)
end

return { onBulleSwitch, 44, 1 }