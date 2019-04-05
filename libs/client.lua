local connectionHandler = require("connection")
local byteArray = require("bArray")
local encode = require("cipher")
local http = require("coro-http")
local json = require("json")
local timer = require("timer")
local enum = require("enum")
local event = require("core").Emitter
local bitwise = require("bitwise")
local zlibDecompress = require("miniz").inflate
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
		_connectionTime = os.time(),
		_isConnected = false,
		_hbTimer = nil,
		_who_fingerprint = 0,
		_who_list = { },
		_process_xml = true
	}, self)
end

-- Recv
-- Tribulle functions
local trib = {
	[32] = function(self, connection, packet, C_CC, tribulleId) -- Friend connected
		local playerName = packet:readUTF()
		--[[@
			@desc Triggered when a friend connects to the game.
			@param playerName<string> The player name.
		]]
		self.event:emit("friendConnection", string.toNickname(playerName, true))
	end,
	[33] = function(self, connection, packet, C_CC, tribulleId) -- Friend disconnected
		local playerName = packet:readUTF()
		--[[@
			@desc Triggered when a friend disconnects from the game.
			@param playerName<string> The player name.
		]]
		self.event:emit("friendDisconnection", string.toNickname(playerName, true))
	end,
	[59] = function(self, connection, packet, C_CC, tribulleId) -- /who
		local fingerprint = packet:read32()

		packet:read8() -- ?
		
		local total = packet:read16()
		local data = { }
		for i = 1, total do
			data[i] = string.toNickname(packet:readUTF(), true)
		end

		local chatName = self._who_list[fingerprint]
		--[[@
			@desc Triggered when the /who command is loaded in a chat.
			@param chatName<string> The name of the chat.
			@param data<table> An array with the nicknames of the current users in the chat.
		]]
		self.event:emit("chatWho", chatName, data)
		self._who_list[fingerprint] = nil
	end,
	[64] = function(self, connection, packet, C_CC, tribulleId) -- #Chat Message
		local playerName, community, chatName, message = packet:readUTF(), packet:read32(), packet:readUTF(), packet:readUTF()
		--[[@
			@desc Triggered when a #chat receives a new message.
			@param chatName<string> The name of the chat.
			@param playerName<string> The player who sent the message.
			@param message<string> The message.
			@param playerCommunity<int> The community id of @playerName.
		]]
		self.event:emit("chatMessage", chatName, string.toNickname(playerName, true), string.fixEntity(message), community)
	end,
	[65] = function(self, connection, packet, C_CC, tribulleId) -- Tribe message
		local memberName, message = packet:readUTF(), packet:readUTF()
		--[[@
			@desc Triggered when the tribe chat receives a new message.
			@param memberName<string> The member who sent the message.
			@param message<string> The message.
		]]
		self.event:emit("tribeMessage", string.toNickname(memberName, true), string.fixEntity(message))
	end,
	[66] = function(self, connection, packet, C_CC, tribulleId) -- Whisper message
		local playerName, community, _, message = packet:readUTF(), packet:read32(), packet:readUTF(), packet:readUTF()
		--[[@
			@desc Triggered when the account receives a whisper.
			playerName<string> Who sent the whisper message.
			message<string> The message.
			playerCommunity<int> The community id of @playerName.
		]]
		self.event:emit("whisperMessage", string.toNickname(playerName, true), string.fixEntity(message), community)
	end,
	[88] = function(self, connection, packet, C_CC, tribulleId) -- Tribe member connected
		local memberName = packet:readUTF()
		--[[@
			@desc Triggered when a tribe member connects to the game.
			@param memberName<string> The member name.
		]]
		self.event:emit("tribeMemberConnection", string.toNickname(memberName, true))
	end,
	[90] = function(self, connection, packet, C_CC, tribulleId) -- Tribe member disconnected
		local memberName = packet:readUTF()
		--[[@
			@desc Triggered when a tribe member disconnects to the game.
			@param memberName<string> The member name.
		]]
		self.event:emit("tribeMemberDisconnection", string.toNickname(memberName, true))
	end,
	[91] = function(self, connection, packet, C_CC, tribulleId) -- New tribe member
		local memberName = packet:readUTF()
		--[[@
			@desc Triggered when a player joins the tribe.
			@param memberName<string> The member who joined the tribe.
		]]
		self.event:emit("newTribeMember", string.toNickname(memberName, true))
	end,
	[92] = function(self, connection, packet, C_CC, tribulleId) -- Tribe member leave
		local memberName = packet:readUTF()
		--[[@
			@desc Triggered when a member leaves the tribe.
			@param memberName<string> The member who left the tribe.
		]]
		self.event:emit("tribeMemberLeave", string.toNickname(memberName, true))
	end,
	[93] = function(self, connection, packet, C_CC, tribulleId) -- Tribe member kicked
		local memberName, kickerName = packet:readUTF(), packet:readUTF()
		--[[@
			@desc Triggered when a tribe member is kicked.
			@param memberName<string> The member name.
			@param kickerName<string> The name of who kicked the member.
		]]
		self.event:emit("tribeMemberKick", string.toNickname(memberName, true), string.toNickname(kickerName, true))
	end,
	[124] = function(self, connection, packet, C_CC, tribulleId) -- Tribe member kicked
		local memberName, setterName, role = packet:readUTF(), packet:readUTF(), packet:readUTF()
		--[[@
			@desc Triggered when a tribe member gets a role.
			@param memberName<string> The member name.
			@param setterName<string> The name of who set the role to the member.
			@param role<string> The role name.
		]]
		self.event:emit("tribeMemberGetRole", string.toNickname(memberName, true), string.toNickname(setterName, true), role)
	end
}
-- Recv functions
local exec = {
	[5] = {
		[2] = function(self, connection, packet, C_CC) -- New game
			if not self._isConnected then return end

			local map = { }
			map.code = packet:read32()
	
			packet:read16() -- ?
			packet:read8() -- ?
			packet:read16() -- ?

			local xml = packet:read8(packet:read16())
			if self._process_xml then
				xml = table.writeBytes(xml)
				if xml ~= '' then
					map.xml = zlibDecompress(xml, 1)
				end
			end
			map.author = packet:readUTF()
			map.perm = packet:read8()
			map.isMirrored = packet:readBool()
	
			--[[@
				@desc Triggered when a new map is loaded.
				@desc /!\ This event may increase the memory consumption significantly due to the XML processes. Set the variable `_process_xml` as false to avoid processing it.
				@param map<table> The new map data.
				@struct @map {
					code = 0, -- The map code.
					xml = "", -- The map XML. May be nil if the map is Vanilla.
					author = "", -- The map author
					perm = 0, -- The perm code of the map.
					isMirrored = false -- Whether the map is mirrored or not.
				}
			]]
			self.event:emit("newGame", map)
		end,
		[21] = function(self, connection, packet, C_CC) -- Room changed
			local isPrivate, roomName = packet:readBool(), packet:readUTF()

			if string.byte(roomName, 2) == 3 then
				--[[@
					@desc Triggered when the account joins a tribe house.
					@param tribeName<string> The name of the tribe.
				]]
				self.event:emit("joinTribeHouse", string.sub(roomName, 3))
			else
				--[[@
					@desc Triggered when the account changes the room.
					@param roomName<string> The name of the room.
					@param isPrivateRoom<boolean> Whether the room is only accessible by the account or not.
				]]
				self.event:emit("roomChanged", string.fixEntity(roomName), isPrivate)
			end
		end
	},
	[6] = {
		[6] = function(self, connection, packet, C_CC) -- Room message
			local playerId, playerName, playerCommu, message = packet:read32(), packet:readUTF(), packet:read8(), string.fixEntity(packet:readUTF())
			--[[@
				@desc Triggered when the room receives a new user message.
				@param playerName<string> The player who sent the message.
				@param message<string> The message.
				@param playerCommunity<int> The community id of @playerName.
				@param playerId<int> The temporary id of @playerName.
			]]
			self.event:emit("roomMessage", string.toNickname(playerName, true), string.fixEntity(message), playerCommu, playerId)
		end,
		[20] = function(self, connection, packet, C_CC) -- /time
			packet:read8() -- ?
			packet:readUTF() -- $TempsDeJeu
			packet:read8() -- Total parameters (useless?)

			local time = { }
			time.day = tonumber(packet:readUTF())
			time.hour = tonumber(packet:readUTF())
			time.minute = tonumber(packet:readUTF())
			time.second = tonumber(packet:readUTF())

			--[[@
				@desc Triggered when the command /time is requested.
				@param time<table> The account's time data.
				@struct @param {
					day = 0, -- Total days
					hour = 0, -- Total hours
					minute = 0, -- Total minutes
					second = 0 -- Total seconds
				}
			]]
			self.event:emit("time", time)
		end
	},
	[8] = {
		[16] = function(self, connection, packet, C_CC) -- Profile data
			local data = { }
			data.playerName = packet:readUTF()
			data.id = packet:read32()
			data.registrationDate = packet:read32()
			data.role = packet:read8() -- enum.role
			
			data.gender = packet:read8() -- enum.gender
			data.tribeName = packet:readUTF()
			data.soulmate = packet:readUTF()
			
			data.saves = { }
			data.saves.normal = packet:read32()
			data.shamanCheese = packet:read32()
			data.firsts = packet:read32()
			data.cheeses = packet:read32()
			data.saves.hard = packet:read32()
			data.bootcamps = packet:read32()
			data.saves.divine = packet:read32()
			
			data.titleId = packet:read16()
			data.totalTitles = packet:read16()
			data.titles = { }
			for i = 1, data.totalTitles do
				data.titles[packet:read16()] = packet:read8() -- id, stars
			end

			data.look = packet:readUTF()

			data.level = packet:read16()

			data.totalBadges = packet:read16() / 2
			data.badges = { }
			for i = 1, data.totalBadges do
				data.badges[packet:read16()] = packet:read16() -- id, quantity
			end

			data.totalModeStats = packet:read8()
			data.modeStats = { }
			local modeId
			for i = 1, data.totalModeStats do
				modeId = packet:read8()
				data.modeStats[modeId] = { }
				data.modeStats[modeId].progress = packet:read32()
				data.modeStats[modeId].progressLimit = packet:read32()
				data.modeStats[modeId].imageId = packet:read8()
			end

			data.orbId = packet:read8()
			data.totalOrbs = packet:read8()
			data.orbs = { }
			for i = 1, data.totalOrbs do
				data.orbs[packet:read8()] = true
			end

			packet:read8() -- ?

			data.adventurePoints = packet:read32()

			--[[@
				@desc Triggered when the profile of an user is loaded.
				@param data<table> The user profile data.
				@struct @data {
					playerName = "", -- The player name.
					id = 0, -- The player id.
					registrationDate = 0, -- The timestamp of when the account was created.
					role = 0, -- An enum from enum.role that specifies the account's role.
					gender = 0, -- An enum from enum.gender for the account's gender. 
					tribeName = "", -- The name of the tribe.
					soulmate = "", -- The name of the soulmate.
					saves = {
						normal = 0, -- Total saves in the normal mode.
						hardmode = 0, -- Total saves in the hard mode.
						divine = 0 -- Total saves in the divine mode.
					}, -- Total saves of the account.
					shamanCheese = 0, -- Total of cheeses gathered as shaman.
					firsts = 0, -- Total of firsts.
					cheeses = 0, -- Total of cheeses.
					bootcamps = 0, -- Total of bootcamps.
					titleId = 0, -- The id of the current title.
					totalTitles = 0, -- Total of unlocked titles.
					titles = {
						[id] = 0 -- The id of the title as index, the quantity of stars as value.
					}, -- The list of unlocked titles.
					look = "", -- The account's outfit code.
					level = 0, -- The account's level.
					totalBadges = 0, -- The total of unlocked badges.
					badges = {
						[id] = 0 -- The id of the badge as index, the quantity as value.
					}, -- The list of unlocked badges.
					totalModeStats = 0, -- The total of mode statuses.
					modeStats = {
						[id] = {
							progress = 0, -- The current score in the status.
							progressLimit = 0, -- The status score limit.
							imageId = 0 -- The image id of the status. 
						} -- The status id.
					}, -- The list of mode statuses.
					orbId = 0, -- The id of the current shaman orb.
					totalOrbs = 0, -- The total of unlocked shaman orbs.
					orbs = {
						[id] = true -- The id of the shaman orb as index.
					}, -- The list of unlocked shaman orbs.
					adventurePoints = 0 -- The total adventure points.
				}
			]]
			self.event:emit("profileLoaded", data)
		end
	},
	[26] = {
		[2] = function(self, connection, packet, C_CC)
			self._isConnected = true
		end,
		[3] = function(self, connection, packet, C_CC) -- Correct handshake identifiers
			local onlinePlayers = packet:read32()

			connection.packetID = packet:read8()
			local community = packet:readUTF() -- Necessary to get the country and authkeys later
			local country = packet:readUTF()

			self.receivedAuthkey = packet:read32() -- Receives an authentication key, parsed in the login function

			self._hbTimer = timer.setInterval(10 * 1000, self.sendHeartbeat, self)

			community = byteArray:new():write8(self.community):write8(0)
			self.main:send(enum.identifier.community, community)

			local osInfo = byteArray:new():writeUTF("en"):writeUTF("Linux")
			osInfo:writeUTF("LNX 29,0,0,140"):write8(0)
			self.main:send(enum.identifier.os, osInfo)
		end
	},
	[28] = {
		[5] = function(self, connection, packet, C_CC)
			packet:read16() -- ?
			--[[@
				@desc Triggered when a staff list is loaded (/mod, /mapcrew).
				@param list<string> The staff list content.
			]]
			self.event:emit("staffList", packet:readUTF())
		end,
		[6] = function(self, connection, packet, C_CC)
			--[[@
				@desc Triggered when a server heartbeat is received.
			]]
			self.event:emit("ping", os.time())
		end
	},
	[29] = {
		[6] = function(self, connection, packet, C_CC)
			local log = packet:readUTF()
			--[[@
				@desc Triggered when the #lua chat receives a log message.
				@param log<string> The log message.
			]]
			self.event:emit("lua", log)
		end
	},
	[44] = {
		[1] = function(self, connection, packet, C_CC) -- Switch bulle identifiers
			local bulleId = packet:read32()
			local bulleIp = packet:readUTF()

			self.bulle = connectionHandler:new("bulle", self.event)
			self.bulle:connect(bulleIp, enum.setting.port[self.main.port])

			self.bulle.event:once("_socketConnection", function()
				self.bulle:send(C_CC, byteArray:new():write32(bulleId))
			end)
		end,
		[22] = function(self, connection, packet, C_CC) -- PacketID offset identifiers
			connection.packetID = packet:read8() -- Sets the pkt of the connection
		end
	},
	[60] = {
		[3] = function(self, connection, packet, C_CC) -- Community Platform
			local tribulleId = packet:read16()
			if trib[tribulleId] then
				return trib[tribulleId](self, connection, packet, C_CC, tribulleId)
			end
			--[[@
				@desc Triggered when a tribulle packet is not handled by the tribulle packet parser.
				@param connection<connection> The connection object.
				@param tribulleId<int> The tribulle id.
				@param packet<bArray> The Byte Array object with the packets that were not handled.
			]]
			self.event:emit("missedTribulle", connection, tribulleId, packet)
		end
	}
}

