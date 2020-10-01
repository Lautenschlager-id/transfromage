local Client = require("Client/init")
local ByteArray = require("classes/ByteArray")

local enum = require("api/enum")

-- Optimization --
local string_format = string.format
local enum_validate = enum._validate
------------------

--[[@
	@name requestRoomList
	@desc Requests the data of a room mode list.
	@param roomMode?<enum.roomMode> An enum from @see roomMode. (index or value) @default normal
]]
Client.requestRoomList = function(self, roomMode)
	roomMode = enum_validate(enum.roomMode, enum.roomMode.normal, roomMode,
		string_format(enum.error.invalidEnum, "requestRoomList", "roomMode", "roomMode"))
	if not roomMode then return end

	self.mainConnection:send(enum.identifier.roomList, ByteArray:new():write8(roomMode))
end