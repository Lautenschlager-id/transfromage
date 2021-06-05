local timer = require("timer")

require("wrapper")(function(test, transfromage, client, clientId)
	clientId = clientId * 2

	test("join tribe house", function(expect)
		client:on("joinTribeHouse", expect(function(roomName, roomLanguage)
			p("Received event joinTribeHouse")

			assert(roomName)
			assert(roomLanguage)
		end))

		p("Joining tribe house", args[clientId])
		timer.setTimeout(3500, client.joinTribeHouse, client)

		return -3500
	end)

	test("join room", function(expect)
		client:on("roomChanged", expect(function(roomName, isPrivate, roomLanguage)
			p("Received event roomChanged")

			assert(roomName, client.language .. "-#bolodefchoco", "roomName")

			assert_eq(type(isPrivate), "boolean", "type(isPrivate)")
			assert_eq(roomLanguage, client.language, "roomLanguage")
		end))

		p("Joining room", args[clientId])
		timer.setTimeout(5000, client.enterRoom, client, "#bolodefchoco")

		return -5000
	end)
end)