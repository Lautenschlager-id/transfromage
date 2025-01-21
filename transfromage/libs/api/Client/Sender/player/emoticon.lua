local Client = require("api/Client/init")

local ByteArray = require("classes/ByteArray")

local enum = require("api/enum")

------------------------------------------- Optimization -------------------------------------------
local string_format = string.format
local enum_emoticon = enum.emoticon
local enum_error    = enum.error
local enum_validate = enum._validate
----------------------------------------------------------------------------------------------------

local identifier = require("api/enum").identifier.emoticon

--[[@
	@name playEmoticon
	@desc Plays an emoticon.
	@param emoticon?<enum.emoticon> An enum from @see emoticon. (index or value) @default smiley
]]
Client.playEmoticon = function(self, emoticon)
	emoticon = enum_validate(enum_emoticon, enum_emoticon.smiley, emoticon,
		string_format(enum_error.invalidEnum, "playEmoticon", "emoticon", "emoticon"))
	if not emoticon then return end

	self.bulleConnection:send(identifier, ByteArray:new():write16(emoticon))
end
