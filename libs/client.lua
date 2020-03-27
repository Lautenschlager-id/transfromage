local timer = require("timer")
local event = require("core").Emitter
local http_request = require("coro-http").request
local json_decode = require("json").decode
local zlibDecompress = require("miniz").inflate

local byteArray = require("bArray")
local connection = require("connection")
local encode = require("encode")
local enum = require("enum")

-- Optimization --
local bit_bxor = bit.bxor
local coroutine_makef = coroutine.makef
local encode_getPasswordHash = encode.getPasswordHash
local enum_validate = enum._validate
local math_normalizePoint = math.normalizePoint
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
local timer_setInterval = timer.setInterval
local timer_setTimeout = timer.setTimeout
------------------

local parsePacket, receive, sendHeartbeat, getKeys, closeAll
local tribulleListener, oldPacketListener, packetListener
local handlePlayerField, handleFriendData

local client = table_setNewClass()

local meta = {
	playerList = {
		__len = function(this)
			return this.count or -1
		end,
		__pairs = function(this)
			local indexes = { }
			for i = 1, #this do
				indexes[i] = this[i].playerName
			end

			local i = 0
			return function()
				i = i + 1
				if this[indexes[i]] then
					return this[indexes[i]].playerName, this[indexes[i]]
				end
			end
		end
	}
}

--[[@
	@name new
	@desc Creates a new instance of Client. Alias: `client()`.
	@desc The function @see start is automatically called if you pass its arguments.
	@param tfmId?<string,int> The Transformice ID of your account. If you don't know how to obtain it, go to the room **#bolodefchoco0id** and check your chat.
	@param token?<string> The API Endpoint token to get access to the authentication keys.
	@returns client The new Client object.
	@struct {
		playerName = "", -- The nickname of the account that is attached to this instance, if there's any.
		community = 0, -- The community enum where the object is set to perform the login. Default value is EN.
		main = { }, -- The main connection object, handles the game server.
		bulle = { }, -- The bulle connection object, handles the room server.
		event = { }, -- The event emitter object, used to trigger events.
		cafe = { }, -- The cached Café structure. (topics and messages)
		playerList = { }, -- The room players data.
		-- The fields below must not be edited, since they are used internally in the api.
		_mainLoop = { }, -- (userdata) A timer that retrieves the packets received from the game server.
		_bulleLoop = { }, -- (userdata) A timer that retrieves the packets received from the room server.
		_receivedAuthkey = 0, -- Authorization key, used to connect the account.
		_gameConnectionKey = "", -- The game connection key, used to connect the account.
		_gameIdentificationKeys = { }, -- The game identification keys, used to connect the account.
		_gameMsgKeys = { }, -- The game message keys, used to connect the account.
		_connectionTime = 0, -- The timestamp of when the player logged in. It will be 0 if the account is not connected.
		_isConnected = false, -- Whether the player is connected or not.
		_hbTimer = { }, -- (userdata) A timer that sends heartbeats to the server.
		_who_fingerprint = 0, -- A fingerprint to identify the chat where the command /who was used.
		_who_list = { }, -- A list of chat names associated to their own fingerprints.
		_process_xml = false, -- Whether the event "newGame" should decode the XML packet or not. (Set as false to save process)
		_cafeCachedMessages = { }, -- A set of message IDs to cache the read messages at the Café.
		_handle_players = false -- Whether the player-related events should be handled or not. (Set as false to save process)
	}
]]
client.new = function(self, tfmId, token, hasSpecialRole, useEndpointOnSpecialRole)
	local eventEmitter = event:new()
	local encode = encode:new(hasSpecialRole)

	local obj = setmetatable({
		playerName = nil,
		community = enum.community.en,
		main = connection:new("main", eventEmitter),
		bulle = nil,
		event = eventEmitter,
		cafe = { },
		playerList = setmetatable({ }, meta.playerList),
		-- Private
		_mainLoop = nil,
		_bulleLoop = nil,
		_receivedAuthkey = 0,
		_gameConnectionKey = "",
		_gameAuthkey = 0,
		_gameIdentificationKeys = { },
		_gameMsgKeys = { },
		_connectionTime = 0,
		_isConnected = false,
		_hbTimer = nil,
		_who_fingerprint = 0,
		_who_list = { },
		_process_xml = false,
		_cafeCachedMessages = { },
		_handle_players = false,
		_encode = encode,
		_hasSpecialRole = hasSpecialRole,
		_useEndpointOnSpecialRole = useEndpointOnSpecialRole
	}, self)

	if tfmId and token then
		obj:start(tfmId, token)
	end

	return obj
end

