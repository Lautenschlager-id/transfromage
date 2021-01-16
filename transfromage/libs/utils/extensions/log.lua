------------------------------------------- Optimization -------------------------------------------
local colorThemes   = require("utils").theme
local error         = error
local io_open       = io.open
local print         = print
local string_format = string.format
local string_gsub   = string.gsub
local tostring      = tostring
----------------------------------------------------------------------------------------------------

local colorFormat = "\27[%sm%s\27[0m"
local colorCodes = {
	error     = colorThemes.err,
	failure   = colorThemes.failure,
	highlight = colorThemes.highlight,
	info      = colorThemes.userdata,
	success   = colorThemes.string
}

@#IF COLORED_LOGS
local formatColor = function(raw, code, text)
	return (colorCodes[code] and string_format(colorFormat, colorCodes[code], text) or raw)
end
@#ELSE
local formatColor = function(raw, code, text)
	return colorCodes[code] and text or raw
end
@#ENDIF

--[[@
	@name os.log
	@desc Sends a log message with colors to the prompt of command.
	@desc Color format is given as `↑name↓text↑`, as in `↑error↓[FAIL]↑`.
	@desc Available code names: `error`, `failure`, `highlight`, `info`, `success`.
	@desc This function is also available for the `error` function. Ex: `error("↑error↓Bug↑")`
	@param str<string> The message to be sent. It may included color formats.
	@param returnValue?<boolean> Whether the formated message has to be returned. If not, it'll be sent to the prompt automatically. @default false
	@returns nil,string The formated message, depending on @returnValue.
]]
@#IF LOG_FILE & LOG_FILE ~= ''
local logFile = io_open(_G.PREPDIR_SETTINGS.LOG_FILE, 'a')
@#ENDIF
os.log = function(log, ...)
	log = string_format(tostring(log), ...)

	coloredLog = string_gsub(log, "(↑(.-)↓(.-)↑)", formatColor)

	print(coloredLog)

	@#IF LOG_FILE & LOG_FILE ~= ''
	logFile:write(string_gsub(log, "↑.-↓(.-)↑", "%1"))
	logFile:flush()
	@#ENDIF
end

@#IF COLORED_ERRORS
_G.error = function(message, level, ...)
	os.log(message, ...) -- Colored message
	return error('^', level)
end
@#ELSE
_G.error = function(message, level, ...)
	return error(string_format(string_gsub(tostring(message), "↑.-↓(.-)↑", "%1"), ...), level)
end
@#ENDIF