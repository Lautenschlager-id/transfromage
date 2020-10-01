local Client = require("Client/init")
local ByteArray = require("classes/ByteArray")

local enum = require("api/enum")

-- Optimization --
local string_format = string.format
local enum_validate = enum._validate
------------------

--[[@
	@name playEmoticon
	@desc Plays an emoticon.
	@param emoticon?<enum.emoticon> An enum from @see emoticon. (index or value) @default smiley
]]
Client.playEmoticon = function(self, emoticon)
	emoticon = enum_validate(enum.emoticon, enum.emoticon.smiley, emoticon,
		string_format(enum.error.invalidEnum, "playEmoticon", "emoticon", "emoticon"))
	if not emoticon then return end

	self.bulleConnection:send(enum.identifier.emoticon, ByteArray:new():write8(emoticon))
end