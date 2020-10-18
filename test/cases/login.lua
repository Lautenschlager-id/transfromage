require("./test/wrapper")(function(test, transfromage, client)
	test("login", function(expect)
		args[2] = string.toNickname(args[2], true)

		client:once("ready", expect(function(onlinePlayers, country, language)
			assert(onlinePlayers)

			assert(country)
			assert(country ~= '')

			assert(language)
			assert(language ~= '')

			client:connect(args[2], args[3])

			return true
		end))

		client:once("connection", expect(function(playerId, playerName, playedTime)
			assert(playerId)

			assert(playerName)
			assert(playerName ~= '')

			assert(playedTime)

			assert(playerName == args[2])

			return true
		end))

		client:start(args[4], args[5])
	end)
end)