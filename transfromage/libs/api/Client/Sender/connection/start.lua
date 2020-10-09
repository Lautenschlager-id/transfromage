local Client = require("api/Client/init")

local getAuthenticationKeys = require("api/Client/utils/_internal/authenticationEndpoint")
local killOnSigterm = require("api/Client/utils/_internal/sigterm")
local onSocketConnection = require("api/Client/Listener/_internal/socketConnection")

------------------------------------------- Optimization -------------------------------------------
local coroutine_makef = coroutine.makef
local enum_setting    = require("api/enum").setting
----------------------------------------------------------------------------------------------------

--[[@
	@name start
	@desc Initializes the API connection with the authentication keys. It must be the first method of the API to be called.
	@param tfmId<string,int> The Transformice ID of your account. If you don't know how to obtain it, go to the room **#bolodefchoco0id** and check your chat.
	@param token<string> The API Endpoint token to get access to the authentication keys.
]]
Client.start = coroutine_makef(function(self, tfmID, token)
	-- Resets everything
	self:disconnect()
	self._isConnected = false

	-- Non-official bot proccess
	if not self._isOfficialBot or self._endpointUpdate then
		getAuthenticationKeys(self, tfmID, token)
	end

	self.mainConnection:connect(enum_setting.mainIP)

	self.mainConnection._client = self
	self.mainConnection.event:once("_socketConnection", onSocketConnection)

	-- Triggered when the developer uses CTRL+C to leave the command prompt.
	killOnSigterm(self)
end)