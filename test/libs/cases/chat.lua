require("wrapper")(function(test, transfromage, client)
	test("chat list metamethods", function(expect)
		local chatNames = { "help", "lua", "mapcrew" }

		local chatNamesByIndex = { }
		local chats = { }

		local totalChats = #chatNames
		for c = 1, totalChats do
			chatNamesByIndex[chatNames[c]] = true
			chats[c] = client.chatList:get(chatNames[c])

			assert_eq(tostring(chats[c]), "Chat", "str(t[i])")
		end

		assert_eq(#client.chatList, totalChats, "totalChats")

		for chatName, chat in pairs(client.chatList) do
			assert(chatNamesByIndex[chatName])
			assert_eq(tostring(chat), "Chat", "str(c)")
		end
	end)

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