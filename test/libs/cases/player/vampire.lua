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

	test("(un)transform into vampire", function(expect)
		local trigger = 0
		client:on("playerVampire", expect(function(playerData, isVampire)
			p("Received event playerVampire")

			trigger = trigger + 1

			assert_eq(tostring(playerData), "Player", "str(t)")
			assert_eq(type(isVampire), "boolean", "type(isVampire)")
			assert_eq(isVampire, trigger == 1, "isVampire")

			assert_eq(playerData.isVampire, isVampire, "t.isVampire")
			assert_eq(playerData.winPosition, -1, "t.winPosition")
			assert_eq(playerData.winTimeElapsed, -1, "t.winTimeElapsed")
			assert_eq(playerData.hasWon, false, "t.hasWon")
		end, 2))

		for t = 0, 1 do
			timer.setTimeout(5000 + (3000 * t), client.loadLua, client, string.format([[
				tfm.exec.respawnPlayer("%s")
				tfm.exec.setVampirePlayer("%s", %s)
			]], client.playerName, client.playerName, t == 0))
		end

		return -8000
	end)
end)