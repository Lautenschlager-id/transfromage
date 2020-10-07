local Client = require("api/Client/init")

local ByteArray = require("classes/ByteArray")

local enum = require("api/enum")

------------------------------------------- Optimization -------------------------------------------
local string_format = string.format
local enum_error    = enum.error
local enum_roomMode = enum.roomMode
local enum_validate = enum._validate
----------------------------------------------------------------------------------------------------

local identifier = require("api/enum").identifier.roomList

--[[@
	@name requestRoomList
	@desc Requests the data of a room mode list.
	@param roomMode?<enum.roomMode> An enum from @see roomMode. (index or value) @default normal
]]
Client.requestRoomList = function(self, roomMode)
	roomMode = enum_validate(enum_roomMode, enum_roomMode.normal, roomMode,
		string_format(enum_error.invalidEnum, "requestRoomList", "roomMode", "roomMode"))
	if not roomMode then return end

	self.mainConnection:send(identifier, ByteArray:new():write8(roomMode))
end