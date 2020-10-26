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

local _assert = function(condition, message, x, y, varname)
	local tX, tY = type(x), type(y)
	x, y = tostring(x), tostring(y)
	x, y = string.sub(x, 1, 10), string.sub(y, 1, 10)

	assert(condition, string.format(message, varname, x, tX, y, tY))
end

_G.assert_eq = function(x, y, varname)
	_assert(x == y, "(%s)'%s'<%s> is not equals to '%s'<%s>", x, y, varname)
end

_G.assert_neq = function(x, y, varname)
	_assert(x ~= y, "(%s)'%s'<%s> is equals to '%s'<%s>", x, y, varname)
end

local testCases = {
	{ "IGNORE+TODO", "utils/extensions.lua" },
	{ "IGNORE+TODO", "utils/bit64.lua" },
	{ "IGNORE+TODO", "utils/encoding.lua" },

	{ "IGNORE+TODO", "packetControl.lua" },

	{ "IGNORE", "translation.lua" },

	{ "IGNORE", "important/login.lua" },
	{ "IGNORE", "important/message.lua" },
	{ "BROKEN", "important/room.lua" },

	{ "IGNORE", "misc.lua" },
}

local loadTests = function()
	testWrapper(transfromage, client)

	for name = 1, #testCases do
		name = testCases[name]

		if string.find(name[1], "CHECK") then
			testWrapper(name[2])
			require("cases/" .. name[2])
		end
	end
end
loadTests()

-- Run the tests
testWrapper(true)