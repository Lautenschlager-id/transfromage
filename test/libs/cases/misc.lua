require("wrapper")(function(test, transfromage, client)
	test("server ping", function(expect)
		client:once("serverPing", expect(function(time)
			assert(time)
		end))

		return 0
	end)

	test("account time", function(expect)
		client:once("time", expect(function(time)
			assert(time.day)
			assert(time.hour)
			assert(time.minute)
			assert(time.second)
		end))

		client:sendCommand("time")
	end)

	test("staff list", TO_DO)
end)