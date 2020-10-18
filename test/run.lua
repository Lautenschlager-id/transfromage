-- Based on luvit/tap

local testWrapper = require("./test/wrapper")
local transfromage = require("transfromage")
local fs = require("fs")

local client = transfromage.Client()
client:setLanguage(transfromage.enum.language.br)

do
	local assert = assert
	_G.assert = function(condition, message, ...)
		assert(condition, message and string.format(message, ...) or nil)
	end

	local client_on = client.on
	client.on = function(self, eventName, fn)
		-- Deletes listener when it is specific again
		if self.event.handlers and self.event.handlers[eventName] then
			self.event.handlers[eventName] = nil
		end

		return client_on(self, eventName, fn)
	end
end

testWrapper(transfromage, client)

local req = fs.scandirSync("test/cases")

local name = "login.lua"
while true do
	if not name then
		name = req()

		if not name or name == "login.lua" then break end
		if type(name) == "table" then
			name = name.name
		end
	end

	local fileName = string.match(name, "^(.*).lua$")
	if fileName then
		testWrapper(fileName)
		require("test/cases/" .. fileName)
	end
	name = nil
end

-- Run the tests
testWrapper(true)