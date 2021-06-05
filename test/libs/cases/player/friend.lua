require("wrapper")(function(test, transfromage, client)
	local tigId

	test("add friend", function(expect)
		client:on("newFriend", expect(function(friend)
			p("Received event newFriend")
			assert(friend)

			assert_eq(tostring(friend), "Friend", "str(t)")

			assert(friend._client)
			assert(friend.id)
			assert_eq(friend.playerName, "Tigrounette#0001", "playerName")
			assert(friend.gender)
			assert_eq(type(friend.hasAvatar), "boolean", "type(hasAvatar)")
			assert_eq(type(friend.isFriend), "boolean", "type(isFriend)")
			assert_eq(type(friend.isConnected), "boolean", "type(isConnected)")
			assert(friend.gameId)
			assert(friend.roomName)
			assert(friend.lastConnection)

			tigId = friend.id
		end))

		client:addFriend("Tigrounette#0001")
	end)

	test("remove friend", function(expect)
		client:on("removeFriend", expect(function(playerId)
			p("Received event removeFriend")
			assert_eq(playerId, tigId, "id")
		end))

		client:removeFriend("Tigrounette#0001")
	end)

	test("blacklist", function(expect)
		local foundRecentlyBlacklisted = false

		client:on("blackList", expect(function(playerList)
			p("Received event blackList")

			assert_eq(type(playerList), "table", "type(t)")

			local mustFindRecentlyBlacklisted = not foundRecentlyBlacklisted
			foundRecentlyBlacklisted = false

			for n = 1, #playerList do
				assert_neq(playerList[n], nil, "t[" .. n .. "]")

				if playerList[n] == "Tigrounette#0001" then
					foundRecentlyBlacklisted = true
				end
			end

			if mustFindRecentlyBlacklisted then
				assert(foundRecentlyBlacklisted)

				client:whitelistPlayer("Tigrounette#0001")
				client:requestBlackList()
			else
				assert(not foundRecentlyBlacklisted)
			end
		end, 2))

		client:blacklistPlayer("Tigrounette#0001")
	end)
end)