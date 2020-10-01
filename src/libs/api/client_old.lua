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
	@name receive
	@desc Creates a new timer attached to a connection object to receive packets and parse them.
	@param self<client> A Client object.
	@param connectionName<string> The name of the Connection object to get the timer attached to.
]]
receive = function(self, connectionName)
	self["_" .. connectionName .. "Loop"] = timer_setInterval(10, function(self)
		if self[connectionName] and self[connectionName].open then
			local packet = self[connectionName]:receive()
			if not packet then return end

			--[[@
				@name _receive
				@desc Triggered when the socket receives a packet. (Initial stage, before @see receive)
				@param connection<connection> The connection where the packet came from.
				@param packet<bArray> The packet received.
			]]
			self.event:emit("_receive", self[connectionName], byteArray:new(packet))
			parsePacket(self, self[connectionName], byteArray:new(packet))
		end
	end, self)
end
--[[@
	@name getKeys
	@desc Gets the connection keys and settings in the API endpoint.<br>
	@desc If @self.hasSpecialRole is true, the endpoint is only going to be requested if updateSettings is also true, and only the IP/Ports are going to be updated.
	@param self<client> A Client object.
	@param tfmId<string,int> The developer's transformice id.
	@param token<string> The developer's token.
]]
getKeys = function(self, tfmId, token)
	if not self._hasSpecialRole or self._updateSettings then
		-- Uses requires because it's used only once before it gets deleted.
		local _, result = http_request("GET", string_format(enum.url.authKeys, tfmId, token))
		local rawresult = result
		result = json_decode(result)
		if not result then
			return error("↑error↓[API ENDPOINT]↑ ↑highlight↓TFMID↑ or ↑highlight↓TOKEN↑ value is \z
				invalid.\n\t" .. tostring(rawresult), enum.errorLevel.high)
		end

		if result.success then
			if not result.internal_error then
				enum.setting.mainIp = result.ip
				if not self._hasSpecialRole then
					self._gameVersion = result.version
					self._gameConnectionKey = result.connection_key
					self._gameAuthkey = result.auth_key
					self._encode.identificationKeys = result.identification_keys
					self._encode.messageKeys = result.msg_keys
				end
			else
				return not self._hasSpecialRole and error(string_format("↑error↓[API ENDPOINT]↑ An internal error occurred in \z
					the API endpoint.\n\t'%s'%s", result.internal_error_step,
					(result.internal_error_step == 2 and ": The game may be in maintenance." or '')
				), enum.errorLevel.high)
			end
		else
			return not self._hasSpecialRole and error("↑error↓[API ENDPOINT]↑ Impossible to get the keys.\n\tError: " ..
				tostring(result.error), enum.errorLevel.high)
		end
	end
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

--[[@
	@name start
	@desc Initializes the API connection with the authentication keys. It must be the first method of the API to be called.
	@param tfmId<string,int> The Transformice ID of your account. If you don't know how to obtain it, go to the room **#bolodefchoco0id** and check your chat.
	@param token<string> The API Endpoint token to get access to the authentication keys.
]]
Client.start = coroutine_makef(function(self, tfmId, token)
	self:disconnect()
	self.isConnected = false

	getKeys(self, tfmId, token)

	self.mainConnection:connect(enum.setting.mainIp)

	self.main.event:once("_socketConnection", function()
		local packet = ByteArray:new():write16(self._gameVersion)
		if not self._hasSpecialRole then
			packet
				:writeUTF("en")
				:writeUTF(self._gameConnectionKey)
		end
		packet:writeUTF("Desktop"):writeUTF('-'):write32(0x1FBD):writeUTF('')
			:writeUTF("86bd7a7ce36bec7aad43d51cb47e30594716d972320ef4322b7d88a85904f0ed")
			:writeUTF("A=t&SA=t&SV=t&EV=t&MP3=t&AE=t&VE=t&ACC=t&PR=t&SP=f&SB=f&DEB=f&V=LNX 29,0,\z
			0,140&M=Adobe Linux&R=1920x1080&COL=color&AR=1.0&OS=Linux&ARCH=x86&L=en&IME=t&PR32=t&P\z
			R64=t&LS=en-US&PT=Desktop&AVD=f&LFD=f&WD=f&TLS=t&ML=5.1&DP=72")
			:write32(0):write32(0x6257):writeUTF('')

		self.mainConnection:send(enum.identifier.initialize, packet)

		receive(self, "main")
		receive(self, "bulle")
		local loop
		loop = timer_setInterval(10, function(self)
			if not self.main.open then
				timer_clearInterval(self._hbTimer)
				timer_clearInterval(loop)
				closeAll(self)
			end
		end, self)
	end)

	self.main.event:on("_receive", function(connection, packet)
		--[[@
			@name receive
			@desc Triggered when the client receives packets from the server.
			@param connection<connection> The connection object that received the packets.
			@param identifiers<table> The C, CC identifiers that were received.
			@param packet<byteArray> The Byte Array object that was received.
		]]
		self.event:emit("receive", connection, packet:read8(2), packet)
	end)

	-- Triggered when the developer uses CTRL+C to leave the command prompt.
	if not self._isListeningSigint then
		self._isListeningSigint = true

		local isClosing = false
		local endProcess = function()
			if isClosing then return end
			isClosing = true

			closeAll(self)
			timer_setTimeout(100, os_exit)
		end

		uv_signal_start(uv_new_signal(), "sigint", endProcess)
		uv_signal_start(uv_new_signal(), "sighup", endProcess)
	end
end)
--[[@
	@name on
	@desc Sets an event emitter that is triggered everytime a specific behavior happens.
	@desc See the available events in @see Events.
	@param eventName<string> The name of the event.
	@param callback<function> The function that must be called when the event is triggered.
]]
Client.on = function(self, eventName, callback)
	return self.event:on(eventName, coroutine_makef(callback))
end
--[[@
	@name once
	@desc Sets an event emitter that is triggered only once a specific behavior happens.
	@desc See the available events in @see Events.
	@param eventName<string> The name of the event.
	@param callback<function> The function that must be called only once when the event is triggered.
]]
Client.once = function(self, eventName, callback)
	return self.event:once(eventName, coroutine_makef(callback))
end
--[[@
	@name waitFor
	@desc Yields the running coroutine and will resume it when the given event is triggered.
	@desc If a timeout (in milliseconds) is provided, the function will return after that timeout expires unless the given event has been triggered before.
	@desc If a predicate is provided, events that do not pass the predicate will be ignored.
	@desc See the available events in @see Events.
	@param eventName<string> The name of the event.
	@param timeout?<int> The time to timeout the yield.
	@param predicate?<function> The predicate that checks whether the triggered event refers to the right one. Must return a boolean.
	@returns boolean Whether it has not timed out and triggered successfully.
	@returns ... The parameters of the event.
]]
Client.waitFor = function(self, eventName, timeout, predicate)
	return self.event:waitFor(eventName, timeout, predicate)
end
--[[@
	@name emit
	@desc Emits an event.
	@desc See the available events in @see Events. You can also create your own events / emitters.
	@param eventName<string> The name of the event.
	@param ...?<*> The parameters to be passed during the emitter call.
]]
Client.emit = function(self, eventName, ...)
	return self.event:emit(eventName, ...)
end
--[[@
	@name connectionTime
	@desc Gets the total time since the account was connected.
	@returns int The total time since account was logged in.
]]
Client.connectionTime = function(self)
	return os.time() - self._connectionTime
end

-- Methods
-- Initialization
--[[@
	@name setLanguage
	@desc Sets the language the bot will connect to.
	@desc /!\ This method must be called before the @see start.
	@param language?<enum.language> An enum from @see language. (index or value) @default EN
]]
Client.setLanguage = function(self, language)
	language = enum_validate(enum.language, enum.language.en, language,
		string_format(enum.error.invalidEnum, "setCommunity", "language", "language"))
	if not language then return end

	self.language = language
end
--[[@
	@name handlePlayers
	@desc Toggles the field _\_handle\_players_ of the instance.
	@desc If 'true', the following events are going to be handled: _playerGetCheese_, _playerVampire_, _playerWon_, _playerLeft_, _playerDied_, _newPlayer_, _refreshPlayerList_, _updatePlayer_, _playerEmote_.
	@param handle?<boolean> Whether the bot should handle the player events. The default value is the inverse of the current value. The instance starts the field as 'false'.
	@returns boolean Whether the bot will handle the player events.
]]
Client.handlePlayers = function(self, handle)
	if handle == nil then
		self._handlePlayers = not self._handlePlayers
	else
		self._handlePlayers = handle
	end
	return self._handlePlayers
end
--[[@
	@name processXml
	@desc Toggles the field _\_process\_xml_ of the instance.
	@desc If 'true', the XML will be processed in the event _newGame_.
	@param process?<boolean> Whether map XMLs should be processed.
	@returns boolean Whether map XMLs will be processed.
]]
Client.processXml = function(self, process)
	if process == nil then
		self._processXml = not self._processXml
	else
		self._processXml = process
	end
	return self._processXml
end
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
--[[@
	@name disconnect
	@desc Forces the private function @see closeAll to be called. (Ends the connections)
	@returns boolean Whether the Connection objects can be destroyed or not.
]]
Client.disconnect = function(self)
	if self.main then
		self.main.open = false
		return true
	end
	return false
end
-- Miscellaneous




--[[@
	@name requestLanguage
	@desc Requests the list of available languages.
]]
Client.requestLanguage = function(self)
	self.mainConnection:send({ 176, 02 }, ByteArray:new())
end
----- Compatibility -----
Client.insertReceiveFunction = "insertPacketListener"
Client.insertTribulleFunction = "insertTribulleListener"
Client.closeAll = "disconnect"
-------------------------

