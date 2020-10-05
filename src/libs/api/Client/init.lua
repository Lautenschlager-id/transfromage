local EventEmitter = require("core").Emitter

local Connection = require("api/Connection")

local PlayerList = require("api/Entities/player/PlayerList")
local Cafe = require("api/Entities/cafe/Cafe")

local enum = require("api/enum")

------------------------------------------- Optimization -------------------------------------------

----------------------------------------------------------------------------------------------------

local Client = table.setNewClass()

--[[@
	@name new
	@desc Creates a new instance of Client. Alias: `client()`.
	@desc The function @see start is automatically called if you pass its arguments.
	@param tfmId?<string,int> The Transformice ID of your account. If you don't know how to obtain it, go to the room **#bolodefchoco0id** and check your chat.
	@param token?<string> The API Endpoint token to get access to the authentication keys.
	@param hasSpecialRole?<boolean> Whether the bot has the game's special role bot or not.
	@param updateSettings?<boolean> Whether the IP/Port settings should be updated by the endpoint or not when the @hasSpecialRole is true.
	@returns client The new Client object.
	@struct {
		playerName = "", -- The nickname of the account that is attached to this instance, if there's any.
		language = 0, -- The language enum where the object is set to perform the login. Default value is EN.
		main = { }, -- The main connection object, handles the game server.
		bulle = { }, -- The bulle connection object, handles the room server.
		event = { }, -- The event emitter object, used to trigger events.
		cafe = { }, -- The cached Café structure. (topics and messages)
		playerList = { }, -- The room players data.
		-- The fields below must not be edited, since they are used internally in the api.
		_mainLoop = { }, -- (userdata) A timer that retrieves the packets received from the game server.
		_bulleLoop = { }, -- (userdata) A timer that retrieves the packets received from the room server.
		_receivedAuthkey = 0, -- Authorization key, used to connect the account.
		_gameVersion = 0, -- The game version, used to connect the account.
		_gameConnectionKey = "", -- The game connection key, used to connect the account.
		_gameIdentificationKeys = { }, -- The game identification keys, used to connect the account.
		_gameMsgKeys = { }, -- The game message keys, used to connect the account.
		_connectionTime = 0, -- The timestamp of when the player logged in. It will be 0 if the account is not connected.
		_isConnected = false, -- Whether the player is connected or not.
		_hbTimer = { }, -- (userdata) A timer that sends heartbeats to the server.
		_whoFingerprint = 0, -- A fingerprint to identify the chat where the command /who was used.
		_whoList = { }, -- A list of chat names associated to their own fingerprints.
		_processXml = false, -- Whether the event "newGame" should decode the XML packet or not. (Set as false to save process)
		_cafeCachedMessages = { }, -- A set of message IDs to cache the read messages at the Café.
		_handlePlayers = false, -- Whether the player-related events should be handled or not. (Set as false to save process)
		_encode = { }, -- The encode object, used to encryption.
		_hasSpecialRole = false, -- Whether the bot has the game's special role bot or not.
		_updateSettings = false -- Whether the IP/Port settings should be updated by the endpoint or not when the @hasSpecialRole is true.
	}
]]
Client.new = function(self, tfmId, token, isOfficialBot, endpointUpdate)
	local eventEmitter = EventEmitter:new()

	local data = setmetatable({
		playerName = nil,
		language = enum.language.en,
		_isConnected = false,

		_isOfficialBot = isOfficialBot,
		_endpointUpdate = endpointUpdate,

		mainConnection = Connection:new("main", eventEmitter),
		bulleConnection = nil,
		_heartbeatTimer = nil,

		_loginTime = 0,

		event = eventEmitter,

		cafe = Cafe:new(),
		playerList = PlayerList:new(),

		_decryptXML = false,
		_handlePlayers = false,

		_whoList = { },
		_whoFingerprint = 0,

		_authenticationKey = nil,
		_gameConnectionKey = nil,
		_identificationKeys = { },
		_messageKeys = { }
	}, self)

	if tfmId and token then
		data:start(tfmId, token)
	end

	return data
end

return Client