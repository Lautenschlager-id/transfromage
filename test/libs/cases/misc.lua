local timer = require("timer")

require("wrapper")(function(test, transfromage, client)
	test("server ping", function(expect)
		client:once("serverPing", expect(function(time)
			p("Received event serverPing")
			assert(time)
		end))

		return 0
	end)

	test("account time", function(expect)
		client:once("time", expect(function(time)
			p("Received event time")

			assert(time.day)
			assert(time.hour)
			assert(time.minute)
			assert(time.second)
		end))

		client:sendCommand("time")
	end)

	test("staff list", function(expect)
		local firstCommand = false
		client:on("staffList", expect(function(isModList, namesByCommunity, individualNames)
			p("Received event staffList")

			firstCommand = not firstCommand
			assert_eq(isModList, firstCommand, "isModList")

			assert_eq(type(namesByCommunity), "table", "type(t)")
			assert_eq(type(individualNames), "table", "type(t)")

			local count = 0
			for k, v in next, namesByCommunity do
				count = count + #v
			end

			assert_eq(count, #individualNames, "#t")

			if firstCommand then
				timer.setTimeout(250, client.sendCommand, client, "mapcrew")
			end
		end, 2))

		client:sendCommand("mod")

		return 250
	end)
end)