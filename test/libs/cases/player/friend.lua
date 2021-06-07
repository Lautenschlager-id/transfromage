require("wrapper")(function(test, transfromage, client, _, clientAux)
	local friendNickname = clientAux and clientAux.playerName or "Tigrounette#0001"
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

			assert_eq(friend.playerName, friendNickname, "playerName")
			recentlyAddedID = friend.id
		end))

		client:addFriend(friendNickname)
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

				if friendList[friend].playerName == friendNickname then
					foundRecentlyAdded = true
				end
			end

			assert(foundRecentlyAdded)
		end))

		client:requestFriendList()
	end)

	if clientAux == false then -- All failed
		test("friend disconnection", function(expect)
			client:on("friendDisconnection", expect(function(friendName)
				p("Received event friendDisconnection")
				assert_eq(friendName, friendNickname, "friendName")
			end))

			clientAux:disconnect()
		end)

		test("reconnect auxiliar account", function(expect)
			clientAux:once("ready", expect(function()
				clientAux:connect(args[4], args[5], "*transfromage") -- client.room.name (?)
			end))
			clientAux:start()
		end)

		test("friend connection", function(expect)
			client:on("friendConnection", expect(function(friendName)
				p("Received event friendConnection")
				assert_eq(friendName, friendNickname, "friendName")
			end))
		end)
	end

	test("remove friend", function(expect)
		client:on("removeFriend", expect(function(playerId)
			p("Received event removeFriend")
			assert_eq(playerId, recentlyAddedID, "id")
		end))

		client:removeFriend(friendNickname)
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

				if playerList[n] == friendNickname then
					foundRecentlyBlacklisted = true
				end
			end

			if mustFindRecentlyBlacklisted then
				assert(foundRecentlyBlacklisted)

				client:whitelistPlayer(friendNickname)
				client:requestBlackList()
			else
				assert(not foundRecentlyBlacklisted)
			end
		end, 2))

		client:blacklistPlayer(friendNickname)
	end)
end)