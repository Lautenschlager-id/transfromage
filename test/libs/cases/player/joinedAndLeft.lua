-- There must be a regular player in the room in order to make this test pass.

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

	test("player joined room", function(expect)
		clientAux:on("tribeHouseInvitation", expect(function(inviterName, inviterTribe)
			p("Received event tribeHouseInvitation")

			client:handlePlayers(true)

			assert_eq(inviterName, client.playerName, "inviterName")

			clientAux:acceptTribeHouseInvitation(inviterName)
		end))

		client:on("newPlayer", expect(function(playerData, __rollbackExpected)
			p("Received event newPlayer", playerData.playerName)

			assert_eq(tostring(playerData), "Player", "str(t)")
			if playerData.playerName ~= clientAux.playerName then
				__rollbackExpected()
			else
				assert_eq(playerData.playerName, clientAux.playerName, "playerName")
			end
		end))

		client:sendCommand("inv " .. clientAux.playerName)
	end)

	test("player left room", function(expect)
		client:on("playerLeft", expect(function(playerData)
			p("Received event playerLeft")

			assert_eq(tostring(playerData), "Player", "str(t)")
			assert_eq(playerData.playerName, clientAux.playerName, "playerName")
		end))

		client:handlePlayers(true)

		client:sendCommand("invkick " .. clientAux.playerName)
	end)
end)