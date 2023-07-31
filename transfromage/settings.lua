local settings = {
	-- The API update mode
	-- Can be false, "permission" (to ask for permission before updating) and "auto" (to update automatically)
	UPDATE = false,

	DEBUG = true,

	-- Whether logs should have color or not
	COLORED_LOGS = true,
	-- Whether the function error should have color or not
	COLORED_ERRORS = false,

	-- File where all logs are saved, use false to disable it.
	LOG_FILE = "logs.log",
}

if _G.PREPDIR_SETTINGS then
	-- Cannot assign _G.PREPDIR_SETTINGS to settings because there can be default values that aren't assigned by the developer
	for key, value in next, _G.PREPDIR_SETTINGS do
		settings[key] = value
	end
end

return settings