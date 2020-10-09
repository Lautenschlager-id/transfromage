local timer_setInterval = require("timer").setInterval

local ByteArray = require("classes/ByteArray")

------------------------------------------- Optimization -------------------------------------------
local enum_identifier = require("api/enum").identifier
local os_time         = os.time
----------------------------------------------------------------------------------------------------

--[[@
	@name sendHeartbeat
	@desc Sends server heartbeats/pings to the servers.
	@param self<client> A Client object.
]]
sendHeartbeat = function(self)
	self.mainConnection:send(enum_identifier.heartbeat, ByteArray:new())
	if self.bulleConnection and self.bulleConnection.isOpen then
		self.bulleConnection:send(enum_identifier.heartbeat, ByteArray:new())
	end

	--[[@
		@name heartbeat
		@desc Triggered when a heartbeat is sent to the connection, every 10 seconds.
		@param time<int> The current time.
	]]
	self.event:emit("heartbeat", os_time())
end

local onReady = function(self, packet, connection, identifiers)
	local onlinePlayers = packet:read32()

	local language = packet:readUTF()
	local country = packet:readUTF()

	-- Receives an authentication key, parsed in the login function
	self._authenticationKey = packet:read32()

	self._heartbeatTimer = timer_setInterval(10 * 1000, sendHeartbeat, self)

	self.mainConnection:send(enum_identifier.language, ByteArray:new():writeUTF(self.language))

	self.mainConnection:send(enum_identifier.os, ByteArray:new()
		:writeUTF("en"):writeUTF("Linux")
		:writeUTF("LNX 29,0,0,140"):write8(0))

	--[[@
		@name ready
		@desc Triggered when the connection is alive and ready to login.
		@param onlinePlayers<int> The number of players connected in the game.
		@param country<string> The client's country.
		@param language<string> The language based on the account's country.
	]]
	self.event:emit("ready", onlinePlayers, country, language)
end

return { onReady, 26, 3 }