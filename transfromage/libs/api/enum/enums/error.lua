--[[@
	@name error
	@desc The API error messages.
	@type string
]]
local error = {
	invalidEnum = "↑failure↓[%s]↑ ↑highlight↓%s↑ must be a valid ↑highlight↓%s↑ enumeration.",
	translationFailure = "↑failure↓[TRANSLATION]↑ Language ↑highlight↓%s↑ could not be \z
		downloaded. File not found in Transformice's archives.",
	timeout = "↑error↓[SOCKET]↑ Timed out.",
	authEndpoint = "↑error↓[API ENDPOINT]↑ %s : %s",
	failLogin = "↑error↓[LOGIN]↑ Impossible to log in. Try again later.",
	enumConflict = "↑failure↓[ENUM]↑ Enumeration conflict in ↑highlight↓%s↑ and ↑highlight↓%s↑",
	enumOverwrite = "↑failure↓[ENUM]↑ Can not overwrite enumerations."
}

--[[@
	@name errorLevel
	@desc The API error levels.
	@type int
]]
local errorLevel = {
	low  = -2,
	high = -1
}

return {
	error = error,
	errorLevel = errorLevel
}