require("wrapper")(function(test, transfromage, client)
	local Translation = transfromage.Translation
	local en

	test("download translation", function(expect)
		en = Translation("en", expect(function(self)
			assert(self.language == "en")
		end))
	end)

	test("get/set translation line", function(expect)
		p("Validating get")
		assert(en:get("T_0") == "Little Mouse")

		local T_200, hasGender = en:get("T_200")
		assert(type(T_200) == "table")
		assert(hasGender)
		assert(T_200[1] == "God Shaman")
		assert(T_200[2] == "Goddess Shaman")

		local T_200, hasGender = en:get("T_200", true)
		assert(type(T_200) == "string")
		assert(not hasGender)
		assert(T_200 == "God(|dess) Shaman")

		p("Validating set")
		en:set("T_200", function(value, code)
			assert(code == "T_200")
			assert(value == "God(|dess) Shaman")

			return "Goddamnit Shaman"
		end, true)

		assert(en:get("T_200") == "Goddamnit Shaman")
	end)

	test("free translation lines", function(expect)
		en:free({ ["T_0"] = true }, "^T_1")

		assert(en:get("T_0") == "Little Mouse")
		assert(en:get("T_200") == nil)
		assert(en:get("T_114") == "Alpha & Omega")
	end)
end)