-- Receive
-- Tribulle functions
tribulleListener = {
	[3] = function(self, packet, connection, tribulleId) -- Connection info
		local gender = packet:read8()
		local playerId = packet:read32()

		-- Gets the friendList data
		local friendList, soulmate = tribulleListener[34](self, packet, connection, tribulleId,
			true)
		-- Gets the blackList data
		local blackList = tribulleListener[47](self, packet, connection, tribulleId, true)

		local tribeName = packet:readUTF()
		local tribeId = packet:read32()
		local tribeMessage = packet:readUTF()
		local tribeHouseMap = packet:read32()
		local tribeRankName = packet:readUTF()
		local tribeRankPermissions = packet:read32()

		--[[@
			@name connectionInfo
			@desc Triggered when the client logs in and its data gets loaded.
			@param playerData<table> The data of the player that has connected.
			@param friendList<table> The data of the players in the account's friend list.
			@param soulmate<table> The separated data of the account's soulmate.
			@param blackList<table> An array of strings of the names that are in the black list.
			@param tribeData<table> The data of the player's tribe.
			@struct @playerData {
				id = 0, -- The player's name.
				gender = 0 -- The player's gender. Enum in enum.gender.
			}
			@struct @friendlist {
				[i] = {
					id = 0, -- The player id.
					playerName = "", -- The player's name.
					gender = 0, -- The player's gender. Enum in enum.gender.
					isFriend = true, -- Whether the player has the account as a friend (added back) or not.
					isConnected = true, -- Whether the player is online or offline.
					gameId = 0, -- The id of the game where the player is connected. Enum in enum.game.
					roomName = "", -- The name of the room the player is in.
					lastConnection = 0 -- Timestamp of when the player was last online.
				}
			}
			@struct @soulmate {
				id = 0, -- The player id.
				playerName = "", -- The soulmate's name.
				gender = 0, -- The soulmate's gender. Enum in enum.gender.
				isFriend = true, -- Whether the soulmate has the account as a friend (added back) or not.
				isConnected = true, -- Whether the soulmate is online or offline.
				gameId = 0, -- The id of the game where the soulmate is connected. Enum in enum.game.
				roomName = "", -- The name of the room the soulmate is in.
				lastConnection = 0 -- Timestamp of when the soulmate was last online.
			}
			@struct @tribeInfo {
				tribeName = "", -- The name of the tribe.
				tribeId = 0, -- The id of the tribe.
				tribeMessage = "", -- The greetings message of the tribe.
				tribeHouseMap = 0, -- The map code of the tribe house.
				tribeRankName = "", -- The name of the rank that the account has in the tribe.
				tribeRankPermissions = 0 -- The permissions of the rank that the account has in the tribe.
			}
		]]
		self.event:emit("connectionInfo", {
			id = playerId,
			gender = gender
		}, friendList, soulmate, blackList, {
			tribeName = tribeName,
			tribeId = tribeId,
			tribeMessage = tribeMessage,
			tribeHouseMap = tribeHouseMap,
			tribeRankName = tribeRankName,
			tribeRankPermissions = tribeRankPermissions
		})
	end,
	[32] = function(self, packet, connection, tribulleId) -- Friend connected
		local playerName = packet:readUTF()
		--[[@
			@name friendConnection
			@desc Triggered when a friend connects to the game.
			@param playerName<string> The player name.
		]]
		self.event:emit("friendConnection", string_toNickname(playerName, true))
	end,
	[33] = function(self, packet, connection, tribulleId) -- Friend disconnected
		local playerName = packet:readUTF()
		--[[@
			@name friendDisconnection
			@desc Triggered when a friend disconnects from the game.
			@param playerName<string> The player name.
		]]
		self.event:emit("friendDisconnection", string_toNickname(playerName, true))
	end,
	[34] = function(self, packet, connection, tribulleId, _return) -- Loaded friendlist
		local soulmate = handleFriendData(packet)

		local friendList = { }
		for i = 1, packet:read16() do
			friendList[i] = handleFriendData(packet)
		end

		if _return then
			return friendList, soulmate
		end

		--[[@
			@name friendList
			@desc Triggered when the friend list is loaded.
			@param friendList<table> The data of the players in the account's friend list.
			@param soulmate<table> The separated data of the account's soulmate.
			@struct @friendlist {
				[i] = {
					id = 0, -- The player id.
					playerName = "", -- The player's name.
					gender = 0, -- The player's gender. Enum in enum.gender.
					isFriend = true, -- Whether the player has the account as a friend (added back) or not.
					isConnected = true, -- Whether the player is online or offline.
					gameId = 0, -- The id of the game where the player is connected. Enum in enum.game.
					roomName = "", -- The name of the room the player is in.
					lastConnection = 0 -- Timestamp of when the player was last online.
				}
			}
			@struct @soulmate {
				id = 0, -- The player id.
				playerName = "", -- The soulmate's name.
				gender = 0, -- The soulmate's gender. Enum in enum.gender.
				isFriend = true, -- Whether the soulmate has the account as a friend (added back) or not.
				isConnected = true, -- Whether the soulmate is online or offline.
				gameId = 0, -- The id of the game where the soulmate is connected. Enum in enum.game.
				roomName = "", -- The name of the room the soulmate is in.
				lastConnection = 0 -- Timestamp of when the soulmate was last online.
			}
		]]
		self.event:emit("friendList", friendList, soulmate)
	end,
	[36] = function(self, packet, connection, tribulleId) -- Add friend
		--[[
			@desc Triggered when a player is added to the friend list.
			@param friend<table> The data of the new friend.
			@struct @friend {
				id = 0, -- The player id.
				playerName = "", -- The player's name.
				gender = 0, -- The player's gender. Enum in enum.gender.
				isFriend = true, -- Whether the player has the account as a friend (added back) or not.
				isConnected = true, -- Whether the player is online or offline.
				gameId = 0, -- The id of the game where the player is connected. Enum in enum.game.
				roomName = "", -- The name of the room the player is in.
				lastConnection = 0 -- Timestamp of when the player was last online.
			}
		]]
		self.event:emit("newFriend", handleFriendData(packet))
	end,
	[37] = function(self, packet, connection, tribulleId) -- Remove friend
		--[[@
			@name removeFriend
			@desc Triggered when a player is removed from the friend list.
			@param playerId<int> The id of the player that was removed.
		]]
		self.event:emit("removeFriend", packet:read32())
	end,
	[47] = function(self, packet, connection, tribulleId, _return) -- Loaded blacklist
		local blackList = { }
		for i = 1, packet:read16() do
			blackList[i] = packet:readUTF()
		end

		if _return then
			return blackList
		end

		--[[@
			@name blackList
			@desc Triggered when the black list is loaded.
			@param blackList<table> An array of strings of the names that are in the black list.
		]]
		self.event:emit("blackList", blackList)
	end,
	[59] = function(self, packet, connection, tribulleId) -- /who
		local fingerprint = packet:read32()

		packet:read8() -- ?

		local total = packet:read16()
		local data = { }
		for i = 1, total do
			data[i] = string_toNickname(packet:readUTF(), true)
		end

		local chatName = self._who_list[fingerprint]
		--[[@
			@name chatWho
			@desc Triggered when the /who command is loaded in a chat.
			@param chatName<string> The name of the chat.
			@param data<table> An array with the nicknames of the current users in the chat.
		]]
		self.event:emit("chatWho", chatName, data)
		self._who_list[fingerprint] = nil
	end,
	[64] = function(self, packet, connection, tribulleId) -- #Chat Message
		local playerName, community = packet:readUTF(), packet:read32()
		local chatName, message = packet:readUTF(), packet:readUTF()
		--[[@
			@name chatMessage
			@desc Triggered when a #chat receives a new message.
			@param chatName<string> The name of the chat.
			@param playerName<string> The player who sent the message.
			@param message<string> The message.
			@param playerCommunity<int> The community id of @playerName.
		]]
		self.event:emit("chatMessage", chatName, string_toNickname(playerName, true),
			string_fixEntity(message), community)
	end,
	[65] = function(self, packet, connection, tribulleId) -- Tribe message
		local memberName, message = packet:readUTF(), packet:readUTF()
		--[[@
			@name tribeMessage
			@desc Triggered when the tribe chat receives a new message.
			@param memberName<string> The member who sent the message.
			@param message<string> The message.
		]]
		self.event:emit("tribeMessage", string_toNickname(memberName, true),
			string_fixEntity(message))
	end,
	[66] = function(self, packet, connection, tribulleId) -- Whisper message
		local playerName, community = packet:readUTF(), packet:read32()
		local _, message = packet:readUTF(), packet:readUTF()
		--[[@
			@name whisperMessage
			@desc Triggered when the player receives a whisper.
			playerName<string> Who sent the whisper message.
			message<string> The message.
			playerCommunity<int> The community id of @playerName.
		]]
		self.event:emit("whisperMessage", string_toNickname(playerName, true),
			string_fixEntity(message), community)
	end,
	[88] = function(self, packet, connection, tribulleId) -- Tribe member connected
		local memberName = packet:readUTF()
		--[[@
			@name tribeMemberConnection
			@desc Triggered when a tribe member connects to the game.
			@param memberName<string> The member name.
		]]
		self.event:emit("tribeMemberConnection", string_toNickname(memberName, true))
	end,
	[90] = function(self, packet, connection, tribulleId) -- Tribe member disconnected
		local memberName = packet:readUTF()
		--[[@
			@name tribeMemberDisconnection
			@desc Triggered when a tribe member disconnects from the game.
			@param memberName<string> The member name.
		]]
		self.event:emit("tribeMemberDisconnection", string_toNickname(memberName, true))
	end,
	[91] = function(self, packet, connection, tribulleId) -- New tribe member
		local memberName = packet:readUTF()
		--[[@
			@name newTribeMember
			@desc Triggered when a player joins the tribe.
			@param memberName<string> The name of the new tribe member.
		]]
		self.event:emit("newTribeMember", string_toNickname(memberName, true))
	end,
	[92] = function(self, packet, connection, tribulleId) -- Tribe member leave
		local memberName = packet:readUTF()
		--[[@
			@name tribeMemberLeave
			@desc Triggered when a member leaves the tribe.
			@param memberName<string> The member who left the tribe.
		]]
		self.event:emit("tribeMemberLeave", string_toNickname(memberName, true))
	end,
	[93] = function(self, packet, connection, tribulleId) -- Tribe member kicked
		local memberName, kickerName = packet:readUTF(), packet:readUTF()
		--[[@
			@name tribeMemberKick
			@desc Triggered when a tribe member is kicked.
			@param memberName<string> The member name.
			@param kickerName<string> The name of the player who kicked the member.
		]]
		self.event:emit("tribeMemberKick", string_toNickname(memberName, true),
			string_toNickname(kickerName, true))
	end,
	[124] = function(self, packet, connection, tribulleId) -- Tribe member get role
		local setterName, memberName, role = packet:readUTF(), packet:readUTF(), packet:readUTF()
		--[[@
			@name tribeMemberGetRole
			@desc Triggered when a tribe member gets a role.
			@param memberName<string> The member name.
			@param setterName<string> The name of the player who set the role.
			@param role<string> The role name.
		]]
		self.event:emit("tribeMemberGetRole", string_toNickname(memberName, true),
			string_toNickname(setterName, true), role)
	end
}
-- Old packet functions
oldPacketListener = {
	[8] = {
		[5] = function(self, data, connection, oldIdentifiers) -- Updates player dead state [true]
			if not self._handle_players or self.playerList.count == 0 then return end

			local playerId, score = data[1], data[2]
			if self.playerList[playerId] then
				self.playerList[playerId].isDead = true
				self.playerList[playerId].score = score

				--[[@
					@name playerDied
					@desc Triggered when a player dies.
					@param playerData<table> The data of the player.
					@struct @playerData {
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
						y =  0, -- Player's X coordinate in the map.
						vx = 0, -- Player's X speed in the map.
						vy =  0, -- Player's Y speed in the map.
						isDucking = false, -- Whether the player is ducking.
						isJumping = false, -- Whether the player is jumping.
						_pos = 0 -- The position of the player in the array list. This value should never be changed manually.
					}
				]]
				self.event:emit("playerDied", self.playerList[playerId])
			end
		end,
		[7] = function(self, data, connection, oldIdentifiers) -- Removes player
			if not self._handle_players or self.playerList.count == 0 then return end

			local playerId = tonumber(data[1])
			if self.playerList[playerId] then
				--[[@
					@name playerLeft
					@desc Triggered when a player leaves the room.
					@param playerData<table> The data of the player.
					@struct @playerData {
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
						y =  0, -- Player's X coordinate in the map.
						vx = 0, -- Player's X speed in the map.
						vy =  0, -- Player's Y speed in the map.
						isDucking = false, -- Whether the player is ducking.
						isJumping = false, -- Whether the player is jumping.
						_pos = 0 -- The position of the player in the array list. This value should never be changed manually.
					}
				]]
				self.event:emit("playerLeft", self.playerList[playerId])

				-- Removes the numeric reference and decreases 1 for all the next players in the queue.
				local pos = self.playerList[playerId]._pos
				table_remove(self.playerList, self.playerList[playerId]._pos)

				self.playerList.count = self.playerList.count - 1
				for i = pos, self.playerList.count do
					if self.playerList[i] then
						self.playerList[i]._pos = self.playerList[i]._pos - 1
					else
						-- TODO : Error ?
					end
				end

				-- Removes the other references
				self.playerList[self.playerList[playerId].playerName] = nil
				self.playerList[playerId] = nil
			end
		end
	}
}
-- Normal functions
packetListener = {
	[1] = {
		[1] = function(self, packet, connection, identifiers) -- Old packets format
			local data = string_split(packet:readUTF(), "[^\x01]+")
			local oldIdentifiers = { string_byte(table_remove(data, 1), 1, 2) }

			if oldPacketListener[oldIdentifiers[1]]
				and oldPacketListener[oldIdentifiers[1]][oldIdentifiers[2]]
			then
				return oldPacketListener[oldIdentifiers[1]][oldIdentifiers[2]](self, data,
					connection, oldIdentifiers)
			end

			--[[@
				@name missedOldPacket
				@desc Triggered when an old packet is not handled by the old packet parser.
				@param oldIdentifiers<table> The oldC, oldCC identifiers that were not handled.
				@param data<table> The data that was not handled.
				@param connection<connection> The connection object.
			]]
			self.event:emit("missedOldPacket", oldIdentifiers, data, connection)
		end
	},
	[4] = {
		[4] = function(self, packet, connection, identifiers) -- Update player movement
			if not self._handle_players or self.playerList.count == 0 then return end

			local playerId = packet:read32()
			if self.playerList[playerId] then
				packet:read32() -- round code

				local oldPlayerData = table_copy(self.playerList[playerId])

				-- It's intended that, based on Lua behavior, all the hashes get updated automatically.
				self.playerList[playerId].movingRight = packet:readBool()
				self.playerList[playerId].movingLeft = packet:readBool()

				self.playerList[playerId].x = math_normalizePoint(packet:read32())
				self.playerList[playerId].y = math_normalizePoint(packet:read32())
				self.playerList[playerId].vx = packet:read16()
				self.playerList[playerId].vy = packet:read16()

				self.playerList[playerId].isJumping = packet:readBool()

				self.event:emit("updatePlayer", self.playerList[playerId], oldPlayerData)
			end
		end,
		[6] = function(self, packet, connection, identifiers) -- Updates player direction
			handlePlayerField(self, packet, "isFacingRight")
		end,
		[9] = function(self, packet, connection, identifiers) -- Updates ducking
			handlePlayerField(self, packet, "isDucking")
		end,
		[10] = function(self, packet, connection, identifiers) -- Updates player direction
			handlePlayerField(self, packet, "isFacingRight")
		end
	},
	[5] = {
		[2] = function(self, packet, connection, identifiers) -- New game
			if not self._isConnected then return end

			local map = { }
			map.code = packet:read32()

			packet:read16() -- ?
			packet:read8() -- ?
			packet:read16() -- ?

			local xml = packet:read8(packet:read16())
			if self._process_xml then
				xml = table_writeBytes(xml)
				if xml ~= '' then
					map.xml = zlibDecompress(xml, 1)
				end
			end
			map.author = packet:readUTF()
			map.perm = packet:read8()
			map.isMirrored = packet:readBool()

			--[[@
				@name newGame
				@desc Triggered when a map is loaded.
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
		[21] = function(self, packet, connection, identifiers) -- Room changed
			self.playerList = setmetatable({ }, meta.playerList) -- Refreshes it

			local isPrivate, roomName = packet:readBool(), packet:readUTF()

			if string_byte(roomName, 2) == 3 then
				--[[@
					@name joinTribeHouse
					@desc Triggered when the account joins a tribe house.
					@param tribeName<string> The name of the tribe.
				]]
				self.event:emit("joinTribeHouse", string_sub(roomName, 3))
			else
				--[[@
					@name roomChanged
					@desc Triggered when the player changes the room.
					@param roomName<string> The name of the room.
					@param isPrivateRoom<boolean> Whether the room is only accessible by the account or not.
				]]
				self.event:emit("roomChanged", string_fixEntity(roomName), isPrivate)
			end
		end
	},
	[6] = {
		[6] = function(self, packet, connection, identifiers) -- Room message
			local playerId, playerName = packet:read32(), packet:readUTF()
			local playerCommu, message = packet:read8(), string_fixEntity(packet:readUTF())
			--[[@
				@name roomMessage
				@desc Triggered when the room receives a new user message.
				@param playerName<string> The player who sent the message.
				@param message<string> The message.
				@param playerCommunity<int> The community id of @playerName.
				@param playerId<int> The temporary id of @playerName.
			]]
			self.event:emit("roomMessage", string_toNickname(playerName, true),
				string_fixEntity(message), playerCommu, playerId)
		end,
		[20] = function(self, packet, connection, identifiers) -- /time
			packet:read8() -- ?
			packet:readUTF() -- $TempsDeJeu
			packet:read8() -- Total parameters (useless?)

			local time = { }
			time.day = tonumber(packet:readUTF())
			time.hour = tonumber(packet:readUTF())
			time.minute = tonumber(packet:readUTF())
			time.second = tonumber(packet:readUTF())

			--[[@
				@name time
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
		[1] = function(self, packet, connection, identifiers) -- Emote played
			if not self._handle_players or self.playerList.count == 0 then return end

			local playerId = packet:read32()
			if self.playerList[playerId] then
				local emote = packet:read8()

				local flags
				if emote == enum.emote.flag then
					flag = packet:readUTF()
				end

				--[[@
					@name playerEmote
					@desc Triggered when a player plays an emote.
					@param playerData<table> The data of the player.
					@param emote<enum.emote> The id of the emote played the player.
					@param flag?<string> The country code of the flag when @emote is flag.
					@struct @playerData {
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
						y =  0, -- Player's X coordinate in the map.
						vx = 0, -- Player's X speed in the map.
						vy =  0, -- Player's Y speed in the map.
						isDucking = false, -- Whether the player is ducking.
						isJumping = false, -- Whether the player is jumping.
						_pos = 0 -- The position of the player in the array list. This value should never be changed manually.
					}
				]]
				self.event:emit("playerEmote", self.playerList[playerId], emote, flag)
			end
		end,
		[6] = function(self, packet, connection, identifiers) -- Updates player win state
			if not self._handle_players or self.playerList.count == 0 then return end

			packet:readBool() -- ?

			local playerId = packet:read32()
			if self.playerList[playerId] then
				self.playerList[playerId].score = packet:read16()
				self.playerList[playerId].hasWon = true
				self.playerList[playerId].winPosition = packet:read8()
				self.playerList[playerId].winTimeElapsed = packet:read16() / 100

				--[[@
					@name playerWon
					@desc Triggered when a player joins the hole.
					@param playerData<table> The data of the player.
					@param position<int> The position where the player entered the hole.
					@param timeElapsed<number> The time elapsed until the player entered the hole.
					@struct @playerdata {
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
						y =  0, -- Player's X coordinate in the map.
						vx = 0, -- Player's X speed in the map.
						vy =  0, -- Player's Y speed in the map.
						isDucking = false, -- Whether the player is ducking.
						isJumping = false, -- Whether the player is jumping.
						_pos = 0 -- The position of the player in the array list. This value should never be changed manually.
					}
				]]
				self.event:emit("playerWon", self.playerList[playerId],
					self.playerList[playerId].winPosition, self.playerList[playerId].winTimeElapsed)
			end
		end,
		[7] = function(self, packet, connection, identifiers) -- Updates player score
			handlePlayerField(self, packet, "score", nil, "read16")
		end,
		[11] = function(self, packet, connection, identifiers) -- Updates blue/ping shaman
			if not self._handle_players or self.playerList.count == 0 then return end

			local shaman = { }
			shaman[1] = packet:read32() -- Blue
			shaman[2] = packet:read32() -- Pink

			local oldPlayerData
			for i = 1, 2 do
				if self.playerList[shaman[i]] then
					oldPlayerData = table_copy(self.playerList[shaman[i]])

					self.playerList[shaman[i]][(i == 1 and "isBlueShaman" or "isPinkShaman")] = true

					self.event:emit("updatePlayer", self.playerList[shaman[i]], oldPlayerData)
				end
			end
		end,
		[12] = function(self, packet, connection, identifiers) -- Updates player shaman state [true]
			handlePlayerField(self, packet, "isShaman", nil, nil, true)
		end,
		[16] = function(self, packet, connection, identifiers) -- Profile data
			local data = { }
			data.playerName = packet:readUTF()
			data.id = packet:read32()
			data.registrationDate = packet:read32()
			data.role = packet:read8() -- enum.role

			data.gender = packet:read8() -- enum.gender
			data.tribeName = packet:readUTF()
			data.soulmate = string_toNickname(packet:readUTF())

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
				data.orbs[packet:read8()] = true -- Can't be optimized because totalOrbs may be < 2
			end

			packet:read8() -- ?

			data.adventurePoints = packet:read32()

			--[[@
				@name profileLoaded
				@desc Triggered when the profile of an player is loaded.
				@param data<table> The player profile data.
				@struct @data {
					playerName = "", -- The player's name.
					id = 0, -- The player id. It may be 0 if the player has no avatar.
					registrationDate = 0, -- The timestamp of when the player was created.
					role = 0, -- An enum from enum.role that specifies the player's role.
					gender = 0, -- An enum from enum.gender for the player's gender.
					tribeName = "", -- The name of the tribe.
					soulmate = "", -- The name of the soulmate.
					saves = {
						normal = 0, -- Total saves in normal mode.
						hard = 0, -- Total saves in hard mode.
						divine = 0 -- Total saves in divine mode.
					}, -- Total saves of the player.
					shamanCheese = 0, -- Number of cheese gathered as shaman.
					firsts = 0, -- Number of firsts.
					cheeses = 0, -- Number of cheese gathered.
					bootcamps = 0, -- Number of bootcamps completed.
					titleId = 0, -- The id of the current title.
					totalTitles = 0, -- Number of titles unlocked.
					titles = {
						[id] = 0 -- The id of the title as index, the number of stars as value.
					}, -- The list of unlocked titles.
					look = "", -- The player's outfit code.
					level = 0, -- The player's level.
					totalBadges = 0, -- Number of unlocked badges.
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
					totalOrbs = 0, -- Number of shaman orbs unlocked.
					orbs = {
						[id] = true -- The id of the shaman orb as index.
					}, -- The list of unlocked shaman orbs.
					adventurePoints = 0 -- Number of adventure points.
				}
			]]
			self.event:emit("profileLoaded", data)
		end,
		[66] = function(self, packet, connection, identifiers) -- Updates player vampire state
			--[[@
				@name playerVampire
				@desc Triggered when a player is transformed from/into a vampire.
				@param playerData<table> The data of the player.
				@param isVampire<boolean> Whether the player is a vampire or not.
				@struct @playerdata {
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
					y =  0, -- Player's X coordinate in the map.
					vx = 0, -- Player's X speed in the map.
					vy =  0, -- Player's Y speed in the map.
					isDucking = false, -- Whether the player is ducking.
					isJumping = false, -- Whether the player is jumping.
					_pos = 0 -- The position of the player in the array list. This value should never be changed manually.
				}
			]]
			handlePlayerField(self, packet, "isVampire", "playerVampire", nil, nil, true)
		end
	},
	[26] = {
		[2] = function(self, packet, connection, identifiers) -- Login
			self._isConnected = true
			self._connectionTime = os.time()

			local playerId = packet:read32()
			self.playerName = packet:readUTF()
			local playedTime = packet:read32()
			local community = packet:read8()

			timer_setTimeout(5000, function()
				--[[@
					@name connection
					@desc Triggered when the player is logged in and ready to perform actions.
					@param playerId<int> The temporary id of the player during the section.
					@param playerName<string> The name of the player that has connected.
					@param playedTime<int> The time played by the player.
					@param community<int> The community ID that the account has been logged into.
				]]
				self.event:emit("connection", playerId, self.playerName, playedTime, community)
			end)
		end,
		[3] = function(self, packet, connection, identifiers) -- Correct handshake identifiers
			local onlinePlayers = packet:read32()

			connection.packetID = packet:read8()
			local community = packet:readUTF() -- Necessary to get the country and authkeys later
			local country = packet:readUTF()

			self._receivedAuthkey = packet:read32() -- Receives an authentication key, parsed in the login function

			self._hbTimer = timer_setInterval(10 * 1000, sendHeartbeat, self)

			local communityPacket = byteArray:new():write8(self.community):write8(0)
			self.main:send(enum.identifier.community, communityPacket)

			local osInfo = byteArray:new():writeUTF("en"):writeUTF("Linux")
			osInfo:writeUTF("LNX 29,0,0,140"):write8(0)
			self.main:send(enum.identifier.os, osInfo)

			--[[@
				@name ready
				@desc Triggered when the connection is alive and ready to login.
				@param onlinePlayers<int> The number of players connected in the game.
				@param community<string> The community that the account has been logged into.
				@param country<string> The country related to the community connected.
			]]
			self.event:emit("ready", onlinePlayers, community, country)
		end,
		[35] = function(self, packet, connection, identifiers) -- Room list
			 -- Room types
			packet:read8(packet:read8())

			local rooms, counter = { }, 0
			local pinned, pinnedCounter = { }, 0

			local roomType, community, name, count, max, onFcMode
			local roomMode = packet:read8()
			while packet.stackLen > 0 do
				roomType = packet:read8()
				if roomType == 0 then -- Normal room
					community = packet:read8()
					name = packet:readUTF()
					count = packet:read16() -- total mice
					max = packet:read8() -- max total mice
					onFcMode = packet:readBool() -- funcorp mode

					counter = counter + 1
					rooms[counter] = {
						name = name,
						totalPlayers = count,
						maxPlayers = max,
						onFuncorpMode = onFcMode,
						community = community
					}
				elseif roomType == 1 then -- Pinned rooms / modules
					community = packet:read8()
					name = packet:readUTF()
					count = packet:readUTF() -- total mice
					count = tonumber(count) or count -- Make it a number
					packet:readUTF() -- mjj
					packet:readUTF() -- m room/#module

					pinnedCounter = pinnedCounter + 1
					pinned[pinnedCounter] = {
						name = name,
						totalPlayers = count,
						community = community
					}
				end
			end

			--[[@
				@name roomList
				@desc Triggered when the room list of a mode is loaded.
				@param roomMode<int> The id of the room mode.
				@param rooms<table> The data of the rooms in the list.
				@param pinned<tablet> The data of the pinned objects in the list.
				@struct @rooms {
					[i] = {
						name = "", -- The name of the room.
						totalPlayers = 0, -- Number of players in the room.
						maxPlayers = 0, -- Maximum Number of players the room can get.
						onFuncorpMode = false, -- Whether the room is having a funcorp event (orange name) or not.
						community = 0 -- The community of the room.
					}
				}
				@struct @pinned {
					[i] = {
						name = "", -- The name of the object.
						totalPlayers = 0, -- Number of players in the object counter. (Might be a string)
						community = 0 -- The community of the object.
					}
				}
			]]
			self.event:emit("roomList", roomMode, rooms, pinned)
		end,
	},
	[28] = {
		[5] = function(self, packet, connection, identifiers) -- /mod, /mapcrew
			packet:read16() -- ?
			--[[@
				@name staffList
				@desc Triggered when a staff list is loaded (/mod, /mapcrew).
				@param list<string> The staff list content.
			]]
			self.event:emit("staffList", packet:readUTF())
		end,
		[6] = function(self, packet, connection, identifiers) -- Ping
			--[[@
				@name ping
				@desc Triggered when a server heartbeat is received.
				@param time<int> The current time.
			]]
			self.event:emit("ping", os.time())
		end
	},
	[29] = {
		[6] = function(self, packet, connection, identifiers) -- Lua logs
			--[[@
				@name lua
				@desc Triggered when the #lua chat receives a log message.
				@param log<string> The log message.
			]]
			self.event:emit("lua", packet:readUTF())
		end
	},
	[30] = {
		[40] = function(self, packet, connection, identifiers) -- Cafe topic data
			local id, data
			local _messages, _totalMessages, _author

			while packet.stackLen > 0 do
				id = packet:read32()
				data = { id = id }
				data.title = packet:readUTF()
				data.authorId = packet:read32()
				data.posts = packet:read32()
				data.lastUserName = packet:readUTF()
				data.timestamp = os.time() - packet:read32()

				if self.cafe[id] then
					data.messages = self.cafe[id].messages
					data.author = self.cafe[id].author
				end
				self.cafe[id] = data
			end

			--[[@
				@name cafeTopicList
				@desc Triggered when the Café is opened or refreshed, and the topics are loaded partially.
				@param data<table> The data of the topics.
				@struct @data
				{
					[x] = {
						id = 0, -- The id of the topic.
						title = "", -- The title of the topic.
						authorId = 0, -- The id of the topic author.
						posts = 0, -- The number of messages in the topic.
						lastUserName = "", -- The name of the last user that posted in the topic.
						timestamp = 0, -- When the topic was created.

						-- The event "cafeTopicLoad" must be triggered so the fields below exist.
						author = "", -- The name of the topic author.
						messages = {
							[i] = {
								topicId = 0, -- The id of the topic where the message is located.
								id = 0, -- The id of the message.
								authorId = 0, -- The id of the topic author.
								timestamp = 0, -- When the topic was created.
								author = "", -- The name of the topic author.
								content = "", -- The content of the message.
								canLike = false, -- Whether the account can like/dislike the message.
								likes = 0 -- The number of likes on the message.
							}
						}
					}
				}
			]]
			self.event:emit("cafeTopicList", self.cafe)
		end,
		[41] = function(self, packet, connection, identifiers) -- Cafe message data
			packet:read8() -- ?

			local id = packet:read32()
			if not self.cafe[id] then
				self.cafe[id] = { id = id }
			end
			local data = self.cafe[id]

			data.messages = { }

			local totalMessages = 0

			while packet.stackLen > 0 do
				totalMessages = totalMessages + 1
				data.messages[totalMessages] = { }
				data.messages[totalMessages].topicId = id
				data.messages[totalMessages].id = packet:read32()
				data.messages[totalMessages].authorId = packet:read32()
				data.messages[totalMessages].timestamp = os.time() - packet:read32()
				data.messages[totalMessages].author = packet:readUTF()
				data.messages[totalMessages].content = string_gsub(packet:readUTF(), "\r", "\r\n")
				data.messages[totalMessages].canLike = packet:readBool()
				data.messages[totalMessages].likes = packet:readSigned16()
			end

			data.author = data.messages[1].author

			--[[@
				@name cafeTopicLoad
				@desc Triggered when a Café topic is opened or refreshed.
				@param topic<table> The data of the topic.
				@struct @topic
				{
					id = 0, -- The id of the topic.
					title = "", -- The title of the topic.
					authorId = 0, -- The id of the topic author.
					posts = 0, -- The number of messages in the topic.
					lastUserName = "", -- The name of the last user that posted in the topic.
					timestamp = 0, -- When the topic was created.
					author = "", -- The name of the topic author.
					messages = {
						[i] = {
							topicId = 0, -- The id of the topic where the message is located.
							id = 0, -- The id of the message.
							authorId = 0, -- The id of the topic author.
							timestamp = 0, -- When the topic was created.
							author = "", -- The name of the topic author.
							content = "", -- The content of the message.
							canLike = false, -- Whether the account can like/dislike the message.
							likes = 0 -- The number of likes on the message.
						}
					}
				}
			]]
			self.event:emit("cafeTopicLoad", topic)

			for i = 1, totalMessages do -- Unfortunately I couldn't make it decrescent, otherwise it would trigger the events in the wrong order
				if not self._cafeCachedMessages[data.messages[i].id] then
					self._cafeCachedMessages[data.messages[i].id] = true

					--[[@
						@name cafeTopicMessage
						@desc Triggered when a new message in a Café topic is cached.
						@param message<table> The data of the message.
						@param topic<table> The data of the topic.
						@struct @message
						{
							topicId = 0, -- The id of the topic where the message is located.
							id = 0, -- The id of the message.
							authorId = 0, -- The id of the topic author.
							timestamp = 0, -- When the topic was created.
							author = "", -- The name of the topic author.
							content = "", -- The content of the message.
							canLike = false, -- Whether the account can like/dislike the message.
							likes = 0 -- The number of likes on the message.
						}
						@struct @data
						{
							id = 0, -- The id of the topic.
							title = "", -- The title of the topic.
							authorId = 0, -- The id of the topic author.
							posts = 0, -- The number of messages in the topic.
							lastUserName = "", -- The name of the last user that posted in the topic.
							timestamp = 0, -- When the topic was created.
							author = "", -- The name of the topic author.
							messages = {
								[i] = {
									topicId = 0, -- The id of the topic where the message is located.
									id = 0, -- The id of the message.
									authorId = 0, -- The id of the topic author.
									timestamp = 0, -- When the topic was created.
									author = "", -- The name of the topic author.
									content = "", -- The content of the message.
									canLike = false, -- Whether the account can like/dislike the message.
									likes = 0 -- The number of likes on the message.
								}
							}
						}
					]]
					self.event:emit("cafeTopicMessage", data.messages[i], data)
				end
			end
		end,
		[44] = function(self, packet, connection, identifiers) -- New Cafe post detected
			local topicId = packet:read32()

			--[[@
				@name unreadCafeMessage
				@desc Triggered when new messages are posted on Café.
				@param topicId<int> The id of the topic where the new messages were posted.
				@param topic<table> The data of the topic. It **may be** nil.
				@struct @topic
				{
					id = 0, -- The id of the topic.
					title = "", -- The title of the topic.
					authorId = 0, -- The id of the topic author.
					posts = 0, -- The number of messages in the topic.
					lastUserName = "", -- The name of the last user that posted in the topic.
					timestamp = 0, -- When the topic was created.

					-- The event "cafeTopicLoad" must be triggered so the fields below exist.
					author = "", -- The name of the topic author.
					messages = {
						-- This might not include the unread message.
						[i] = {
							topicId = 0, -- The id of the topic where the message is located.
							id = 0, -- The id of the message.
							authorId = 0, -- The id of the topic author.
							timestamp = 0, -- When the topic was created.
							author = "", -- The name of the topic author.
							content = "", -- The content of the message.
							canLike = false, -- Whether the account can like/dislike the message.
							likes = 0 -- The number of likes on the message.
						}
					}
				}
			]]
			self.event:emit("unreadCafeMessage", topicId, self.cafe[topicId])
		end
	},
	[44] = {
		[1] = function(self, packet, connection, identifiers) -- Switch bulle identifiers
			local serverTimestamp = packet:read32()
			local bulleId = packet:read32()
			local bulleIp = packet:readUTF()

			local oldBulle = self.bulle
			self.bulle = connection:new("bulle", self.event)
			self.bulle:connect(bulleIp, enum.setting.port[self.main.port])

			self.bulle.event:once("_socketConnection", function()
				if oldBulle then
					oldBulle:close()
				end

				self.bulle:send(enum.identifier.bulleConnection,
					byteArray:new():write32(serverTimestamp):write32(bulleId))
				--[[@
					@name switchBulleConnection
					@desc Triggered when the bulle connection is switched.
					@param bulleId<int> The ID of the new bulle.
					@param bulleIp<string> The IP of the new bulle.
					@param serverTimestamp<int> The timestamp of the server.
				]]
				self.event:emit("switchBulleConnection", bulleId, bulleIp, serverTimestamp)
			end)
		end,
		[22] = function(self, packet, connection, identifiers) -- PacketID offset identifiers
			connection.packetID = packet:read8() -- Sets the pkt of the connection
		end
	},
	[60] = {
		[3] = function(self, packet, connection, identifiers) -- Community Platform
			local tribulleId = packet:read16()
			if tribulleListener[tribulleId] then
				return tribulleListener[tribulleId](self, packet, connection, tribulleId)
			end
			--[[@
				@name missedTribulle
				@desc Triggered when a tribulle packet is not handled by the tribulle packet parser.
				@param tribulleId<int> The tribulle id.
				@param packet<byteArray> The Byte Array object with the packet that was not handled.
				@param connection<connection> The connection object.
			]]
			self.event:emit("missedTribulle", tribulleId, packet, connection)
		end
	},
	[144] = {
		[1] = function(self, packet, connection, identifiers) -- Set player list
			if not self._handle_players then return end

			self.playerList.count = packet:read16() -- Total mice in the room

			for i = 1, self.playerList.count do
				packetListener[144][2](self, packet, connection, nil, i)
			end

			--[[@
				@name refreshPlayerList
				@desc Triggered when the data of all players are refreshed (mostly when a new map is loaded).
				@param playerList<table> The data of all players.
				@struct @playerList {
					[playerName] = {
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
						y =  0, -- Player's X coordinate in the map.
						vx = 0, -- Player's X speed in the map.
						vy =  0, -- Player's Y speed in the map.
						isDucking = false, -- Whether the player is ducking.
						isJumping = false, -- Whether the player is jumping.
						_pos = 0 -- The position of the player in the array list. This value should never be changed manually.
					},
					[i] = { }, -- Reference of [playerName], 'i' is stored in '_pos'
					[id] = { } -- Reference of [playerName]
				}
			]]
			self.event:emit("refreshPlayerList", self.playerList)
		end,
		[2] = function(self, packet, connection, identifiers, _pos) -- Updates player data
			if not self._handle_players or (not _pos and self.playerList.count == 0) then return end

			local data, color = { }
			data.playerName = packet:readUTF()
			data.id = packet:read32() -- Temporary id
			data.isShaman = packet:readBool()
			data.isDead = packet:readBool()
			data.score = packet:read16()
			data.hasCheese = packet:readBool()
			data.title = packet:read16()
			data.titleStars = packet:read8() - 1
			data.gender = packet:read8()
			packet:readUTF() -- ?
			data.look = packet:readUTF()
			packet:readBool() -- ?
			data.mouseColor = packet:read32()
			data.shamanColor = packet:read32()
			packet:read32() -- ?
			color = packet:read32()
			data.nameColor = (color == 0xFFFFFFFF and -1 or color)

			-- Custom or delayed data
			data.isSouris = (string_sub(data.playerName, 1, 1) == '*')
			data.isVampire = false
			data.hasWon = false
			data.winPosition = -1
			data.winTimeElapsed = -1
			data.isFacingRight = true
			data.movingRight = false
			data.movingLeft = false
			data.isBlueShaman = false
			data.isPinkShaman = false

			data.x = 0
			data.y = 0
			data.vx = 0
			data.vy = 0
			data.isDucking = false
			data.isJumping = false

			local isNew, oldPlayerData = false
			if not self.playerList[data.playerName] then
				isNew = true

				if _pos then
					data._pos = _pos
				else
					self.playerList.count = self.playerList.count + 1
					data._pos = self.playerList.count
				end
			else
				oldPlayerData = table_copy(self.playerList[data.id])
				data._pos = self.playerList[data.playerName]._pos
			end

			self.playerList[data._pos] = data
			self.playerList[data.playerName] = data
			self.playerList[data.id] = data

			if not _pos and not (isNew and data.playerName == self.playerName) then
				--[[@
					@name newPlayer
					@desc Triggered when a player joins the room.
					@param playerData<table> The data of the player.
					@struct @playerdata {
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
						y =  0, -- Player's X coordinate in the map.
						vx = 0, -- Player's X speed in the map.
						vy =  0, -- Player's Y speed in the map.
						isDucking = false, -- Whether the player is ducking.
						isJumping = false, -- Whether the player is jumping.
						_pos = 0 -- The position of the player in the array list. This value should never be changed manually.
					}
				]]
				self.event:emit((isNew and "newPlayer" or "updatePlayer"), data, oldPlayerData)
			end
		end,
		[6] = function(self, packet, connection, identifiers) -- Updates player cheese state
			--[[@
				@name playerGetCheese
				@desc Triggered when a player gets (or loses) the cheese.
				@param playerData<table> The data of the player.
				@param hasCheese<boolean> Whether the player has cheese or not.
				@struct @playerdata {
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
					y =  0, -- Player's X coordinate in the map.
					vx = 0, -- Player's X speed in the map.
					vy =  0, -- Player's Y speed in the map.
					isDucking = false, -- Whether the player is ducking.
					isJumping = false, -- Whether the player is jumping.
					_pos = 0 -- The position of the player in the array list. This value should never be changed manually.
				}
			]]
			handlePlayerField(self, packet, "hasCheese", "playerGetCheese", nil, nil, true)
		end,
		[7] = function(self, packet, connection, identifiers) -- Updates player shaman state [false]
			handlePlayerField(self, packet, "isShaman", nil, nil, false)
		end
	}
}

-- System
-- Packet listeners and parsers
--[[@
	@name insertPacketListener
	@desc Inserts a new function to the packet parser.
	@param C<int> The C packet.
	@param CC<int> The CC packet.
	@param f<function> The function to be triggered when the @C-@CC packets are received. The parameters are (packet, connection, identifiers).
	@param append?<boolean> 'true' if the function should be appended to the (C, CC) listener, 'false' if the function should overwrite the (C, CC) listener. @default false
]]
client.insertPacketListener = function(self, C, CC, f, append)
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
	@param f<function> The function to be triggered when this tribulle packet is received. The parameters are (packet, connection, tribulleId).
	@param append?<boolean> 'true' if the function should be appended to the (C, CC, tribulle) listener, 'false' if the function should overwrite the (C, CC) listener. @default false
]]
client.insertTribulleListener = function(self, tribulleId, f, append)
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
	@param f<function> The function to be triggered when the @C-@CC packets are received. The parameters are (data, connection, oldIdentifiers).
	@param append?<boolean> 'true' if the function should be appended to the (C, CC) listener, 'false' if the function should overwrite the (C, CC) listener. @default false
]]
client.insertOldPacketListener = function(self, C, CC, f, append)
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
	@desc Gets the connection keys in the API endpoint.
	@param self<client> A Client object.
	@param tfmId<string,int> The developer's transformice id.
	@param token<string> The developer's token.
]]
getKeys = function(self, tfmId, token)
	if not self._hasSpecialRole or self._useEndpointOnSpecialRole then
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
				enum.setting.port = result.ports
				if not self._hasSpecialRole then
					enum.setting.gameVersion = result.version
					self._gameConnectionKey = result.connection_key
					self._gameAuthkey = result.auth_key
					self._encode.identificationKeys = result.identification_keys
					self._encode.messageKeys = result.msg_keys
				end
			else
				return error(string_format("↑error↓[API ENDPOINT]↑ An internal error occurred in \z
					the API endpoint.\n\t'%s'%s", result.internal_error_step,
					(result.internal_error_step == 2 and ": The game may be in maintenance." or '')
				), enum.errorLevel.high)
			end
		else
			return error("↑error↓[API ENDPOINT]↑ Impossible to get the keys.\n\tError: " ..
				tostring(result.error), enum.errorLevel.high)
		end
	end
