local enum = require("api/enum")

------------------------------------------- Optimization -------------------------------------------
local enum_setting = enum.setting
local enum_url     = enum.url
local http_request = require("coro-http").request
local string_split = string.split
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
	local _, result = http_request("GET", enum_url.gameSettings)

	if result == "unknown" then return end

	local data = string_split(result, ':', true)
	enum_setting.mainIP = data[1]
	enum_setting.port = string_split(data[2], '-', true)

	enum.setting = enum(enum_setting)
end

return getGameSettings