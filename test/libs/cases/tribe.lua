local timer = require("timer")

require("wrapper")(function(test, transfromage, client, _, clientAux)
	test("tribe message", function(expect)
		client:on("tribeMessage", expect(function(memberName, message)
			p("Received event tribeMessage")
			if playerName == client.playerName then
				assert_eq(message, "666", "message")
			end
		end))

		client:sendTribeMessage("666")
	end)

	test("open tribe interface", function(expect)
		client:once("tribeInterface", expect(function(tribe)
			p("Received event tribeInterface")
			assert(tribe)

			assert_eq(tostring(tribe), "Tribe", "str(t)")

			assert(tribe._client)
			assert(tribe.id)
			assert(tribe.name)
			assert(tribe.greetingMessage)
			assert(tribe.map)

			assert_eq(type(tribe.members), "table", "type(t)")
			assert(#tribe.members > 0)

			local member
			for m = 1, #tribe.members do
				member = tribe.members[m]
				m = "t[" .. m .. "]."
				assert_neq(member._client, nil, m .. "_client")
				assert_neq(member.id, nil, m .. "id")
				assert_neq(member.playerName, nil, m .. "playerName")
				assert_neq(member.gender, nil, m .. "gender")
				assert_neq(member.lastConnection, nil, m .. "lastConnection")
				assert_neq(member.rolePosition, nil, m .. "rolePosition")
				assert_neq(member.gameId, nil, m .. "gameId")
				assert_neq(member.roomName, nil, m .. "roomName")
			end

			assert_eq(type(tribe.roles), "table", "type(t)")
			assert((next(tribe.roles)))
		end))

		client:openTribeInterface()
	end)

	test("tribe greeting message", function(expect)
		local currentMessage = client.tribe.greetingMessage

		client:once("tribeInterface", expect(function(tribe)
			p("Received event tribeInterface")
			client:setTribeGreetingMessage(currentMessage)

			assert(tribe)
			assert(client.tribe)

			assert_eq(tribe.greetingMessage, "69", "t.greetingMessage")
		end))

		client:setTribeGreetingMessage("69")
	end)

	test("join tribe house (OO)", function(expect)
		client:on("joinTribeHouse", expect(function(roomName, roomLanguage)
			p("Received event joinTribeHouse")

			assert(roomName)
			assert(roomLanguage)
		end))

		p("Joining tribe house")
		timer.setTimeout(3500, client.tribe.joinHouse, client.tribe)

		return -3500
	end)

	test("tribe message (OO)", function(expect)
		client:on("tribeMessage", expect(function(memberName, message)
			p("Received event tribeMessage")
			if playerName == client.playerName then
				assert_eq(message, "666", "message")
			end
		end))

		client.tribe:sendMessage("666")
	end)

	test("open tribe interface (OO)", function(expect)
		client:once("tribeInterface", expect(function(tribe)
			p("Received event tribeInterface")
		end))

		client.tribe:openInterface()
	end)

	test("tribe greeting message (OO)", function(expect)
		local currentMessage = client.tribe.greetingMessage

		client:once("tribeInterface", expect(function(tribe)
			p("Received event tribeInterface")
			client.tribe:setGreetingMessage(currentMessage)
		end))

		client.tribe:setGreetingMessage("69")
	end)

	if clientAux then
		test("recruit player", function(expect)
			local receivedFirst = false
			clientAux:on("tribeInvite", expect(function(recruiterName, tribeName)
				p("Received event tribeInvite")

				assert_eq(recruiterName, client.playerName, "recruiterName")
				assert_eq(type(tribeName), "string", "t(tribeName)")

				client:answerTribeInvite(recruiterName, receivedFirst)
				receivedFirst = not receivedFirst

				if receivedFirst then
					client:recruitPlayer(clientAux.playerName)
				end
			end, 2))

			client:on("newTribeMember", expect(function(memberName)
				p("Received event newTribeMember")

				assert_eq(memberName, clientAux.playerName, "memberName")
			end))

			client:recruitPlayer(clientAux.playerName)
		end)

		test("set member role", function(expect)
			client:on("tribeMemberGetRole", expect(function(memberName, setterName, role)
				p("Received event tribeMemberGetRole")

				assert_eq(memberName, clientAux.playerName, "memberName")
				assert_eq(setterName, client.playerName, "setterName")

				assert_eq(type(role), "string", "type(role)") -- improve 1 -> str
			end))

			client:setTribeMemberRole(clientAux.playerName, 1)
		end)

		test("kick member", function(expect)
			client:on("tribeMemberKick", expect(function(memberName, kickerName)
				p("Received event tribeMemberKick")

				assert_eq(memberName, clientAux.playerName, "memberName")
				assert_eq(kickerName, client.playerName, "kickerName")
			end))

			client:kickTribeMember(clientAux.playerName)
		end)
	end
end)