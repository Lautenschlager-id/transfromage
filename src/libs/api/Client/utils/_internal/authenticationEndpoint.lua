local enum = require("api/enum")

local http_request = require("coro-http").request
local json_decode = require("json").decode

------------------------------------------- Optimization -------------------------------------------
local string_format = string.format
local error = error
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
	local _, result = http_request("GET", string_format(enum.url.authKeys, tfmID, token))

	local rawresult = result
	result = json_decode(result)

	if not result then
		return error("↑error↓[API ENDPOINT]↑ ↑highlight↓TFMID↑ or ↑highlight↓TOKEN↑ value is \z
			invalid.\n\t" .. tostring(rawresult), enum.errorLevel.high)
	end

	if not result.success then
		return not self._isOfficialBot and error("↑error↓[API ENDPOINT]↑ Impossible to get the \z
			keys.\n\tError: " .. tostring(result.error), enum.errorLevel.high)
	end

	if result.internal_error then
		return not self._isOfficialBot and error(string_format("↑error↓[API ENDPOINT]↑ An \z
			internal error occurred in the API endpoint.\n\t'%s'%s", result.internal_error_step,
			(result.internal_error_step == 2 and ": The game may be in maintenance." or '')
		), enum.errorLevel.high)
	end

	enum.setting.mainIP = result.ip

	if not self._isOfficialBot then
		enum.setting.gameVersion = result.version

		self._authenticationKey = result.auth_key
		self._gameConnectionKey = result.connection_key
		self._identificationKeys = result.identification_keys
		self._messageKeys = result.msg_keys
	end

	enum.setting = enum(enum.setting)
end

return getAuthenticationKeys