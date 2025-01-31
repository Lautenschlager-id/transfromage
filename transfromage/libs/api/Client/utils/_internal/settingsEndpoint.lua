local enum = require("api/enum")

------------------------------------------- Optimization -------------------------------------------
local enum_error      = enum.error
local enum_errorLevel = enum.errorLevel
local enum_setting    = enum.setting
local enum_url        = enum.url
local http_request    = require("coro-http").request
local json_decode     = require("json").decode
local pcall           = pcall
local string_split    = string.split
local tostring        = tostring
----------------------------------------------------------------------------------------------------

--[[@
	@name getKeys
	@desc Gets the connection keys and settings in the API endpoint.<br>
	@desc If @self.hasSpecialRole is true, the endpoint is only going to be requested if updateSettings is also true, and only the IP/Ports are going to be updated.
	@param self<client> A Client object.
	@param tfmId<string,int> The developer's transformice id.
	@param token<string> The developer's token.
]]
local getGameSettings = function(self)
	local success, _, result = pcall(http_request, "GET", enum_url.gameSettings)
	result = success and json_decode(tostring(result))
	if not result then return end

	if not result.success then
		if result.error == "MAINTENANCE" then
			return error(enum_error.authEndpoint, enum_errorLevel.high, tostring(result.error),
				tostring(result.description))
		end

		return -- log?
	end

	enum_setting.mainIP = result.server.ip
	enum_setting.port = result.server.ports

	enum.setting = enum(enum_setting)
end

return getGameSettings