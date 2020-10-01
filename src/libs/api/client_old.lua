local timer = require("timer")
local event = require("core").Emitter
local http_request = require("coro-http").request
local json_decode = require("json").decode
local zlibDecompress = require("miniz").inflate
local uv = require("uv")

local byteArray = require("bArray")
local connection = require("connection")
local encode = require("encode")
local enum = require("enum")

-- Optimization --
local bit_bxor = bit.bxor
local coroutine_makef = coroutine.makef
local coroutine_running = coroutine.running
local coroutine_resume = coroutine.resume
local coroutine_yield = coroutine.yield
local encode_getPasswordHash = encode.getPasswordHash
local enum_validate = enum._validate
local math_normalizePoint = math.normalizePoint
local os_exit = os.exit
local string_byte = string.byte
local string_fixEntity = string.fixEntity
local string_format = string.format
local string_gsub = string.gsub
local string_split = string.split
local string_sub = string.sub
local string_toNickname = string.toNickname
local table_copy = table.copy
local table_remove = table.remove
local table_setNewClass = table.setNewClass
local table_writeBytes = table.writeBytes
local timer_clearInterval = timer.clearInterval
local timer_clearTimeout = timer.clearTimeout
local timer_setInterval = timer.setInterval
local timer_setTimeout = timer.setTimeout
local uv_signal_start = uv.signal_start
local uv_new_signal = uv.new_signal
------------------

local parsePacket, receive, sendHeartbeat, getKeys, closeAll
local tribulleListener, oldPacketListener, packetListener
local handlePlayerField, handleFriendData, handleTribeMemberData
local stopHandlingPlayers
do
	event.waitFor = function(self, eventName, timeout, predicate)
		local coro = coroutine_running()
		assert(coro, "Emitter:waitFor must be called inside a coroutine.")

		local waiter
		waiter = function(...)
			if not predicate or predicate(...) then
				if timeout then timer_clearTimeout(timeout) end

				self:removeListener(eventName, waiter)
				return assert(coroutine_resume(coro, true, ...))
			end
		end
		self:on(eventName, waiter)

		timeout = timeout and timer_setTimeout(timeout, function()
			self:removeListener(eventName, waiter)
			return assert(coroutine_resume(coro, false))
		end)

		return coroutine_yield()
	end
end

-- System
-- Packet listeners and parsers
--[[@
	@name insertPacketListener
	@desc Inserts a new function to the packet parser.
	@param C<int> The C packet.
	@param CC<int> The CC packet.
	@param f<function> The function to be triggered when the @C-@CC packets are received. The parameters are (self, packet, connection, identifiers).
	@param append?<boolean> 'true' if the function should be appended to the (C, CC) listener, 'false' if the function should overwrite the (C, CC) listener. @default false
]]
Client.insertPacketListener = function(self, C, CC, f, append)
	if not packetListener[C] then
		packetListener[C] = { }
	end

	f = coroutine_makef(f)
	if append and packetListener[C][CC] then
		local old = packetListener[C][CC]
		packetListener[C][CC] = function(packet, ...)
			old(byteArray:new(packet.stack), ...)
			f(packet, ...)
		end
	else
		packetListener[C][CC] = f
	end
end
--[[@
	@name insertTribulleListener
	@desc Inserts a new function to the tribulle (60, 3) packet parser.
	@param tribulleId<int> The tribulle id.
	@param f<function> The function to be triggered when this tribulle packet is received. The parameters are (self, packet, connection, tribulleId).
	@param append?<boolean> 'true' if the function should be appended to the (C, CC, tribulle) listener, 'false' if the function should overwrite the (C, CC) listener. @default false
]]
Client.insertTribulleListener = function(self, tribulleId, f, append)
	f = coroutine_makef(f)
	if append and tribulleListener[tribulleId] then
		local old = tribulleListener[tribulleId]
		tribulleListener[tribulleId] = function(packet, ...)
			old(byteArray:new(packet.stack), ...)
			f(packet, ...)
		end
	else
		tribulleListener[tribulleId] = f
	end
