local Client = require("api/Client/init")

local ByteArray = require("classes/ByteArray")

local enum = require("api/enum")

------------------------------------------- Optimization -------------------------------------------
local string_format = string.format
local enum_emote    = enum.emote
local enum_error    = enum.error
local enum_validate = enum._validate
----------------------------------------------------------------------------------------------------

local identifier = require("api/enum").identifier.emote

--[[@
	@name playEmote
	@desc Plays an emote.
	@param emote?<enum.emote> An enum from @see emote. (index or value) @default dance
	@param flag?<string> The country code of the flag when @emote is flag.
]]
Client.playEmote = function(self, emote, flag)
	emote = enum_validate(enum_emote, enum_emote.dance, emote,
		string_format(enum_error.invalidEnum, "playEmote", "emote", "emote"))
	if not emote then return end

	local packet = ByteArray:new():write8(emote):write32(0)
	if emote == enum_emote.flag then
		packet = packet:writeUTF(flag)
	end

	self.bulleConnection:send(identifier, packet)
end