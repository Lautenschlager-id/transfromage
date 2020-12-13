require("wrapper")(function(test, transfromage, client)
	test("chat who", function(expect)
		local testChat = "help"

		client:once("chatWho", expect(function(chatName, nameList)
			p("Received event chatWho")

			assert_eq(chatName, testChat, "chatName")
			assert(nameList[1])
		end))

		client:joinChat(testChat)
		p("Requesting chat who")
		client:chatWho(testChat)
		client:closeChat(testChat)
	end)

	test("chat who (OO)", function(expect)
		local testChat = "help"

		client:once("chatWho", expect(function(chatName, nameList)
			p("Received event chatWho")

			assert_eq(chatName, testChat, "chatName")
			assert(nameList[1])
		end))

		local chat = client.chatList:get(testChat)
		chat:open()
		p("Requesting chat who")
		chat:who()
		chat:close()
	end)
end)