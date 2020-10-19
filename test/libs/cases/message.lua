require("wrapper")(function(test, transfromage, client)
	test("room message", function(expect)
		client:on("roomMessage", expect(function(playerName, message)
			p("Received event roomMessage")
			if playerName == client.playerName then
				assert(message == "666")

				return true
			end
		end))

		p("Sending room message")
		client:sendRoomMessage("666")
	end)

	test("chat message (OO)", function(expect)
		client:on("chatMessage", expect(function(chatName, playerName, message, playerCommunity)
			p("Received event chatMessage")
			if playerName == client.playerName then
				assert(chatName == testChat.name)
				assert(message == "69")
				assert(playerCommunity == transfromage.enum.chatCommunity.br)

				return true
			end
		end))

		testChat = client.chatList:get("transfromage-api-test-oo")
		p("Sending chat message")
		testChat:sendMessage("69")
		testChat:close()
	end)

	test("chat message", function(expect)
		local testChat = "transfromage-api-test"

		client:on("chatMessage", expect(function(chatName, playerName, message, playerCommunity)
			p("Received event chatMessage")
			if playerName == client.playerName then
				assert(chatName == testChat)
				assert(message == "69")
				assert(playerCommunity == transfromage.enum.chatCommunity.br)

				return true
			end
		end))

		client:joinChat(testChat)
		p("Sending chat message")
		client:sendChatMessage(testChat, "69")
		client:closeChat(testChat)
	end)

	test("whisper", function(expect)
		client:on("whisperMessage", expect(function(playerName, message, playerCommunity)
			p("Received event whisperMessage")
			if playerName == client.playerName then
				assert(message == "911")
				assert(playerCommunity == transfromage.enum.chatCommunity.br)

				return true
			end
		end))

		p("Sending whisper message")
		client:sendWhisper(client.playerName, "911")
	end)
end)