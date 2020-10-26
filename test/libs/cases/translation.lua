require("wrapper")(function(test, transfromage, client)
	local Translation = transfromage.Translation
	local en

	test("download translation", function(expect)
		en = Translation("en", expect(function(self)
			assert_eq(self.language, "en", "language")
		end))
	end)

	test("get/set translation line", function(expect)
		p("Validating get")
		assert_eq(en:get("T_0"), "Little Mouse", "f(T_0)")

		local T_200, hasGender = en:get("T_200")
		assert_eq(type(T_200), "table", "type(t)")
		assert(hasGender)
		assert_eq(T_200[1], "God Shaman", "t[1]")
		assert_eq(T_200[2], "Goddess Shaman", "t[2]")

		local T_200, hasGender = en:get("T_200", true)
		assert_eq(type(T_200), "string", "type(t)")
		assert(not hasGender)
		assert_eq(T_200, "God(|dess) Shaman", "T_200")

		p("Validating set")
		en:set("T_200", function(value, code)
			assert_eq(code, "T_200", "code")
			assert_eq(value, "God(|dess) Shaman", "value")

			return "Goddamnit Shaman"
		end, true)

		assert_eq(en:get("T_200"), "Goddamnit Shaman", "f(T_200)")
	end)

	test("free translation lines", function(expect)
		en:free({ ["T_0"] = true }, "^T_1")

		assert_eq(en:get("T_0"), "Little Mouse", "f(T_0)")
		assert_eq(en:get("T_200"), nil, "f(T_200)")
		assert_eq(en:get("T_114"), "Alpha & Omega", "f(T_114)")
	end)
end)