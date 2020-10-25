require("wrapper")(function(test, transfromage, client)
	test("server ping", function(expect)
		client:once("serverPing", expect(function(time)
			assert(time)
			return true
		end))

		return 0
	end)

	test("account time", function(expect)
		client:once("time", expect(function(time)
			assert(time.day)
			assert(time.hour)
			assert(time.minute)
			assert(time.second)

			return true
		end))

		client:sendCommand("time")
	end)
end)