-- Recv Manipulation
--[[@
	@desc Inserts a new function to the packet parser.
	@param C<int> The C packet.
	@param CC<int> The CC packet.
	@param f<function> The function to be triggered when the @C-@CC packets are received.	
]]
client.insertReceiveFunction = function(self, C, CC, f)
	if not exec[C] then
		exec[C] = { }
	end
	exec[C][CC] = f
end
--[[@
	@desc Inserts a new function to the tribulle (60, 3) packet parser.
	@param tribulleId<int> The tribulle id.
	@param f<function> The function to be triggered when this tribulle packet is received.
]]
client.insertTribulleFunction = function(self, tribulleId, f)
	trib[tribulleId] = f
end

client.parsePacket = function(self, connection, packet)
	local C, CC = packet:read8(), packet:read8()
	local C_CC = { C, CC }

	if exec[C] and exec[C][CC] then
		return exec[C][CC](self, connection, packet, C_CC)
	end
	--[[@
		@desc Triggered when an identifier is not handled by the system.
		@param identifiers<table> The C, CC identifiers sent in the request.
		@param packet<bArray> The Byte Array object that was sent.
	]]
	self.event:emit("missedPacket", C_CC, packet)
end

-- System

client.sendHeartbeat = function(self)
	self.main:send(enum.identifier.heartbeat, byteArray:new())
	if self.bulle and self.bulle.open then
		self.bulle:send(enum.identifier.heartbeat, byteArray:new())
	end

	--[[@
		@desc Triggered when a heartbeat is sent to the connection, every 10 seconds.
		@param time<int> The current time.
	]]
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
		--[[@
			@desc Triggered when a connection dies or fails.
			@param connection<connection> The connection object.
		]]
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
	local _r = result
	result = json.decode(result)
	if not result then
		return error("[API Endpoint] @TFMID or @TOKEN value is invalid.\n\t" .. tostring(_r))
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
		local packet = byteArray:new():write16(self.gameVersion):writeUTF(self.gameConnectionKey)
		packet:writeUTF("Desktop"):writeUTF('-'):write32(8125):writeUTF('')
		packet:writeUTF("86bd7a7ce36bec7aad43d51cb47e30594716d972320ef4322b7d88a85904f0ed")
		packet:writeUTF("A=t&SA=t&SV=t&EV=t&MP3=t&AE=t&VE=t&ACC=t&PR=t&SP=f&SB=f&DEB=f&V=LNX 29,0,0,140&M=Adobe Linux&R=1920x1080&COL=color&AR=1.0&OS=Linux&ARCH=x86&L=en&IME=t&PR32=t&PR64=t&LS=en-US&PT=Desktop&AVD=f&LFD=f&WD=f&TLS=t&ML=5.1&DP=72")
		packet:write32(0):write32(25175):writeUTF('')

		self.main:send(enum.identifier.initialize, packet)

		self:loop()
	end)

	self.main.event:on("_receive", function(connection, packet)
		local C_CC = { packet:read8(), packet:read8() }

		if connection.name == "main" then
			if enum.identifier.correctVersion[1] == C_CC[1] and enum.identifier.correctVersion[2] == C_CC[2] then
				return timer.setTimeout(5000, function(self)
					--[[@
						@desc Triggered when the connection is live.
					]]
					self.event:emit("ready")
				end, self)
			elseif enum.identifier.bulle[1] == C_CC[1] and enum.identifier.bulle[2] == C_CC[2] then
				return timer.setTimeout(5000, function(self)
					--[[@
						@desc Triggered when the account is logged and ready to perform actions.
					]]
					self.event:emit("connection")
				end, self)
			end
		end
		--[[@
			@desc Triggered when the client receives packets from the server.
			@param connection<connection> The connection object that received the packets.
			@param packet<bArray> The Byte Array object that was received.
			@param identifiers<table> The C, CC identifiers that were received.
		]]
		self.event:emit("receive", connection, C_CC, packet)
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
--[[@
	@desc Emits an event.
	@desc See the available events in @see Events. You can also create your own events / emitters.
	@param eventName<string> The name of the event.
	@param ...?<*> The parameters to be passed during the emitter call.
]]
client.emit = function(self, eventName, ...)
	return self.event:emit(eventName, ...)
end
--[[@
	@desc Gets the total time of the connection.
	@returns int The total time since the connection.
]]
client.connectionTime = function(self)
	return os.time() - self._connectionTime
end

-- Methods
-- Initialization
--[[@
	@desc Sets the community where the bot will be cpmmected to.
	@desc /!\ This method must be called before the @see start.
	@param community<enum.community> An enum from @see community. (index or value) @default EN
]]
client.setCommunity = function(self, community)
	community = community and (tonumber(community) or string.lower(community))
	if community then
		local commu = enum._checkEnum(enum.community, community)
		if not commu then
			return error("[setCommunity] @community must be a valid 'community' enumeration.", 0)
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
client.connect = function(self, userName, userPassword, startRoom, timeout)
	local packet = byteArray:new():writeUTF(userName):writeUTF(encode.getPasswordHash(userPassword))
	packet:writeUTF("app:/TransformiceAIR.swf/[[DYNAMIC]]/2/[[DYNAMIC]]/4"):writeUTF((startRoom and tostring(startRoom)) or "*#bolodefchoco")
	packet:write32(bitwise.bxor(self.receivedAuthkey, self.gameAuthkey))

	self.playerName = userName
	self.main:send(enum.identifier.login, encode.blockCipher(packet):write8(0))

	timer.setTimeout((timeout or (20 * 1000)), function(self)
		if not self._isConnected then
			return error("[Login] Impossible to log in. Try again later.", 0)
		end
	end, self)
end
-- Room
--[[@
	@desc Enters in a room.
	@param roomName<string> The name of the room.
	@param isSalonAuto?<boolean> Whether the change room must be /salonauto or not. @default false
]]
client.enterRoom = function(self, roomName, isSalonAuto)
	self.main:send(enum.identifier.room, byteArray:new():write8(self.community):writeUTF(roomName):writeBool(isSalonAuto))
end
--[[@
	@desc Sends a message in the room chat.
	@desc /!\ Note that the limit of characters for the message is 255, but if the account is new the limit is set to 80. You must limit it yourself or the bot may get disconnected.
	@param message<string> The message.
]]
client.sendRoomMessage = function(self, message)
	self.bulle:send(enum.identifier.roomMessage, encode.xorCipher(byteArray:new():writeUTF(message), self.bulle.packetID))
end
-- Whisper
--[[@
	@desc Sends a whisper to an user.
	@desc /!\ Note that the limit of characters for the message is 255, but if the account is new the limit is set to 80. You must limit it yourself or the bot may get disconnected.
	@param message<string> The message.
	@param targetUser<string> The user to receive the whisper.
]]
client.sendWhisper = function(self, targetUser, message)
	self.main:send(enum.identifier.message, encode.xorCipher(byteArray:new():write16(52):write32(3):writeUTF(targetUser):writeUTF(message), self.main.packetID))
end
--[[@
	@desc Sets the account's whisper state.
	@param message?<string> The /silence message. @default ''
	@param state?<enum.whisperState> An enum from @see whisperState. (index or value) @default enabled
]]
client.changeWhisperState = function(self, message, state)
	state = state and (tonumber(state) or string.lower(state))
	if state then
		local s = enum._checkEnum(enum.whisperState, state)
		if not s then
			return error("[changeWhisperState] @state must be a valid 'whisperState' enumeration.", 0)
		end
		if s == 1 then
			state = enum.whisperState[state]
		end
	else
		state = enum.whisperState.enabled
	end

	self.main:send(enum.identifier.message, encode.xorCipher(byteArray:new():write16(60):write32(1):write8(state):writeUTF(message or ''), self.main.packetID))
end
-- Chat
--[[@
	@desc Joins a #chat.
	@param chatName<string> The name of the chat.
]]
client.joinChat = function(self, chatName)
	self.main:send(enum.identifier.message, encode.xorCipher(byteArray:new():write16(54):write32(1):writeUTF(chatName):write8(1), self.main.packetID))
end
--[[@
	@desc Sends a message to a #chat.
	@desc /!\ Note that the limit of characters for the message is 255, but if the account is new the limit is set to 80. You must limit it yourself or the bot may get disconnected.
	@param chatName<string> The name of the chat.
	@param message<string> The message.
]]
client.sendChatMessage = function(self, chatName, message)
	self.main:send(enum.identifier.message, encode.xorCipher(byteArray:new():write16(48):write32(1):writeUTF(chatName):writeUTF(message), self.main.packetID))
end
--[[@
	@desc Leaves a #chat.
	@param chatName<string> The name of the chat.
]]
client.closeChat = function(self, chatName)
	self.main:send(enum.identifier.message, encode.xorCipher(byteArray:new():write16(56):write32(1):writeUTF(chatName), self.main.packetID))
end
--[[@
	@desc Gets who is in a specific chat. (/who)
	@param chatName<string> The name of the chat.
]]
client.chatWho = function(self, chatName)
	self._who_fingerprint = (self._who_fingerprint + 1) % 300
	self._who_list[self._who_fingerprint] = chatName

	self.main:send(enum.identifier.message, encode.xorCipher(byteArray:new():write16(58):write32(self._who_fingerprint):writeUTF(chatName), self.main.packetID))
end
-- Tribe
--[[@
	@desc Joins the tribe house, if the account is in a tribe.
]]
client.joinTribeHouse = function(self)
	self.main:send(enum.identifier.joinTribeHouse, byteArray:new())
end
--[[@
	@desc Sends a message to the tribe chat.
	@desc /!\ Note that the limit of characters for the message is 255, but if the account is new the limit is set to 80. You must limit it yourself or the bot may get disconnected.
	@param message<string> The message.
]]
client.sendTribeMessage = function(self, message)
    self.main:send(enum.identifier.message, encode.xorCipher(byteArray:new():write16(50):write32(3):writeUTF(message), self.main.packetID))
end
--[[@
	@desc Sends a recruitment invite to the player.
	@desc /!\ Note that this method will not cover errors if the account is not in a tribe or do not have permissions.
	@param playerName<string> The name of player to be recruited.
]]
client.recruitPlayer = function(self, playerName)
	self.main:send(enum.identifier.message, encode.xorCipher(byteArray:new():write16(78):write32(1):writeUTF(playerName), self.main.packetID))
end
--[[@
	@desc Kicks a member of the tribe.
	@desc /!\ Note that this method will not cover errors if the account is not in a tribe or do not have permissions.
	@param memberName<string> The name of the member to be kicked.
]]
client.kickTribeMember = function(self, memberName)
	self.main:send(enum.identifier.message, encode.xorCipher(byteArray:new():write16(104):write32(1):writeUTF(memberName), self.main.packetID))
end
--[[@
	@desc Sets the role of a member in the tribe.
	@desc /!\ Note that this method will not cover errors if the account is not in a tribe or do not have permissions.
	@param memberName<string> The name of the member to get the role.
	@param roleId<int> The role id. (starts in 0, for the initial role. Increases until the Chief role)
]]
client.setTribeMemberRole = function(self, memberName, roleId)
	self.main:send(enum.identifier.message, encode.xorCipher(byteArray:new():write16(112):write32(1):writeUTF(memberName):write8(roleId), self.main.packetID))
end
--[[@
	@desc Loads a lua script in the room.
	@param script<string> The lua script.
]]
client.loadLua = function(self, script)
	self.bulle:send(enum.identifier.loadLua, byteArray:new():writeBigUTF(script))
end
-- Miscellaneous
--[[@
	@desc Sends a command (/).
	@desd /!\ Note that some unlisted commands cannot be triggered by this function.
	@param command<string> The command. (without /)
]]
client.sendCommand = function(self, command, crypted)
	self.main:send(enum.identifier.command, encode.xorCipher(byteArray:new():writeUTF(command), self.main.packetID))
end
--[[@
	@desc Plays an emote.
	@param emote<enum.emote> An enum from @see emote. (index or value) @default dance
	@param flag<string> The country code of the flag when @emote is flag.
]]
client.playEmote = function(self, emote, flag)
	emote = emote and (tonumber(emote) or string.lower(emote))
	if emote then
		local s = enum._checkEnum(enum.emote, emote)
		if not s then
			return error("[playEmote] @emote must be a valid 'emote' enumeration.", 0)
		end
		if s == 1 then
			emote = enum.emote[emote]
		end
	else
		emote = enum.emote.dance
	end

	local packet = byteArray:new():write8(emote):write32(0)
	if emote == enum.emote.flag then
		packet = packet:writeUTF(flag)
	end

	self.bulle:send(enum.identifier.emote, packet)
end
--[[@
	@desc Plays an emoticon.
	@param emoticon<enum.emoticon> An enum from @see emoticon. (index or value) @default smiley
]]
client.playEmoticon = function(self, emoticon)
	emoticon = emoticon and (tonumber(emoticon) or string.lower(emoticon))
	if emoticon then
		local s = enum._checkEnum(enum.emoticon, emoticon)
		if not s then
			return error("[playEmoticon] @emoticon must be a valid 'emoticon' enumeration.", 0)
		end
		if s == 1 then
			emoticon = enum.emoticon[emoticon]
		end
	else
		emoticon = enum.emoticon.smiley
	end

	self.bulle:send(enum.identifier.emoticon, byteArray:new():write8(emoticon):write32(0))
end

return client