end
--[[@
	@name sendHeartbeat
	@desc Sends server heartbeats/pings to the servers.
	@param self<client> A Client object.
]]
sendHeartbeat = function(self)
	self.main:send(enum.identifier.heartbeat, byteArray:new())
	if self.bulle and self.bulle.open then
		self.bulle:send(enum.identifier.heartbeat, byteArray:new())
	end

	--[[@
		@name heartbeat
		@desc Triggered when a heartbeat is sent to the connection, every 10 seconds.
		@param time<int> The current time.
	]]
	self.event:emit("heartbeat", os.time())
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
			self.bulle:close()
		end
		timer_clearInterval(self._mainLoop)
		self.main:close()
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
	if not self._handle_players or self.playerList.count == 0 then return end

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
				y =  0, -- Player's X coordinate in the map.
				vx = 0, -- Player's X speed in the map.
				vy =  0, -- Player's Y speed in the map.
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
	@name handleFriendData
	@desc Handles the data of a friend from the friend list.
	@param packet<byteArray> A Byte Array object with the data to be extracted.
	@returns table The data of the player.
	@struct {
		id = 0, -- The player id.
		playerName = "", -- The player's name.
		gender = 0, -- The player's gender. Enum in enum.gender.
		isFriend = true, -- Whether the player has the account as a friend (added back) or not.
		isConnected = true, -- Whether the player is online or offline.
		gameId = 0, -- The id of the game where the player is connected. Enum in enum.game.
		roomName = "", -- The name of the room the player is in.
		lastConnection = 0 -- Timestamp of when the player was last online.
	}
]]
handleFriendData = function(packet)
	local player = { }
	player.id = packet:read32()
	player.playerName = string.toNickname(packet:readUTF())
 	player.gender = packet:read8()
 	packet:read32() -- id again
	player.isFriend = packet:readBool()
	player.isConnected = packet:readBool()
	player.gameId = packet:read32()
	player.roomName = packet:readUTF()
	player.lastConnection = packet:read32()
	return player
