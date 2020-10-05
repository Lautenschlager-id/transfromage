local Client = require("api/Client/init")
local ByteArray = require("classes/ByteArray")

------------------------------------------- Optimization -------------------------------------------
local string_gsub = string.gsub
----------------------------------------------------------------------------------------------------

local identifier = require("api/enum").identifier.cafeNewTopic

--[[@
	@name createCafeTopic
	@desc Creates a Café topic.
	@desc /!\ The method does not handle the Café's cooldown system.
	@param title<string> The title of the topic.
	@param message<string> The content of the topic.
]]
Client.createCafeTopic = function(self, title, message)
	message = string_gsub(message, "\r\n", '\r')
	self.mainConnection:send(identifier, ByteArray:new():writeUTF(title):writeUTF(message))
end