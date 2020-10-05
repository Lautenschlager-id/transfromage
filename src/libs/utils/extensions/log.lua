local APISettings = require("src/settings")

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

local formatColor
if APISettings.coloredLogs then
	formatColor = function(raw, code, text)
		return (colorCodes[code] and string_format(colorFormat, colorCodes[code], text) or raw)
	end
else
	formatColor = function(raw, code, text)
		return colorCodes[code] and text or raw
	end
end

local logFile, writeLogs = APISettings.logFile
if logFile and logFile ~= '' then
	logFile = io_open(logFile, 'a')

	writeLogs = function(rawLog)
		logFile:write(rawLog)
		logFile:flush()
	end
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
os.log = function(log, returnValue)
	log = tostring(log)

	coloredLog = string_gsub(log, "(↑(.-)↓(.-)↑)", formatColor)

	if returnValue then
		return coloredLog
	end

	print(coloredLog)

	if writeLogs then
		local colorlessLog = string_gsub(log, "↑.-↓(.-)↑", "%1")
		writeLogs(colorlessLog)
	end
end

_G.error = function(message, level)
	os.log(message) -- Colored message
	return error('^', level)
end