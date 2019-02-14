local connectionHandler = require("connection")
local byteArray = require("byteArray")
local encode = require("cipher")
local http = require("coro-http")
local json = require("json")
local timer = require("timer")
local enum = require("enum")
local event = require("core").Emitter
local bitwise = require("bitwise")
if not string.getBytes then
	require("extensions")
end

local client = { }
client.__index = client

client.new = function(self)
	local eventEmitter = event:new()

	return setmetatable({
		playerName = nil,
		community = enum.community.en,
		main = connectionHandler:new("main", eventEmitter),
		mainLoop = nil,
		bulle = nil,
		bulleLoop = nil,
		event = eventEmitter,
		gamePacketKeys = { },
		receivedAuthkey = 0,
		gameVersion = 0,
		gameConnectionKey = "",
		gameAuthkey = 0,
		gameIdentificationKeys = { },
		gameMsgKeys = { },
		_isConnected = false,
		_hbTimer = nil
	}, self)
end

-- Tribulle
do
	-- Tribulle functions
	local exec = {
		[5] = {
			[21] = function(self, connection, packet, C_CC) -- Room changed
				local isPrivate, roomName = packet:readBool(), packet:readUTF()

				if string.byte(roomName, 2) == 3 then
					self.event:emit("joinTribeHouse", string.sub(roomName, 3))
				else
					self.event:emit("roomChanged", roomName, isPrivate)
				end
			end
		},
		[6] = {
			[6] = function(self, connection, packet, C_CC) -- Room message
				local playerId, playerName, playerCommu, message = packet:readLong(), packet:readUTF(), packet:readByte(), string.decodeEntities(packet:readUTF())
				self.event:emit("roomMessage", string.lower(playerName), message, playerCommu, playerId)
			end
		},
		[26] = {
			[2] = function(self, connection, packet, C_CC)
				self._isConnected = true
			end,
			[3] = function(self, connection, packet, C_CC) -- Correct handshake identifiers
				local onlinePlayers = packet:readLong()

				connection.packetID = packet:readByte()
				local community = packet:readUTF() -- Necessary to get the country and authkeys later
				local country = packet:readUTF()

				self.receivedAuthkey = packet:readLong() -- Receives an authentication key, parsed in the login function

				self._hbTimer = timer.setInterval(10 * 1000, self.sendHeartbeat, self)

				community = byteArray:new():writeByte(self.community):writeByte(0)
				self.main:send(enum.identifier.community, community)

				local osInfo = byteArray:new():writeUTF("en"):writeUTF("Linux")
				osInfo:writeUTF("LNX 29,0,0,140"):writeByte(0)
				self.main:send(enum.identifier.os, osInfo)
			end
		},
		[44] = {
			[1] = function(self, connection, packet, C_CC) -- Switch bulle identifiers
				local bulleId = packet:readLong()
				local bulleIp = packet:readUTF()

				self.bulle = connectionHandler:new("bulle", self.event)
				self.bulle:connect(bulleIp, enum.setting.port[self.main.port])

				self.bulle.event:once("_socketConnection", function()
					self.bulle:send(C_CC, byteArray:new():writeLong(bulleId))
				end)
			end,
			[22] = function(self, connection, packet, C_CC) -- PacketID offset identifiers
				connection.packetID = packet:readByte() -- Sets the pkt of the connection
			end
		},
		[60] = {
			[3] = function(self, connection, packet, C_CC) -- Community Platform
				local tribulle = packet:readShort()
				if tribulle == 64 then -- #Chat Message
					local playerName, community, channelName, message = packet:readUTF(), packet:readLong(), packet:readUTF(), packet:readUTF()
					return self.event:emit("chatMessage", channelName, string.lower(playerName), message, community)
				elseif tribulle == 66 then -- Whisper message
					local playerName, community, _, message = packet:readUTF(), packet:readLong(), packet:readUTF(), packet:readUTF()
					return self.event:emit("whisperMessage", string.lower(playerName), message, community)
				end
			end
		}
	}

	client.parsePacket = function(self, connection, packet)
		local C, CC = packet:readByte(), packet:readByte()
		local C_CC = { C, CC }

		if exec[C] and exec[C][CC] then
			return exec[C][CC](self, connection, packet, C_CC)
		end
		self.event:emit("missedPacket", C_CC, packet)
	end
end

-- Technical

client.sendHeartbeat = function(self)
	self.main:send(enum.identifier.heartbeat, byteArray:new())
	if self.bulle and self.bulle.open then
		self.bulle:send(enum.identifier.heartbeat, byteArray:new())
	end

	self.event:emit("heartbeat", os.time())
end

client.mainReceive = function(self)
	self.mainLoop = timer.setInterval(10, function(self)
		if self.main.open then
			local packet = self.main:receive()
			if not packet then return end
			
			self.event:emit("_receive", self.main, byteArray:new(packet))
			self:parsePacket(self.main, byteArray:new(packet))
		end
	end, self)
