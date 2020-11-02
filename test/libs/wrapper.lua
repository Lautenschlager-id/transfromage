-- Based on luvit/tap
local timer = require("timer")
local colorize = require("pretty-print").colorize
local transfromage, client
local filePrefix
local tests = { }

local totalTime = 0

local timerResumeCoro = { }

local resumeCoro = function(coro)
	if timerResumeCoro[1] then
		timer.clearTimeout(timerResumeCoro[1])
	end
	assert(coroutine.resume(coro))
end

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
							resumeCoro(coro)
						end
					else
						err = ret
					end
					collectgarbage()
					return ret
				end
			end

			timerResumeCoro[1] = timer.setTimeout(30000, resumeCoro, coro)

			time = os.clock()

			local ignoreTime = test.fn(expect)
			if expected ~= 0 then
				coroutine.yield()
			end

			if ignoreTime == 0 then
				time = '?'
			else
				time = os.clock() - time
				time = time + ((ignoreTime or 0) / 1000)
			end

			collectgarbage()

			if err then
				error(err .. "\nDebug Traceback: " .. debug.traceback())
			end

			if expected > 0 then
				error("Missing " .. expected .. " expected call(s)")
			elseif expected < 0 then
				error("Found " .. expected .. " unexpected call(s)")
			end
		end, debug.traceback)

		if pass then
			passed = passed + 1
			totalTime = totalTime + time
			print("\t# Test finished with success (" .. time .. "s): " .. colorize("highlight", test.name))
		else
			print(colorize("err", err))
			print("\t# Test finished with errors: (" .. time .. "s): " .. colorize("failure", test.name))
		end
	end

	local failed = #tests - passed
	if failed == 0 then
		print("\t# All tests passed! (" .. totalTime .. "s)")
	else
		print("\t# " .. failed .. " failed test(s)")
	end

	p("Disconnecting")
	client:disconnect()

	timer.setTimeout(1000, os.exit, -failed)
end)

local test = function(name, fn)
	if not fn then return end
	tests[#tests + 1] = {
		name = name,
		fn = fn
	}
end

return function(suite, _client)
	local type = type(suite)

	if type == "function" then
		suite(test, transfromage, client)
	elseif type == "table" then
		-- Receives from test.lua
		transfromage, client = suite, _client
	elseif type == "string" then
		-- File name from test.lua
		filePrefix = suite
	else
		-- Executes all tests
		run()
	end
end