end

--[[@
	@name start
	@desc Initializes the API connection with the authentication keys. It must be the first method of the API to be called.
	@param tfmId<string,int> The Transformice ID of your account. If you don't know how to obtain it, go to the room **#bolodefchoco0id** and check your chat.
	@param token<string> The API Endpoint token to get access to the authentication keys.
]]
client.start = coroutine_makef(function(self, tfmId, token)
	self:disconnect()
	self.isConnected = false

	getKeys(self, tfmId, token)

	self.main:connect(enum.setting.mainIp)

	self.main.event:once("_socketConnection", function()
		local packet = byteArray:new():write16(enum.setting.gameVersion)
		if not self._hasSpecialRole then
			packet:writeUTF(self._gameConnectionKey)
		end
		packet:writeUTF("Desktop"):writeUTF('-'):write32(0x1FBD):writeUTF('')
		packet:writeUTF("86bd7a7ce36bec7aad43d51cb47e30594716d972320ef4322b7d88a85904f0ed")
		packet:writeUTF("A=t&SA=t&SV=t&EV=t&MP3=t&AE=t&VE=t&ACC=t&PR=t&SP=f&SB=f&DEB=f&V=LNX 29,0,\z
			0,140&M=Adobe Linux&R=1920x1080&COL=color&AR=1.0&OS=Linux&ARCH=x86&L=en&IME=t&PR32=t&P\z
			R64=t&LS=en-US&PT=Desktop&AVD=f&LFD=f&WD=f&TLS=t&ML=5.1&DP=72")
		packet:write32(0):write32(0x6257):writeUTF('')

		self.main:send(enum.identifier.initialize, packet)

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
end)
--[[@
	@name on
	@desc Sets an event emitter that is triggered everytime a specific behavior happens.
	@desc See the available events in @see Events.
	@param eventName<string> The name of the event.
	@param callback<function> The function that must be called when the event is triggered.
]]
client.on = function(self, eventName, callback)
	return self.event:on(eventName, coroutine_makef(callback))
end
--[[@
	@name once
	@desc Sets an event emitter that is triggered only once a specific behavior happens.
	@desc See the available events in @see Events.
	@param eventName<string> The name of the event.
	@param callback<function> The function that must be called only once when the event is triggered.
]]
client.once = function(self, eventName, callback)
	return self.event:once(eventName, coroutine_makef(callback))
end
--[[@
	@name emit
	@desc Emits an event.
	@desc See the available events in @see Events. You can also create your own events / emitters.
	@param eventName<string> The name of the event.
	@param ...?<*> The parameters to be passed during the emitter call.
]]
client.emit = function(self, eventName, ...)
	return self.event:emit(eventName, ...)
end
--[[@
	@name connectionTime
	@desc Gets the total time since the account was connected.
	@returns int The total time since account was logged in.
]]
client.connectionTime = function(self)
	return os.time() - self._connectionTime
end

-- Methods
-- Initialization
--[[@
	@name setCommunity
	@desc Sets the community the bot will connect to.
	@desc /!\ This method must be called before the @see start.
	@param community?<enum.community> An enum from @see community. (index or value) @default EN
]]
client.setCommunity = function(self, community)
	community = enum_validate(enum.community, enum.community.en, community,
		string_format(enum.error.invalidEnum, "setCommunity", "community", "community"))
	if not community then return end

	self.community = community
end
--[[@
	@name handlePlayers
	@desc Toggles the field _\_handle\_players_ of the instance.
	@desc If 'true', the following events are going to be handled: _playerGetCheese_, _playerVampire_, _playerWon_, _playerLeft_, _playerDied_, _newPlayer_, _refreshPlayerList_, _updatePlayer_, _playerEmote_.
	@param handle?<boolean> Whether the bot should handle the player events. The default value is the inverse of the current value. The instance starts the field as 'false'.
	@returns boolean Whether the bot will handle the player events.
]]
client.handlePlayers = function(self, handle)
	if handle == nil then
		self._handle_players = not self._handle_players
	else
		self._handle_players = handle
	end
	return self._handle_players
end
--[[@
	@name processXml
	@desc Toggles the field _\_process\_xml_ of the instance.
	@desc If 'true', the XML will be processed in the event _newGame_.
	@param process?<boolean> Whether map XMLs should be processed.
	@returns boolean Whether map XMLs will be processed.
]]
client.processXml = function(self, process)
	if process == nil then
		self._process_xml = not self._process_xml
	else
		self._process_xml = process
	end
	return self._process_xml
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
	client.connect = function(self, userName, userPassword, startRoom, timeout)
		userName = string_toNickname(userName, true)

		local packet = byteArray:new()
			:writeUTF(userName)
			:writeUTF(encode_getPasswordHash(userPassword))
			:writeUTF("app:/TransformiceAIR.swf/[[DYNAMIC]]/2/[[DYNAMIC]]/4")
			:writeUTF((startRoom and tostring(startRoom)) or "*#bolodefchoco")
		if not self._hasSpecialRole then
			packet:write32(bit_bxor(self._receivedAuthkey, self._gameAuthkey))
		end
		packet:write8(0):writeUTF('')
		if not self._hasSpecialRole then
			packet = self._encode.btea(packet)
		end
		packet:write8(0)

		self.playerName = userName
		self.main:send(enum.identifier.loginSend, packet)

		timer_setTimeout((timeout or (20 * 1000)), checkConnection, self)
	end
end
--[[@
	@name disconnect
	@desc Forces the private function @see closeAll to be called. (Ends the connections)
	@returns boolean Whether the Connection objects can be destroyed or not.
]]
client.disconnect = function(self)
	if self.main then
		self.main.open = false
		return true
	end
	return false
end
-- Room
--[[@
	@name enterRoom
	@desc Enters in a room.
	@param roomName<string> The name of the room.
	@param isSalonAuto?<boolean> Whether the change room must be /salonauto or not. @default false
]]
client.enterRoom = function(self, roomName, isSalonAuto)
	self.main:send(enum.identifier.room,
		byteArray:new():write8(self.community):writeUTF(roomName):writeBool(isSalonAuto))
end
--[[@
	@name sendRoomMessage
	@desc Sends a message in the room chat.
	@desc /!\ Note that a message has a limit of 80 characters in the first 24 hours after the account creation, and 255 characters later. You must handle the limit yourself or the bot may get disconnected.
	@param message<string> The message.
]]
client.sendRoomMessage = function(self, message)
	self.bulle:send(enum.identifier.roomMessage,
		self._encode:xorCipher(byteArray:new():writeUTF(message), self.bulle.packetID))
end
-- Whisper
--[[@
	@name sendWhisper
	@desc Sends a whisper to a user.
	@desc /!\ Note that a message has a limit of 80 characters in the first 24 hours after the account creation, and 255 characters later. You must handle the limit yourself or the bot may get disconnected.
	@param message<string> The message.
	@param targetUser<string> The user who will receive the whisper.
]]
client.sendWhisper = function(self, targetUser, message)
	self.main:send(enum.identifier.bulle, self._encode:xorCipher(
		byteArray:new():write16(52):write32(3):writeUTF(targetUser):writeUTF(message),
		self.main.packetID))
end
--[[@
	@name changeWhisperState
	@desc Sets the account's whisper state.
	@param message?<string> The /silence message. @default ''
	@param state?<enum.whisperState> An enum from @see whisperState. (index or value) @default enabled
]]
client.changeWhisperState = function(self, message, state)
	state = enum_validate(enum.whisperState, enum.whisperState.enabled, state,
		string_format(enum.error.invalidEnum, "changeWhisperState", "state", "whisperState"))
	if not state then return end

	self.main:send(enum.identifier.bulle, self._encode:xorCipher(
		byteArray:new():write16(60):write32(1):write8(state):writeUTF(message or ''),
		self.main.packetID))
end
-- Chat
--[[@
	@name joinChat
	@desc Joins a #chat.
	@param chatName<string> The name of the chat.
]]
client.joinChat = function(self, chatName)
	self.main:send(enum.identifier.bulle, self._encode:xorCipher(
		byteArray:new():write16(54):write32(1):writeUTF(chatName):write8(1), self.main.packetID))
end
--[[@
	@name sendChatMessage
	@desc Sends a message to a #chat.
	@desc /!\ Note that a message has a limit of 80 characters in the first 24 hours after the account creation, and 255 characters later. You must handle the limit yourself or the bot may get disconnected.
	@param chatName<string> The name of the chat.
	@param message<string> The message.
]]
client.sendChatMessage = function(self, chatName, message)
	self.main:send(enum.identifier.bulle, self._encode:xorCipher(
		byteArray:new():write16(48):write32(1):writeUTF(chatName):writeUTF(message),
		self.main.packetID))
end
--[[@
	@name closeChat
	@desc Leaves a #chat.
	@param chatName<string> The name of the chat.
]]
client.closeChat = function(self, chatName)
	self.main:send(enum.identifier.bulle, self._encode:xorCipher(
		byteArray:new():write16(56):write32(1):writeUTF(chatName),
		self.main.packetID))
end
--[[@
	@name chatWho
	@desc Gets the names of players in a specific chat. (/who)
	@param chatName<string> The name of the chat.
]]
client.chatWho = function(self, chatName)
	self._who_fingerprint = (self._who_fingerprint + 1) % 500
	self._who_list[self._who_fingerprint] = chatName

	self.main:send(enum.identifier.bulle, self._encode:xorCipher(
		byteArray:new():write16(58):write32(self._who_fingerprint):writeUTF(chatName),
		self.main.packetID))
end
-- Tribe
--[[@
	@name joinTribeHouse
	@desc Joins the tribe house (if the account is in a tribe).
]]
client.joinTribeHouse = function(self)
	self.main:send(enum.identifier.joinTribeHouse, byteArray:new())
end
--[[@
	@name sendTribeMessage
	@desc Sends a message to the tribe chat.
	@desc /!\ Note that a message has a limit of 80 characters in the first 24 hours after the account creation, and 255 characters later. You must handle the limit yourself or the bot may get disconnected.
	@param message<string> The message.
]]
client.sendTribeMessage = function(self, message)
	self.main:send(enum.identifier.bulle, self._encode:xorCipher(
		byteArray:new():write16(50):write32(3):writeUTF(message), self.main.packetID))
end
--[[@
	@name recruitPlayer
	@desc Sends a tribe invite to a player.
	@desc /!\ Note that this method will not cover errors if the account is not in a tribe or does not have permissions.
	@param playerName<string> The name of player to be recruited.
]]
client.recruitPlayer = function(self, playerName)
	self.main:send(enum.identifier.bulle, self._encode:xorCipher(
		byteArray:new():write16(78):write32(1):writeUTF(playerName), self.main.packetID))
end
--[[@
	@name kickTribeMember
	@desc Kicks a member from the tribe.
	@desc /!\ Note that this method will not cover errors if the account is not in a tribe or does not have permissions.
	@param memberName<string> The name of the member to be kicked.
]]
client.kickTribeMember = function(self, memberName)
	self.main:send(enum.identifier.bulle, self._encode:xorCipher(
		byteArray:new():write16(104):write32(1):writeUTF(memberName), self.main.packetID))
end
--[[@
	@name setTribeMemberRole
	@desc Sets the role of a member in the tribe.
	@desc /!\ Note that this method will not cover errors if the account is not in a tribe or does not have permissions.
	@param memberName<string> The name of the member to get the role.
	@param roleId<int> The role id. (starts from 0, the initial role, and goes until the Chief role)
]]
client.setTribeMemberRole = function(self, memberName, roleId)
	self.main:send(enum.identifier.bulle, self._encode:xorCipher(
		byteArray:new():write16(112):write32(1):writeUTF(memberName):write8(roleId),
		self.main.packetID))
end
--[[@
	@name loadLua
	@desc Loads a lua script in the room.
	@param script<string> The lua script.
]]
client.loadLua = function(self, script)
	self.bulle:send(enum.identifier.loadLua, byteArray:new():writeBigUTF(script))
end
-- Café
--[[@
	@name reloadCafe
	@desc Reloads the Café data.
]]
client.reloadCafe = function(self)
	self.main:send(enum.identifier.cafeData, byteArray:new())
end
--[[@
	@name openCafe
	@desc Toggles the current Café state (open / close).
	@desc It will send @see client.reloadCafe automatically if close is false.
	@param close?<boolean> If the Café should be closed. @default false
]]
client.openCafe = function(self, close)
	close = not close
	self.main:send(enum.identifier.cafeState, byteArray:new():writeBool(close))
	if close then -- open = reload
		self:reloadCafe()
	end
end
--[[@
	@name createCafeTopic
	@desc Creates a Café topic.
	@desc /!\ The method does not handle the Café's cooldown system.
	@param title<string> The title of the topic.
	@param message<string> The content of the topic.
]]
client.createCafeTopic = function(self, title, message)
	message = string_gsub(message, "\r\n", "\r")
	self.main:send(enum.identifier.cafeNewTopic, byteArray:new():writeUTF(title):writeUTF(message))
end
--[[@
	@name openCafeTopic
	@desc Opens a Café topic.
	@desc You may use this method to reload (or refresh) the topic.
	@param topicId<int> The id of the topic to be opened.
]]
client.openCafeTopic = function(self, topicId)
	self.main:send(enum.identifier.cafeLoadData, byteArray:new():write32(topicId))
end
--[[@
	@name sendCafeMessage
	@desc Sends a message in a Café topic.
	@desc /!\ The method does not handle the Café's cooldown system: 300 seconds if the last post is from the same account, otherwise 10 seconds.
	@param topicId<int> The id of the topic where the message will be posted.
	@param message<string> The message to be posted.
]]
client.sendCafeMessage = function(self, topicId, message)
	message = string_gsub(message, "\r\n", "\r")
	self.main:send(enum.identifier.cafeSendMessage,
		byteArray:new():write32(topicId):writeUTF(message))
end
--[[@
	@name likeCafeMessage
	@desc Likes/Dislikes a message in a Café topic.
	@desc /!\ The method does not handle the Café's cooldown system: 300 seconds to react in a message.
	@param topicId<int> The id of the topic where the message is located.
	@param messageId<int> The id of the message that will receive the reaction.
	@param dislike?<boolean> Whether the reaction must be a dislike or not. @default false
]]
client.likeCafeMessage = function(self, topicId, messageId, dislike)
	self.main:send(enum.identifier.cafeLike,
		byteArray:new():write32(topicId):write32(messageId):writeBool(not dislike))
end
-- Friends
--[[@
	@name requestFriendList
	@desc Requests the friend list.
]]
client.requestFriendList = function(self)
	self.main:send(enum.identifier.bulle, self._encode:xorCipher(
		byteArray:new():write16(28):write32(3), self.main.packetID))
end
--[[@
	@name requestBlackList
	@desc Requests the black list.
]]
client.requestBlackList = function(self)
	self.main:send(enum.identifier.bulle, self._encode:xorCipher(
		byteArray:new():write16(46):write32(3), self.main.packetID))
end
--[[@
	@name addFriend
	@desc Adds a player to the friend list.
	@param playerName<string> The player name to be added.
]]
client.addFriend = function(self, playerName)
	self.main:send(enum.identifier.bulle, self._encode:xorCipher(
		byteArray:new():write16(18):write32(1):writeUTF(playerName), self.main.packetID))
end
--[[@
	@name removeFriend
	@desc Removes a player from the friend list.
	@param playerName<string> The player name to be removed from the friend list.
]]
client.removeFriend = function(self, playerName)
	self.main:send(enum.identifier.bulle, self._encode:xorCipher(
		byteArray:new():write16(20):write32(1):writeUTF(playerName), self.main.packetID))
end
--[[@
	@name blacklistPlayer
	@desc Adds a player to the black list.
	@param playerName<string> The player name to be added.
]]
client.blacklistPlayer = function(self, playerName)
	self.main:send(enum.identifier.bulle, self._encode:xorCipher(
		byteArray:new():write16(42):write32(1):writeUTF(playerName), self.main.packetID))
end
--[[@
	@name whitelistPlayer
	@desc Removes a player from the black list.
	@param playerName<string> The player name to be removed from the black list.
]]
client.whitelistPlayer = function(self, playerName)
	self.main:send(enum.identifier.bulle, self._encode:xorCipher(
		byteArray:new():write16(44):write32(1):writeUTF(playerName), self.main.packetID))
end
-- Miscellaneous
--[[@
	@name sendCommand
	@desc Sends a (/)command.
	@desc /!\ Note that some unlisted commands cannot be triggered by this function.
	@param command<string> The command. (without /)
]]
client.sendCommand = function(self, command, crypted)
	self.main:send(enum.identifier.command, self._encode:xorCipher(
		byteArray:new():writeUTF(command), self.main.packetID))
end
--[[@
	@name playEmote
	@desc Plays an emote.
	@param emote?<enum.emote> An enum from @see emote. (index or value) @default dance
	@param flag?<string> The country code of the flag when @emote is flag.
]]
client.playEmote = function(self, emote, flag)
	emote = enum_validate(enum.emote, enum.emote.dance, emote,
		string_format(enum.error.invalidEnum, "playEmote", "emote", "emote"))
	if not emote then return end

	local packet = byteArray:new():write8(emote):write32(0)
	if emote == enum.emote.flag then
		packet = packet:writeUTF(flag)
	end

	self.bulle:send(enum.identifier.emote, packet)
end
--[[@
	@name playEmoticon
	@desc Plays an emoticon.
	@param emoticon?<enum.emoticon> An enum from @see emoticon. (index or value) @default smiley
]]
client.playEmoticon = function(self, emoticon)
	emoticon = enum_validate(enum.emoticon, enum.emoticon.smiley, emoticon,
		string_format(enum.error.invalidEnum, "playEmoticon", "emoticon", "emoticon"))
	if not emoticon then return end

	self.bulle:send(enum.identifier.emoticon, byteArray:new():write8(emoticon):write32(0))
end
--[[@
	@name requestRoomList
	@desc Requests the data of a room mode list.
	@param roomMode?<enum.roomMode> An enum from @see roomMode. (index or value) @default normal
]]
client.requestRoomList = function(self, roomMode)
	roomMode = enum_validate(enum.roomMode, enum.roomMode.normal, roomMode,
		string_format(enum.error.invalidEnum, "requestRoomList", "roomMode", "roomMode"))
	if not roomMode then return end

	self.main:send(enum.identifier.roomList, byteArray:new():write8(roomMode))
end

----- Compatibility -----
client.insertReceiveFunction = "insertPacketListener"
client.insertTribulleFunction = "insertTribulleListener"
client.closeAll = "disconnect"
-------------------------

return client
