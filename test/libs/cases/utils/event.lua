local timer = require("timer")

require("wrapper")(function(test, transfromage, client)
	test("event calling [on]", function(expect)
		client:on("__TESTON", function(a, b, c, d)
			p("Received event __TEST [on]")

			assert(a)
			assert(b)
			assert(c)
			assert_eq(d, nil, "nil")
		end)

		client:emit("__TESTON", 1, 2, 3)
		client:emit("__TESTON", 1, 2, 3)
		client:emit("__TESTON", 1, 2, 3)
	end)

	test("event calling [once]", function(expect)
		local calls = 0
		client:once("__TESTONCE", function(a, b, c, d)
			p("Received event __TEST [once]")

			calls = calls + 1
			assert_eq(calls, 1, '1')

			assert(a)
			assert(b)
			assert(c)
			assert_eq(d, nil, "nil")
		end)

		client:emit("__TESTONCE", 1, 2, 3)
		client:emit("__TESTONCE", 1, 2, 3)
		client:emit("__TESTONCE", 1, 2, 3)
	end)

	test("waiting for event", function(expect)
		local maxCalls = 6

		client:on("__WAITTEST", expect(function(a, b, c)
			p("Received event __WAITTEST", a)
		end, maxCalls + 1), true)

		local calls = 0
		local t
		t = timer.setInterval(250, function()
			calls = calls + 1
			client:emit("__WAITTEST", calls, calls, calls)

			if calls == maxCalls + 1 then
				timer.clearInterval(t)
			end
		end)

		p("Waiting for __WAITTEST(", maxCalls, ")")
		local success, a, b, c = client:waitFor("__WAITTEST", 1800, function(a, b, c)
			return a == maxCalls and b == maxCalls and c == maxCalls
		end)

		assert(success)
		assert_eq(a, maxCalls, maxCalls)
		assert_eq(b, maxCalls, maxCalls)
		assert_eq(c, maxCalls, maxCalls)

		return -(250 * maxCalls)
	end)

	test("timeout waitfor event", function(expect)
		local success, a, b, c = client:waitFor("__WAITTEST", 1000, function(a, b, c)
			return a == 1 and b == 1 and c == 1
		end)

		assert(not success)
		assert_eq(a, nil, "nil")
		assert_eq(b, nil, "nil")
		assert_eq(c, nil, "nil")

		return -1000
	end)
end)