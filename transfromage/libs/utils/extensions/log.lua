@#DEFINE SAVE_LOG LOG_FILE & LOG_FILE != ''

------------------------------------------- Optimization -------------------------------------------
local colorThemes   = require("utils").theme
local error         = error
local io_open       = io.open
local print         = print
local string_format = string.format
local string_gsub   = string.gsub
local tostring      = tostring
----------------------------------------------------------------------------------------------------

@#IF SAVE_LOG
local saveLog
do
	local logFile = io_open(_G.PREPDIR_SETTINGS.LOG_FILE, 'a')

	saveLog = function(log)
		logFile:write(log)
		logFile:flush()
	end
end
@#ENDIF

@#IF COLORED_LOGS
local colorFormat = "\27[%sm%s\27[0m"

local colorCodes = {
	error     = colorThemes.err,
	failure   = colorThemes.failure,
	highlight = colorThemes.highlight,
	info      = colorThemes.userdata,
	success   = colorThemes.string
}

local formatColor = function(raw, code, text)
	return (colorCodes[code] and string_format(colorFormat, colorCodes[code], text) or raw)
end

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
os.log = function(log, ...)
	log = string_format(tostring(log), ...)

	local coloredLog = string_gsub(log, "(↑(.-)↓(.-)↑)", formatColor)
	print(coloredLog)
end

_G.error = function(message, level, ...)
	@#IF SAVE_LOG
	saveLog(message)
	@#ENDIF

	os.log(message, ...) -- Colored message
	return error('^', level)
end
@#ELSE
_G.error = function(message, level, ...)
	message = string_gsub(tostring(message), "↑.-↓(.-)↑", "%1")
	message = string_format(message, ...)

	@#IF SAVE_LOG
	saveLog(message)
	@#ENDIF

	return error(message, level)
end
@#ENDIF