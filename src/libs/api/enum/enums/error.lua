local enum = require("enum/init")

--[[@
	@name error
	@desc The API error messages.
	@type string
]]
enum.error = enum {
	invalidEnum = "↑failure↓[%s]↑ ↑highlight↓%s↑ must be a valid ↑highlight↓%s↑ enumeration.",
	translationFailure = "↑failure↓[TRANSLATION]↑ Language ↑highlight↓%s↑ could not be \z
		downloaded. File not found in Transformice's archives.",
	timeout = "↑error↓[SOCKET]↑ Timed out."
}

--[[@
	@name errorLevel
	@desc The API error levels.
	@type int
]]
enum.errorLevel = enum {
	low  = -2,
	high = -1
}