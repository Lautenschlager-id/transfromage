-- Based on luvit/tap
local timer = require("timer")
local colorize = require("pretty-print").colorize
local transfromage, client
local filePrefix
local tests = { }

local run = coroutine.wrap(function()
	if #tests == 0 then
		error("No tests specified!")
	end

	local coro = coroutine.running()
	local passed = 0

	for t = 1, #tests do
		local test = tests[t]
		local time

		print("\t# Starting test: " .. colorize("highlight", test.name))
		local pass, err = xpcall(function()

			local expected = 0

			local err
			local expect = function(fn, totalCalls)
				expected = expected + (totalCalls or 1)
				return function(...)
					local success, ret = pcall(fn, ...)
					if success then
						expected = expected - 1
						if expected <= 0 then
							assert(coroutine.resume(coro))
						end
					else
						err = ret
					end
					collectgarbage()
					return ret
				end
			end

			timer.setTimeout(30000, assert, coroutine.resume, coro)

			time = os.clock()
			coroutine.yield(test.fn(expect))
			time = os.clock() - time
			collectgarbage()

			if err then
				error(err)
			end

			if expected > 0 then
				error("Missing " .. expected .. " expected call(s)")
			elseif expected < 0 then
				error("Found " .. expected .. " unexpected call(s)")
			end
		end, debug.traceback)

		if pass then
			passed = passed + 1
			print("\t# Test finished with success (" .. time .. "ms): " .. colorize("highlight", test.name))
		else
			print(colorize("err", err))
			print("\t# Test finished with errors: (" .. time .. "ms): " .. colorize("failure", test.name))
		end
	end

	local failed = #tests - passed
	if failed == 0 then
		print("\t# All tests passed!")
	else
		print("\t#" .. failed .. " failed test(s)")
	end

	client:disconnect()

	timer.setTimeout(1000, os.exit, -failed)
end)

local test = function(name, fn)
	tests[#tests + 1] = {
		name = name,
		fn = fn
	}
end

return function(suite, _client)
	if type(suite) == "function" then
		suite(test, transfromage, client)
	elseif type(suite) == "table" then
		-- Receives from test.lua
		transfromage, client = suite, _client
	elseif type(suite) == "string" then
		-- File name from test.lua
		filePrefix = suite
	else
		-- Executes all tests
		run()
	end
end