end

client.bulleReceive = function(self)
	self.bulleLoop = timer.setInterval(10, function(self)
		if self.bulle and self.bulle.open then
			local packet = self.bulle:receive()
			if not packet then return end

			self.event:emit("_receive", self.bulle, byteArray:new(packet))
			self:parsePacket(self.bulle, byteArray:new(packet))
		end
	end, self)
end

client.closeAll = function(self)
	if self.bulle and self.bulle.open then
		self.bulle.open = false

		timer.clearInterval(self.bulleLoop)
		self.bulle.socket:destroy()
		self.event:emit("disconnection", self.bulle)

		self.main.open = false
		timer.clearInterval(self.mainLoop)
		self.main.socket:destroy()
		self.event:emit("disconnection", self.main)
	end
end

client.loop = function(self)
	self:mainReceive()
	self:bulleReceive()
	local loop
	loop = timer.setInterval(10, function(self, loop)
		if not self.main.open then
			timer.clearInterval(self._hbTimer)
			timer.clearInterval(loop)
			self.closeAll()
		end
	end, self, loop)
end

client.getKeys = function(self, tfmId, token)
	local _, result = http.request("GET", "https://api.tocu.tk/get_transformice_keys.php?tfmid=" .. tfmId .. "&token=" .. token, {
		{ "User-Agent", "Mozilla/5.0" }
	})
	result = json.decode(result)
	if not result then
		return error("[API Endpoint] @TFMID or @TOKEN value is invalid.")
	end

	if result.success then
		if not result.internal_error then
			self.gameVersion = result.version
			self.gameConnectionKey = result.connection_key
			self.gameAuthkey = result.auth_key
			self.gamePacketKeys = result.packet_keys
			self.gameIdentificationKeys = result.identification_keys
			self.gameMsgKeys = result.msg_keys

			encode.setPacketKeys(self.gamePacketKeys, self.gameIdentificationKeys, self.gameMsgKeys)
		else
			return error("[Endpoint] An internal error occurred in the API endpoint.\n\t'" .. result.internal_error_step .. "'" .. ((result.internal_error_step == 2) and ": The game may be in maintenance." or ""), 0)
		end
	else
		return error("[Endpoint] Impossible to get the keys.\n\tError: " .. tostring(result.error), 0)
	end
end

--[[@
	@desc Initializes the API connection with the authentication keys. It must be the first method of the API to be called.
	@param tfmId<string,int> The Transformice ID of your account. If you don't know how to obtain it, go to the room **#bolodefchoco0id** and check your chat.
	@param token<string> The API Endpoint token to get access to the authentication keys. Learn more in
]]
client.start = coroutine.wrap(function(self, tfmId, token)
	self:getKeys(tfmId, token)

	self.main:connect("164.132.202.12")

	self.main.event:once("_socketConnection", function()
		local packet = byteArray:new():writeShort(self.gameVersion):writeUTF(self.gameConnectionKey)
		packet:writeUTF("Desktop"):writeUTF('-'):writeLong(8125):writeUTF('')
		packet:writeUTF("86bd7a7ce36bec7aad43d51cb47e30594716d972320ef4322b7d88a85904f0ed")
		packet:writeUTF("A=t&SA=t&SV=t&EV=t&MP3=t&AE=t&VE=t&ACC=t&PR=t&SP=f&SB=f&DEB=f&V=LNX 29,0,0,140&M=Adobe Linux&R=1920x1080&COL=color&AR=1.0&OS=Linux&ARCH=x86&L=en&IME=t&PR32=t&PR64=t&LS=en-US&PT=Desktop&AVD=f&LFD=f&WD=f&TLS=t&ML=5.1&DP=72")
		packet:writeLong(0):writeLong(25175):writeUTF('')

		self.main:send(enum.identifier.initialize, packet)

		self:loop()
	end)

	self.main.event:on("_receive", function(connection, packet)
		local C_CC = { packet:readByte(), packet:readByte() }

		if connection.name == "main" then
			if enum.identifier.correctVersion[1] == C_CC[1] and enum.identifier.correctVersion[2] == C_CC[2] then
				return timer.setTimeout(5000, function(self)
					self.event:emit("ready")
				end, self)
			elseif enum.identifier.bulle[1] == C_CC[1] and enum.identifier.bulle[2] == C_CC[2] then
				return timer.setTimeout(5000, function(self)
					self.event:emit("connection")
				end, self)
			end
		end
		self.event:emit("receive", connection, packet, C_CC)
	end)
end)
--[[@
	@desc Sets an event emitter that is triggered everytime the specific behavior happens.
	@desc See the available events in @see Events.
	@param eventName<string> The name of the event.
	@param callback<function> The function that must be called when the event is triggered.
]]
client.on = function(self, eventName, callback)
	return self.event:on(eventName, callback)
