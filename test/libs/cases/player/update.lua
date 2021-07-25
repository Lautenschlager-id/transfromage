local timer = require("timer")

require("wrapper")(function(test, transfromage, client)
	local updateFlags = transfromage.enum.updatePlayer

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

	test("change shaman color", function(expect)
		client:on("updatePlayer", expect(function(playerData, oldPlayerData, updateFlag,
			__rollbackExpected)
			p("Received event updatePlayer", updateFlags(updateFlag))

			assert_eq(tostring(playerData), "Player", "str(t)")
			assert_eq(tostring(oldPlayerData), "Player", "str(oldT)")

			if updateFlag ~= updateFlags.shamanColor
				or playerData.playerName ~= client.playerName then
				__rollbackExpected()
			else
				assert_eq(updateFlag, updateFlags.shamanColor, "updateFlag")

				assert_eq(playerData.playerName, client.playerName, "t.playerName")
				assert_eq(oldPlayerData.playerName, client.playerName, "oldT.playerName")

				assert_eq(playerData.isShaman, true, "t.isShaman")

				if playerData.isBlueShaman then
					assert_neq(playerData.isBlueShaman, oldPlayerData.isBlueShaman, "isBlueShaman")
				else
					assert_neq(playerData.isPinkShaman, oldPlayerData.isPinkShaman, "isPinkShaman")
				end
			end
		end))

		client:handlePlayers(true)

		-- pick pink by luck with 2 players in the room
		timer.setTimeout(5000, client.sendCommand, client, "np 50")

		return -5000
	end)

	test("change player score", function(expect)
		client:on("updatePlayer", expect(function(playerData, oldPlayerData, updateFlag,
			__rollbackExpected)
			p("Received event updatePlayer", updateFlags(updateFlag))

			assert_eq(tostring(playerData), "Player", "str(t)")
			assert_eq(tostring(oldPlayerData), "Player", "str(oldT)")

			if updateFlag ~= updateFlags.score then
				__rollbackExpected()
			else
				assert_eq(updateFlag, updateFlags.score, "updateFlag")

				assert_eq(playerData.playerName, client.playerName, "t.playerName")
				assert_eq(oldPlayerData.playerName, client.playerName, "oldT.playerName")

				assert_neq(playerData.score, oldPlayerData.score, "score")
				assert_eq(playerData.score, 666, "t.score")
			end
		end))

		client:handlePlayers(true)

		timer.setTimeout(5000, client.loadLua, client, string.format([[
			tfm.exec.setPlayerScore("%s", 666)
		]], client.playerName))

		return -5000
	end)

	-- There must be a regular player in the room in order to make this test pass.
	local friendNickname = "Bolodefchoco#0015"
	test("change player position", function(expect)
		client:on("updatePlayer", expect(function(playerData, oldPlayerData, updateFlag,
			__rollbackExpected)

			assert_eq(tostring(playerData), "Player", "str(t)")
			assert_eq(tostring(oldPlayerData), "Player", "str(oldT)")

			if updateFlag ~= updateFlags.movement or playerData.y > 0 then
				__rollbackExpected()
			else
				if playerData.x ~= 69 then
					return __rollbackExpected()
				end

				assert_eq(updateFlag, updateFlags.movement, "updateFlag")

				assert_eq(playerData.playerName, friendNickname, "t.playerName")
				assert_eq(oldPlayerData.playerName, friendNickname, "oldT.playerName")

				assert_neq(playerData.x, oldPlayerData.x, "x")
				assert_neq(playerData.y, oldPlayerData.y, "y")

				assert_neq(playerData.vx, oldPlayerData.vx, "vx")
				assert_neq(playerData.vy, oldPlayerData.vy, "vy")

				assert_eq(playerData.x, 69, "t.x")
				assert_eq(playerData.y, -50, "t.y")

				assert_eq(playerData.vx, 365, "t.vx")
				assert_eq(playerData.vy, -36, "t.vy")
			end
		end))

		client:handlePlayers(true)

		timer.setTimeout(5000, client.loadLua, client, string.format([[
			tfm.exec.respawnPlayer("%s")
			tfm.exec.movePlayer("%s", 69, -50, nil, 365, -36)
		]], friendNickname, friendNickname))

		return -5000
	end)

end)