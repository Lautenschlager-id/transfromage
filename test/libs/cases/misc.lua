local timer = require("timer")

require("wrapper")(function(test, transfromage, client, _, clientAux)
	test("server ping", function(expect)
		client:once("serverPing", expect(function(time)
			p("Received event serverPing")
			assert(time)
		end))

		return 0
	end)

	test("account time", function(expect)
		client:once("time", expect(function(time)
			p("Received event time")

			assert(time.day)
			assert(time.hour)
			assert(time.minute)
			assert(time.second)
		end))

		client:sendCommand("time")
	end)

	test("staff list", function(expect)
		local firstCommand = false
		client:on("staffList", expect(function(isModList, namesByCommunity, individualNames)
			p("Received event staffList")

			firstCommand = not firstCommand
			assert_eq(isModList, firstCommand, "isModList")

			assert_eq(type(namesByCommunity), "table", "type(t)")
			assert_eq(type(individualNames), "table", "type(t)")

			local count = 0
			for k, v in next, namesByCommunity do
				count = count + #v
			end

			assert_eq(count, #individualNames, "#t")

			if firstCommand then
				timer.setTimeout(250, client.sendCommand, client, "mapcrew")
			end
		end, 2))

		timer.setTimeout(250, client.sendCommand, client, "mod")

		return 500
	end)

	if clientAux then
		test("whisper state", function(expect)
			local attempt = 0
			client:on("whisperFail", expect(function(failType, silenceMessage)
				p("Received event whisperFail", failType, silenceMessage)

				attempt = attempt + 1

				if attempt == 1 then -- /silence msg
					assert_eq(failType, transfromage.enum.whisperFail.silence, "failType 1")
					assert_eq(silenceMessage, "noob", "silenceMessage 1")

					clientAux:removeFriend(client.playerName)
					clientAux:changeWhisperState(transfromage.enum.whisperState.disabledPublic)
					timer.setTimeout(250, client.sendWhisper, client, clientAux.playerName,
						"test 2")
				elseif attempt == 2 then -- /silence
					assert_eq(failType, transfromage.enum.whisperFail.silence, "failType 2")
					assert_eq(silenceMessage, "", "silenceMessage 2")

					clientAux:changeWhisperState(transfromage.enum.whisperState.enabled)
					timer.setTimeout(250, client.sendWhisper, client, clientAux.playerName,
						"test 3")
				elseif attempt == 3 then
					assert_eq(failType, transfromage.enum.whisperFail.disconnected, "failType 3")
					assert_eq(silenceMessage, "", "silenceMessage 3")
				end
			end, 3))

			clientAux:once("whisperMessage", expect(function(playerName, message, playerCommunity)
				p("Received event whisperMessage")

				assert_eq(playerName, client.playerName, "playerName")
				assert_eq(message, "test 3", "message")

				client:sendWhisper("+" .. clientAux.playerName, "test")
			end))

			clientAux:changeWhisperState(transfromage.enum.whisperState.disabledAll, "noob")
			timer.setTimeout(250, client.sendWhisper, client, clientAux.playerName, "test")

			return -(250 * 3)
		end)
	end
end)