end
--[[@
	@desc Sets an event emitter that is triggered only once when a specific behavior happens.
	@desc See the available events in @see Events.
	@param eventName<string> The name of the event.
	@param callback<function> The function that must be called only once when the event is triggered.
]]
client.once = function(self, eventName, callback)
	return self.event:once(eventName, callback)
end

-- Methods
--[[@
	@desc Sets the community where the bot will be cpmmected to.
	@desc /!\ This method must be called before the @see start.
	@param community<string,int> An enum from @see community (index or value) @default EN
]]
client.setCommunity = function(self, community)
	community = community and (tonumber(community) or string.lower(community))
	if community then
		local commu = enum._checkEnum(enum.community, community)
		if not commu then
			return error("[Client] @community must be a valid community enumeration.", 0)
		end
		if commu == 1 then
			community = enum.community[community]
		end
	else
		community =  enum.community.en
	end
	self.community = community
end
--[[@
	@desc Connects to an account in-game.
	@desc It will try to connect using all the available ports before throwing a timing out error.
	@param userName<string> The name of the account. It must contain the discriminator tag (#).
	@param userPassword<string> The password of the account.
	@param startRoom?<string> The name of the initial room. @default *#bolodefchoco
]]
client.connect = function(self, userName, userPassword, startRoom)
	local packet = byteArray:new():writeUTF(userName):writeUTF(encode.getPasswordHash(userPassword))
	packet:writeUTF("app:/TransformiceAIR.swf/[[DYNAMIC]]/2/[[DYNAMIC]]/4"):writeUTF(tostring(startRoom) or "*#bolodefchoco")
	packet:writeLong(bitwise.bxor(self.receivedAuthkey, self.gameAuthkey))

	self.playerName = userName
	self.main:send(enum.identifier.login, encode.blockCipher(packet):writeByte(0))

	timer.setTimeout(10000, function(self)
		if not self._isConnected then
			return error("[Login] Impossible to log in. Try again later.", 0)
		end
	end, self)
end
--[[@
	@desc Sends a message in the room chat.
	@desc /!\ Note that the limit of characters for the message is 255, but if the account is new the limit is set to 80. You must limit it yourself or the bot may get disconnected.
	@param message<string> The message.
]]
client.sendRoomMessage = function(self, message)
	self.bulle:send(enum.identifier.roomMessage, encode.xorCipher(byteArray:new():writeUTF(message), self.bulle.packetID))
end
--[[@
	@desc Sends a whisper to an user.
	@desc /!\ Note that the limit of characters for the message is 255, but if the account is new the limit is set to 80. You must limit it yourself or the bot may get disconnected.
	@param message<string> The message.
	@param targetUser<string> The user to receive the whisper.
	@param message<string> The message.
]]
client.sendWhisper = function(self, targetUser, message)
	self.main:send(enum.identifier.message, encode.xorCipher(byteArray:new():writeShort(52):writeLong(3):writeUTF(targetUser):writeUTF(message), self.main.packetID))
end
--[[@
	@desc Joins a #chat.
	@param chatName<string> The name of the chat.
]]
client.joinChat = function(self, chatName)
	self.main:send(enum.identifier.message, encode.xorCipher(byteArray:new():writeShort(54):writeLong(1):writeUTF(chatName):writeByte(1), self.main.packetID))
end
--[[@
	@desc Leaves a #chat.
	@param chatName<string> The name of the chat.
]]
client.closeChat = function(self, chatName)
	self.main:send(enum.identifier.message, encode.xorCipher(byteArray:new():writeShort(56):writeLong(1):writeUTF(chatName), self.main.packetID))
end
--[[@
	@desc Sends a message to a #chat.
	@desc /!\ Note that the limit of characters for the message is 255, but if the account is new the limit is set to 80. You must limit it yourself or the bot may get disconnected.
	@param chatName<string> The name of the chat.
	@param message<string> The message.
]]
client.sendChatMessage = function(self, chatName, message)
	self.main:send(enum.identifier.message, encode.xorCipher(byteArray:new():writeShort(48):writeLong(1):writeUTF(chatName):writeUTF(message), self.main.packetID))
end
--[[@
	@desc Joins the tribe house, if the account is in a tribe.
]]
client.joinTribeHouse = function(self)
	self.main:send(enum.identifier.joinTribeHouse, byteArray:new())
end
--[[@
	@desc Enters in a room.
	@param roomName<string> The name of the room.
	@param isSalonAuto?<boolean> Whether the change room must be /salonauto or not. @default false
]]
client.enterRoom = function(self, roomName, isSalonAuto)
	self.main:send(enum.identifier.room, byteArray:new():writeByte(self.community):writeUTF(roomName):writeBool(isSalonAuto))
end
--[[@
	@desc Sends a command (/).
	@param command<string> The command. (without /)
]]
client.sendCommand = function(self, command)
	self.main:send(enum.identifier.command, encode.xorCipher(byteArray:new():writeUTF(command), self.main.packetID))
end

return client