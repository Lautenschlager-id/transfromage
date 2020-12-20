return {
	-- The API update mode
	-- Can be nil, "permission" (to ask for permission before updating) and "auto" (to update automatically)
	UPDATE = nil,

	-- Whether logs should have color or not
	COLORED_LOGS = true,
	-- Whether the function error should have color or not
	COLORED_ERRORS = false,

	-- File where all logs are saved, use nil to disable it.
	LOG_FILE = "logs.log",
}