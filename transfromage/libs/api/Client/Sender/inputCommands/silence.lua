local Client = require("api/Client/init")

local ByteArray = require("classes/ByteArray")

local enum = require("api/enum")

------------------------------------------- Optimization -------------------------------------------
local string_format     = string.format
local enum_error        = enum.error
local enum_validate     = enum._validate
local enum_whisperState = enum.whisperState
----------------------------------------------------------------------------------------------------

--[[@
	@name changeWhisperState
	@desc Sets the account's whisper state.
	@param message?<string> The /silence message. @default ''
	@param state?<enum.whisperState> An enum from @see whisperState. (index or value) @default enabled
]]
Client.changeWhisperState = function(self, message, state)
	state = enum_validate(enum_whisperState, enum_whisperState.enabled, state,
		string_format(enum_error.invalidEnum, "changeWhisperState", "state", "whisperState"))
	if not state then return end

	self:sendTribulle(ByteArray:new():write16(60):write32(1):write8(state):writeUTF(message or ''))
end