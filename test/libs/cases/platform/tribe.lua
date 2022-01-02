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
		client:on("joinTribeHouse", expect(function(room)
			p("Received event joinTribeHouse")

			assert(room.name)
			assert(room.language)
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
		local recruitPlayerOO = function(expect)
			clientAux:on("tribeInvite", expect(function(recruiterName, tribeName)
				p("Received event tribeInvite")

				client:answerTribeInvite(recruiterName, true)
			end))

			client:on("newTribeMember", expect(function(memberName)
				p("Received event newTribeMember")

				assert_eq(memberName, clientAux.playerName, "memberName")
			end))

			client.tribe:recruitPlayer(clientAux.playerName)
		end

		test("tribe invitation", function(expect)
			clientAux:on("tribeHouseInvitation", expect(function(inviterName, inviterTribe)
				p("Received event tribeHouseInvitation")

				assert_eq(inviterName, client.playerName, "inviterName")
				assert_eq(inviterTribe, client.tribe.name, "inviterTribe")

				clientAux:acceptTribeHouseInvitation(inviterName)
			end))

			client:on("newPlayer", expect(function(playerData)
				p("Received event newPlayer")

				assert_eq(playerData.playerName, clientAux.playerName, "playerName")
			end))

			client:sendCommand("inv " .. clientAux.playerName)
		end)

		test("recruit player", function(expect)
			local receivedFirst = false
			clientAux:on("tribeInvite", expect(function(recruiterName, tribeName)
				p("Received event tribeInvite")

				assert_eq(recruiterName, client.playerName, "recruiterName")
				assert_eq(type(tribeName), "string", "type(tribeName)")

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

		test("recruit player (OO)", recruitPlayerOO)

		test("set member role (OO)", function(expect)
			client:on("tribeMemberGetRole", expect(function(memberName, setterName, role)
				p("Received event tribeMemberGetRole")

				assert_eq(memberName, clientAux.playerName, "memberName")
				assert_eq(setterName, client.playerName, "setterName")

				assert_eq(type(role), "string", "type(role)") -- improve 1 -> str
			end))

			client.tribe:setMemberRole(clientAux.playerName, 1)
		end)

		test("kick member (OO)", function(expect)
			client:on("tribeMemberKick", expect(function(memberName, kickerName)
				p("Received event tribeMemberKick")

				assert_eq(memberName, clientAux.playerName, "memberName")
				assert_eq(kickerName, client.playerName, "kickerName")
			end))

			client.tribe:kickMember(clientAux.playerName)
		end)

		test("recruit player (OO 2) [redo]", recruitPlayerOO)

		local newMember
		test("set member role (OO 2)", function(expect)
			client:on("tribeMemberGetRole", expect(function(memberName, setterName, role)
				p("Received event tribeMemberGetRole")

				assert_eq(memberName, clientAux.playerName, "memberName")
				assert_eq(setterName, client.playerName, "setterName")

				assert_eq(type(role), "string", "type(role)") -- improve 1 -> str
			end))

			for m = 1, #client.tribe.members do
				if client.tribe.members[m].playerName == memberName then
					newMember = client.tribe.members[m]
					break
				end
			end

			newMember:setRole(1)
		end)

		test("kick member (OO 2)", function(expect)
			client:on("tribeMemberKick", expect(function(memberName, kickerName)
				p("Received event tribeMemberKick")

				assert_eq(memberName, clientAux.playerName, "memberName")
				assert_eq(kickerName, client.playerName, "kickerName")
			end))

			newMember:kick()
		end)

		test("recruit player (OO) [redo 2]", recruitPlayerOO)

		test("member leave", function(expect)
			client:on("tribeMemberLeave", function(playerName)
				p("Received event tribeMemberLeave")

				assert_eq(playerName, clientAux.playerName, "playerName")
			end)

			clientAux:leaveTribe()
		end)

		test("recruit player (OO) [redo 3]", recruitPlayerOO)

		test("member leave (OO)", function(expect)
			client:on("tribeMemberLeave", expect(function(playerName)
				p("Received event tribeMemberLeave")

				assert_eq(playerName, clientAux.playerName, "playerName")
			end))

			clientAux:once("tribeInterface", expect(function()
				p("Received event tribeInterface")

				clientAux.tribe:leave()
			end))
			clientAux:openTribeInterface()
		end)

		test("recruit player (OO) [redo 4]", recruitPlayerOO)

		test("member disconnection", function(expect)
			client:on("tribeMemberDisconnection", expect(function(memberName)
				p("Received event tribeMemberDisconnection")

				assert_eq(memberName, clientAux.playerName, "memberName")
			end))

			clientAux:disconnect()
		end)

		test("member connection", function(expect)
			client:on("tribeMemberConnection", expect(function(memberName)
				p("Received event tribeMemberConnection")

				assert_eq(memberName, clientAux.playerName, "memberName")

				clientAux:leaveTribe()
			end))

			clientAux:once("ready", expect(function(onlinePlayers, country, language)
				p("Received event ready")

				clientAux:connect(args[4], args[5], "*transfromage")
			end))

			p("Starting client", args[4])
			clientAux:start()
		end)
	end
end)