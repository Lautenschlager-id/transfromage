local Client = require("api/Client/init")

local enum = require("api/enum")

------------------------------------------- Optimization -------------------------------------------
local string_format = string.format
local enum_error    = enum.error
local enum_language = enum.language
local enum_validate = enum._validate
----------------------------------------------------------------------------------------------------

--[[@
	@name setLanguage
	@desc Sets the language the bot will connect to.
	@desc /!\ This method must be called before the @see start.
	@param language?<enum.language> An enum from @see language. (index or value) @default EN
]]
Client.setLanguage = function(self, language)
	language = enum_validate(enum_language, enum_language.en, language,
		string_format(enum_error.invalidEnum, "setCommunity", "language", "language"))
	if not language then return end

	self.language = language
end