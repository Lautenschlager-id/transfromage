local PlayerList = require("api/Entities/player/PlayerList")
local Room = require("api/Entities/room/Room")

------------------------------------------- Optimization -------------------------------------------
local string_byte      = string.byte
local string_fixEntity = string.fixEntity
local string_sub       = string.sub
----------------------------------------------------------------------------------------------------

local onRoomChange = function(self, packet, connection, identifiers)
	self.playerList = PlayerList:new(self)

	self.room = Room:new(packet)

	if self.room.isTribeHouse then
		--[[@
			@name joinTribeHouse
			@desc Triggered when the account joins a tribe house.
			@param tribeName<string> The name of the tribe.
			@param roomLanguage<string> The language of the tribe.
		]]
		self.event:emit("joinTribeHouse", self.room)
	else
		--[[@
			@name roomChanged
			@desc Triggered when the player changes the room.
			@param roomName<string> The name of the room.
			@param roomLanguage<string> The language of the room.
			@param isPrivateRoom<boolean> Whether the room is only accessible by the account or not.
		]]
		self.event:emit("roomChanged", self.room)
	end
end

return { onRoomChange, 5, 21 }