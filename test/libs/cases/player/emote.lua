require("wrapper")(function(test, transfromage, client)
	test("play emote", function(expect)
		client:on("playerEmote", expect(function(player, emote, flag)
			p("Received event playerEmote")

			assert_eq(tostring(player), "Player", "player")

			assert_eq(player.playerName, client.playerName, "playerName")

			assert_eq(emote, transfromage.enum.emote.flag, "enum_flag")

			assert_eq(flag, "br", "br")
		end))

		for c = 1, 2 do
			p("Playing emote: " .. tostring(client._handlePlayers))
			client:playEmote(transfromage.enum.emote.flag, "br")
			client:handlePlayers(c == 2)
		end
	end)

	test("play emoticon", function(expect)
		client:on("playerEmoticon", expect(function(player, emoticon)
			p("Received event playerEmoticon")

			assert_eq(tostring(player), "Player", "player")

			assert_eq(player.playerName, client.playerName, "playerName")

			assert_eq(emoticon, transfromage.enum.emoticon.shades, "enum_shades")
		end))

		for c = 1, 2 do
			p("Playing emoticon: " .. tostring(client._handlePlayers))
			client:playEmoticon(transfromage.enum.emoticon.shades)
			client:handlePlayers(c == 2)
		end
	end)
end)