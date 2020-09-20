-- Optimization --
local error = error
local print = print
local string_format = string.format
local string_gsub = string.gsub
local tostring = tostring
------------------

local colorFormat = "\27[%sm%s\27[0m"
local colorCodes = { -- Scrapped from luvit.utils.theme
	error = "1;31",
	failure = "1;33;41",
	highlight = "1;36;44",
	info = "1;36",
	success = "0;32"
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
os.log = function(str, returnValue)
	str = string_gsub(tostring(str), "(↑(.-)↓(.-)↑)", formatColor)

	if returnValue then
		return str
	end

	print(str)
end

_G.error = function(message, level)
	os.log(message) -- Clean message
	return error('^', level)
end