local timer = require("timer")

require("wrapper")(function(test, transfromage, client, clientId)
	clientId = clientId * 2

	test("join tribe house", function(expect)
		client:on("joinTribeHouse", expect(function(room)
			p("Received event joinTribeHouse")

			assert_eq(tostring(room), "Room", "str(room)")
			assert(room.isTribeHouse)
			assert(room.name)
			assert(room.language)
		end))

		p("Joining tribe house", args[clientId])
		timer.setTimeout(3500, client.joinTribeHouse, client)

		return -3500
	end)

	test("join room", function(expect)
		client:on("roomChanged", expect(function(room)
			p("Received event roomChanged")

			assert_eq(tostring(room), "Room", "str(room)")
			assert(not room.isTribeHouse)

			assert(room.name, client.language .. "-#bolodefchoco", "roomName")

			assert_eq(type(room.isOfficial), "boolean", "type(isOfficial)")
			assert_eq(room.language, client.language, "roomLanguage")
		end))

		p("Joining room", args[clientId])
		timer.setTimeout(5000, client.enterRoom, client, "#bolodefchoco")

		return -5000
	end)
end)