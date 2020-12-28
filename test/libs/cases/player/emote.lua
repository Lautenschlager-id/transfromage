require("wrapper")(function(test, transfromage, client)
	test("play emote", function(expect)
		client:on("playerEmote", function(player, emote, flag)
			assert_eq(player, client.playerName, "playerName")

			assert_eq(emote, transfromage.enum.emote.flag, "enum_flag")

			assert_eq(flag, "br", "br")
		end)

		client:playEmote(transfromage.enum.emote.flag, "br")
	end)

	test("play emoticon", function(expect)
		client:on("playerEmoticon", function(player, emoticon)
			assert_eq(player, client.playerName, "playerName")

			assert_eq(emoticon, transfromage.enum.emoticon.shades, "enum_shades")
		end)

		client:playEmoticon(transfromage.enum.emoticon.shades)
	end)
end)