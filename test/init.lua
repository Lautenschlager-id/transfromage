-- Based on luvit/tap

assert(args[2], "Missing PlayerName")
assert(args[3], "Missing Password")
assert(args[4], "Missing PlayerID")
assert(args[5], "Missing Token")

local testWrapper = require("wrapper")
local transfromage = require("transfromage")

local client = transfromage.Client()
client:setLanguage(transfromage.enum.language.br)

do
	local client_on = client.on
	client.on = function(self, eventName, fn)
		-- Deletes listener when it is specific again
		if self.event.handlers and self.event.handlers[eventName] then
			self.event.handlers[eventName] = nil
		end

		return client_on(self, eventName, fn)
	end
end

local testCases = {
	--[[ Make sure all utils are working ]]--
	-- "utils/extensions.lua",
	-- "utils/bit64.lua",
	-- "utils/encoding.lua",

	--[[ Important parts of the system ]]--
	--"login.lua",
	--"message.lua",
	--[BROKEN] "room.lua",


	--"misc.lua"
}

local loadTests = function()
	testWrapper(transfromage, client)

	for name = 1, #testCases do
		name = testCases[name]

		testWrapper(name)
		require("cases/" .. name)
	end
end
loadTests()

-- Run the tests
testWrapper(true)