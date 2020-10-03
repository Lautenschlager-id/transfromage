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

-- System
-- Packet listeners and parsers


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


-- Miscellaneous



----- Compatibility -----
Client.insertReceiveFunction = "insertPacketListener"
Client.insertTribulleFunction = "insertTribulleListener"
Client.closeAll = "disconnect"
-------------------------

