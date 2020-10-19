-- Based on luvit/tap

assert(args[2], "Missing PlayerName")
assert(args[3], "Missing Password")
assert(args[4], "Missing PlayerID")
assert(args[5], "Missing Token")

local testWrapper = require("wrapper")
local transfromage = require("transfromage")
local fs = require("fs")

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

local loadTests = function()
	testWrapper(transfromage, client)

	local req = fs.scandirSync("test/libs/cases/")

	local name = "login.lua"
	while true do
		repeat
			if not name then
				name = req()

				if not name then return end
				if name == "login.lua" then
					name = nil
					break
				end
				if type(name) == "table" then
					name = name.name
				end
			end

			testWrapper(name)
			require("cases/" .. name)
			name = nil
		until false
	end
end
loadTests()

-- Run the tests
testWrapper(true)