require("wrapper")(function(test, transfromage, client)
	test("open profile", function(expect)
		client:on("profileLoaded", expect(function(profileData)
			p("Received event profileLoaded")

			assert_eq(type(profileData), "table", "type(t)")

			assert_eq(profileData.playerName, client.playerName)

			assert_eq(profileData.titles[0], 1, "title 0")
			assert_eq(profileData.totalBadges, 2, "total badges")
			assert_eq(profileData.totalOrbs, 3, "total orbs")

			assert_eq(profileData.saves.normal, 2, "normal saves")
			assert_eq(profileData.cheese, 100, "cheese")
		end))

		client:sendCommand("profile " .. client.playerName)
	end)
end)