end
--[[@
	@name insertOldPacketListener
	@desc Inserts a new function to the old packet parser.
	@param C<int> The C packet.
	@param CC<int> The CC packet.
	@param f<function> The function to be triggered when the @C-@CC packets are received. The parameters are (self, data, connection, oldIdentifiers).
	@param append?<boolean> 'true' if the function should be appended to the (C, CC) listener, 'false' if the function should overwrite the (C, CC) listener. @default false
]]
Client.insertOldPacketListener = function(self, C, CC, f, append)
	if not oldPacketListener[C] then
		oldPacketListener[C] = { }
	end

	f = coroutine_makef(f)
	if append and oldPacketListener[C][CC] then
		oldPacketListener[C][CC] = function(data, ...)
			oldPacketListener[C][CC](table_copy(data), ...)
			f(data, ...)
		end
	else
		oldPacketListener[C][CC] = f
	end
end

--[[@
	@name parsePacket
	@desc Handles the received packets by triggering their listeners.
	@param self<client> A Client object.
	@param connection<connection> A Connection object attached to @self.
	@param packet<byteArray> THe packet to be parsed.
]]
parsePacket = function(self, connection, packet)
	local identifiers = packet:read8(2)
	local C, CC = identifiers[1], identifiers[2]

	if packetListener[C] and packetListener[C][CC] then
		return packetListener[C][CC](self, packet, connection, identifiers)
	end
	--[[@
		@name missedPacket
		@desc Triggered when an identifier is not handled by the system.
		@param identifiers<table> The C, CC identifiers that were not handled.
		@param packet<byteArray> The Byte Array object with the packet that was not handled.
		@param connection<connection> The connection object.
	]]
	self.event:emit("missedPacket", identifiers, packet, connection)
end


--[[@
	@name closeAll
	@desc Closes all the Connection objects.
	@desc Note that a new Client instance should be created instead of closing and re-opening an existent one.
	@param self<client> A Client object.
]]
closeAll = function(self)
	if self.main then
		if self.bulle then
			timer_clearInterval(self._bulleLoop)
			self.bulleConnection:close()
		end
		timer_clearInterval(self._mainLoop)
		self.mainConnection:close()
	end
end
--[[@
	@name handlePlayerField
	@desc Handles the packets that alters only one player data field.
	@param self<client> A Client object.
	@param packet<byteArray> A Byte Array object with the data to be extracted.
	@param fieldName<string> THe name of the field to be altered.
	@param eventName?<string> The name of the event to be triggered. @default "updatePlayer"
	@param methodName?<string> The name of the ByteArray function to be used to extract the data from @packet. @default "readBool"
	@param fieldValue?<*> The value to be set to the player data @fieldName. @default Extracted data
	@param sendValue?<boolean> Whether the new value should be sent as second argument of the event or not. @default false
]]
handlePlayerField = function(self, packet, fieldName, eventName, methodName, fieldValue, sendValue)
	-- This method would be a table with settings, but since it's created many times I have decided
	-- to keep it as parameters.
	if stopHandlingPlayers(self) then return end

	local playerId = packet:read32()
	if self.playerList[playerId] then
		if fieldValue == nil then
			fieldValue = packet[(methodName or "readBool")](packet)
		end

		local oldPlayerData
		if not eventName then -- updatePlayer
			oldPlayerData = table_copy(self.playerList[playerId])
		end

		self.playerList[playerId][fieldName] = fieldValue

		--[[@
			@name updatePlayer
			@desc Triggered when a player field is updated.
			@param playerData<table> The data of the player.
			@param oldPlayerData<table> The data of the player before the new values.
			@struct @playerdata @oldPlayerData {
				playerName = "", -- The nickname of the player.
				id = 0, -- The temporary id of the player during the section.
				isShaman = false, -- Whether the player is shaman or not.
				isDead = false, -- Whether the player is dead or alive.
				score = 0, -- The current player's score.
				hasCheese = false, -- Whether the player has cheese or not.
				title = 0, -- The player's title id.
				titleStars = 0, -- The number of stars the player's title has.
				gender = 0, -- The player's gender. Enum in enum.gender.
				look = "", -- The current outfit string code of the player.
				mouseColor = 0, -- The color of the player. It is set to -1 if it's the default color.
				shamanColor = 0, -- The color of the player as shaman.
				nameColor = 0, -- The color of the nickname of the player.
				isSouris = false, -- Whether the player is souris or not.
				isVampire = false, -- Whether the player is vampire or not.
				hasWon = false, -- Whether the player has entered the hole in the round or not.
				winPosition = 0, -- The position where the player entered the hole. It is set to -1 if it has not won yet.
				winTimeElapsed = 0, -- Time elapsed until the player enters the hole. It is set to -1 if it has not won yet.
				isFacingRight = false, -- Whether the player is facing right.
				movingRight = false, -- Whether the player is moving right.
				movingLeft = false, -- Whether the player is moving left.
				isBlueShaman = false, -- Whether the player is the blue shaman.
				isPinkShaman = false, -- Whether the player is the pink shaman.
				x = 0, -- Player's X coordinate in the map.
				y = 0, -- Player's X coordinate in the map.
				vx = 0, -- Player's X speed in the map.
				vy = 0, -- Player's Y speed in the map.
				isDucking = false, -- Whether the player is ducking.
				isJumping = false, -- Whether the player is jumping.
				_pos = 0 -- The position of the player in the array list. This value should never be changed manually.
			}
		]]
		self.event:emit((eventName or "updatePlayer"), self.playerList[playerId],
			(oldPlayerData or (sendValue and fieldValue)))
	end
