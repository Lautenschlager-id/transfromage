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
	timeout = "↑error↓[SOCKET]↑ Timed out.",
	invalidToken = "↑error↓[API ENDPOINT]↑ ↑highlight↓TFMID↑ or ↑highlight↓TOKEN↑ value is \z
		invalid.\n\t%s",
	authEndpointFailure = "↑error↓[API ENDPOINT]↑ Impossible to get the keys.\n\tError: %s",
	authEndpointInternal = "↑error↓[API ENDPOINT]↑ An internal error occurred in the API endpoint.\z
		\n\t'%s'%s",
	gameMaintenace = ": The game may be under maintenance.",
	failLogin = "↑error↓[LOGIN]↑ Impossible to log in. Try again later."
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