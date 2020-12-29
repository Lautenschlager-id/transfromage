local enum = require("api/enum")

------------------------------------------- Optimization -------------------------------------------
local enum_error      = enum.error
local enum_errorLevel = enum.errorLevel
local enum_setting    = enum.setting
local enum_url        = enum.url
local http_request    = require("coro-http").request
local json_decode     = require("json").decode
local error           = error
local string_format   = string.format
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
local getAuthenticationKeys = function(self, tfmID, token)
	local _, result = http_request("GET", string_format(enum_url.authKeys, tfmID, token))
	result = json_decode(result)

	if not result.success then
		return error(enum_error.authEndpoint, enum_errorLevel.high, tostring(result.error),
			tostring(result.description))
	end

	enum_setting.mainIP = result.server.ip
	enum_setting.port = result.server.ports
	enum_setting.gameVersion = result.server.version

	self._connectionAuthenticationKey = result.keys.auth
	self._connectionKey = result.keys.connection
	self._identificationKeys = result.keys.identification
	self._messageKeys = result.keys.msg

	enum.setting = enum(enum_setting)
end

return getAuthenticationKeys