local timer = require("timer")

require("wrapper")(function(test, transfromage, client)
	-- if not client.room.isTribeHouse then
	test("join tribe house", function(expect)
		client:on("joinTribeHouse", expect(function(roomName, roomLanguage)
			p("Received event joinTribeHouse")

			assert(roomName)
			assert(roomLanguage)
		end))

		p("Joining tribe house")
		timer.setTimeout(3500, client.joinTribeHouse, client)

		return -3500
	end)
	--end

	test("execute lua", function(expect)
		local trigger = 0
		client:on("lua", expect(function(log)
			p("Received event lua")

			trigger = trigger + 10
			if trigger == 110 then
				assert(string.find(log, "loaded"))
			else
				assert((string.find(log, "%D" .. trigger)))
			end
		end, 11))

		timer.setTimeout(5000, client.loadLua, client, [[
for i = 1, 10 do
	print(i * 10)
end
			]])

		return -5000
	end)
end)