local timer = require("timer")

require("wrapper")(function(test, transfromage, client)
	test("join room", function(expect)
		client:once("roomChanged", expect(function(roomName, isPrivate, roomLanguage)
			p("Received event roomChanged")

			assert(roomName == "#bolodefchoco666")

			assert(isPrivate ~= nil)
			assert(roomLanguage)

			return true
		end))

		p("Joining room")
		client:enterRoom("#bolodefchoco666")
	end)

	test("join tribe house", function(expect)
		client:once("joinTribeHouse", expect(function(roomName, roomLanguage)
			p("Received event joinTribeHouse")

			assert(roomName)
			assert(string.sub(roomName, 1, 2) == "*\3")

			assert(roomLanguage)

			return true
		end))

		p("Joining tribe house")
		timer.setTimeout(3000, client.enterRoom, client, "#bolodefchoco666")
	end)
end)