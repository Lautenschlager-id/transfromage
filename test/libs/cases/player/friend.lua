require("wrapper")(function(test, transfromage, client)
	local recentlyAddedID

	local checkFriend = function(friend, desc)
		assert_eq(tostring(friend), "Friend", "str(" .. desc .. ")")

		assert(friend._client)
		assert(friend.id)
		assert(friend.playerName)
		assert(friend.gender)
		assert_eq(type(friend.hasAvatar), "boolean", "type(" .. desc .. ".hasAvatar)")
		assert_eq(type(friend.isFriend), "boolean", "type(" .. desc .. ".isFriend)")
		assert_eq(type(friend.isConnected), "boolean", "type(" .. desc .. ".isConnected)")
		assert(friend.gameId)
		assert(friend.roomName)
		assert(friend.lastConnection)
	end

	test("add friend", function(expect)
		client:on("newFriend", expect(function(friend)
			p("Received event newFriend")

			checkFriend(friend, 't')

			assert_eq(friend.playerName, "Tigrounette#0001", "playerName")
			recentlyAddedID = friend.id
		end))

		client:addFriend("Tigrounette#0001")
	end)

	test("friend list", function(expect)
		client:on("friendList", expect(function(friendList, soulmate)
			p("Received event friendList")

			checkFriend(soulmate, "sm")

			assert_eq(type(friendList), "table", "type(t)")
			assert(#friendList >= 1)

			local foundRecentlyAdded = false
			for friend = 1, #friendList do
				checkFriend(friendList[friend], "t[" .. friend .. "]")

				if friendList[friend].playerName == "Tigrounette#0001" then
					foundRecentlyAdded = true
				end
			end

			assert(foundRecentlyAdded)
		end))

		client:requestFriendList()
	end)

	test("remove friend", function(expect)
		client:on("removeFriend", expect(function(playerId)
			p("Received event removeFriend")
			assert_eq(playerId, recentlyAddedID, "id")
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