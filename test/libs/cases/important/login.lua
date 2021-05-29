require("wrapper")(function(test, transfromage, client)
	test("login", function(expect)
		args[2] = string.toNickname(args[2], true)

		client:once("ready", expect(function(onlinePlayers, country, language)
			p("Received event ready")

			assert(onlinePlayers)

			assert(country)
			assert_neq(country, '', "country")

			assert(language)
			assert_neq(language, '', "language")

			client:connect(args[2], args[3], "*transfromage")
		end))

		client:once("mainConnection", expect(function(playerId, playerName, playedTime)
			p("Received event mainConnection")

			assert(playerId)

			assert(playerName)
			assert_neq(playerName, '', "playerName")

			assert(playedTime)

			assert_eq(playerName, args[2], "playerName")
		end))

		client:once("connection", expect(function()
			p("Received event connection")
		end))

		p("Starting client")
		client:start()
	end)

	test("handle players", function(expect)
		client:handlePlayers(false)
		assert(not client._handlePlayers)

		client:handlePlayers()
		assert(client._handlePlayers)

		client:handlePlayers()
		assert(not client._handlePlayers)

		client:handlePlayers(true)
		assert(client._handlePlayers)
	end)

	test("skip first room change", function(expect)
		client:on("roomChanged", expect(function(roomName, isPrivate, roomLanguage)
			p("Received event roomChanged")

			assert(roomName)
			assert(isPrivate ~= nil)
			assert(roomLanguage)
		end))
	end)
end)