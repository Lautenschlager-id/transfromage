return {
	-- The API update mode
	-- Can be nil, "permission" (to ask for permission before updating) and "auto" (to update automatically)
	update = nil,

	-- Whether logs should have color or not
	coloredLogs = true,
	-- Whether the function error should have color or not
	coloredErrors = false,

	-- File where all logs are saved, use nil to disable it.
	logFile = "logs.log",
}