end
--[[@
	@name stopHandlingPlayers
	@desc Checks whether the player handler should NOT be executed.
	@param self<client> A Client object.
	@returns boolean Whether player handling is disabled or if there are not enough players in the room.
]]
stopHandlingPlayers = function(self)
	return not self._handlePlayers or self.playerList.count == 0
end



-- Methods
-- Initialization

-- Connection
do
	local triggerConnectionFailed = function(self)
		if self.event.handlers.connectionFailed then
			--[[@
				@name connectionFailed
				@desc Triggered when it fails to login.
			]]
			self.event:emit("connectionFailed")
		else
			return error("↑error↓[LOGIN]↑ Impossible to log in. Try again later.",
				enum.errorLevel.low)
		end
	end

	local checkConnection = function(self)
		if not self._isConnected then
			self:disconnect()
			-- This timer prevents the time out issue, since it gives time to closeAll work.
			timer_setTimeout(2000, triggerConnectionFailed, self)
		end
	end

	--[[@
		@name connect
		@desc Connects to an account in-game.
		@desc It will try to connect using all the available ports before throwing a timing out error.
		@param userName<string> The name of the account. It must contain the discriminator tag (#).
		@param userPassword<string> The password of the account.
		@param startRoom?<string> The name of the initial room. @default "*#bolodefchoco"
		@param timeout<int> The time in ms to throw a timeout error if the connection takes too long to succeed. @default 20000
	]]
	Client.connect = function(self, userName, userPassword, startRoom, timeout)
		userName = string_toNickname(userName, true)

		local packet = ByteArray:new()
			:writeUTF(userName)
			:writeUTF(encode_getPasswordHash(userPassword))
			:writeUTF("app:/TransformiceAIR.swf/[[DYNAMIC]]/2/[[DYNAMIC]]/4")
			:writeUTF((startRoom and tostring(startRoom)) or "*#bolodefchoco")
		if not self._hasSpecialRole then
			packet:write32(bit_bxor(self._receivedAuthkey, self._gameAuthkey))
		end
		packet:write8(0):writeUTF('')
		if not self._hasSpecialRole then
			packet = self._encode:btea(packet)
		end
		packet:write8(0)

		self.playerName = userName
		self.mainConnection:send(enum.identifier.loginSend, packet)

		timer_setTimeout((timeout or (20 * 1000)), checkConnection, self)
	end
end

-- Miscellaneous



----- Compatibility -----
Client.insertReceiveFunction = "insertPacketListener"
Client.insertTribulleFunction = "insertTribulleListener"
Client.closeAll = "disconnect"
-------------------------

