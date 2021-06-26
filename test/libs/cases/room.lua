local timer = require("timer")

require("wrapper")(function(test, transfromage, client, _, clientAux)
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

	test("new game and xml", function(expect)
		client:on("newGame", expect(function(map)
			p("Received event newGame")

			assert_eq(type(map), "table", "type(t)")

			if client._decryptXML then
				client:decryptXML()

				assert_eq(type(map.xml), "string", "type(t.xml)")
			else
				assert(not map.xml)
			end
		end, 2))

		client:decryptXML(true)
		timer.setTimeout(5000, client.sendCommand, client, "np @1929779")

		return -5000
	end)

	test("room list", function(expect)
		local roomModes = transfromage.enum.roomMode

		client:on("roomList", expect(function(roomMode, rooms, pinnedRooms)
			p("Received event roomList", roomMode)

			assert(roomModes(roomMode))

			assert_eq(type(rooms), "table", "type(rooms)")
			assert_eq(type(pinnedRooms), "table", "type(pinnedRooms)")
		end, #roomModes))

		for modeName, mode in pairs(roomModes) do
			p("Requesting room list", modeName, mode)
			client:requestRoomList(mode)
		end
	end)

	if clientAux then
		test("enter private room", function(expect)
			client:on("roomChanged", expect(function(roomName)
				p("Received event roomChanged")

				assert_eq(roomName, "*#test", "roomName")
			end))

			clientAux:on("roomChanged", expect(function()
				p("Received event roomChanged [aux]")

				clientAux:sendCommand("pw test")

				timer.setTimeout(3500, client.enterPrivateRoom, client, "*#test", "test")
			end))

			timer.setTimeout(3500, clientAux.enterRoom, clientAux, "*#test")

			return -7000
		end)
	end
end)