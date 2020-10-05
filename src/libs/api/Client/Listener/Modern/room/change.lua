local PlayerList = require("classes/PlayerList")

------------------------------------------- Optimization -------------------------------------------
local string_byte = string.byte
local string_fixEntity = string.fixEntity
local string_sub = string.sub
----------------------------------------------------------------------------------------------------

local onRoomChange = function(self, packet, connection, identifiers)
	self.playerList = PlayerList:new()

	local isPrivate, roomName, roomLanguage = packet:readBool(), packet:readUTF(), packet:readUTF()

	if string_byte(roomName, 2) == 3 then
		--[[@
			@name joinTribeHouse
			@desc Triggered when the account joins a tribe house.
			@param tribeName<string> The name of the tribe.
			@param roomLanguage<string> The language of the tribe.
		]]
		self.event:emit("joinTribeHouse", string_sub(roomName, 3), roomLanguage)
	else
		--[[@
			@name roomChanged
			@desc Triggered when the player changes the room.
			@param roomName<string> The name of the room.
			@param roomLanguage<string> The language of the room.
			@param isPrivateRoom<boolean> Whether the room is only accessible by the account or not.
		]]
		self.event:emit("roomChanged", string_fixEntity(roomName), isPrivate, roomLanguage)
	end
end

return { onRoomChange, 5, 21 }