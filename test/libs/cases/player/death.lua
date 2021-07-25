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

	test("player death", function(expect)
		client:on("playerDeath", expect(function(playerData)
			p("Received event playerDeath")

			assert_eq(tostring(playerData), "Player", "str(t)")

			assert_eq(playerData.isDead, true, "t.isDead")
		end))

		client:handlePlayers(true)

		timer.setTimeout(5000, client.loadLua, client, string.format([[
			tfm.exec.respawnPlayer("%s")
			tfm.exec.killPlayer("%s")
		]], client.playerName, client.playerName))

		return -5000
	end)
end)