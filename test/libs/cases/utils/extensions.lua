require("wrapper")(function(test, transfromage, client)
	test("coroutine extensions", function(expect)
		assert(coroutine.makef(function(...)
			assert_eq(select('#', ...), 3, "#...")

			return coroutine.running()
		end)(1, 2, 3))
	end)

	test("log extensions", TO_DO)

	test("math extensions", function(expect)
		assert_eq(math.symmetricFloor(-10.5), -11, "f(-1)")
		assert_eq(math.symmetricFloor(10.5), 11, "f(1)")
		assert_eq(math.symmetricFloor(0), 0, "f(0)")
	end)

	test("string extensions", function(expect)
		-- TO_DO: string.fixEntity

		p("Validating string.getBytes")
		local txt = "abc"
		local firstChar = string.byte(string.sub(txt, 1, 1))
		local lastChar = string.byte(string.sub(txt, -1, -1))

		local bytes = string.getBytes(txt)

		assert_eq(#bytes, #txt, "#t")
		assert_eq(bytes[1], firstChar, "t[1]")
		assert_eq(bytes[#bytes], lastChar, "t[-1")

		local longBytes = string.getBytes(string.rep(txt, 8100 / #txt))

		assert_eq(#longBytes, 8100, "#t")
		assert_eq(longBytes[1], firstChar, "t[1")
		assert_eq(longBytes[#longBytes], lastChar, "t[-1]")

		p("Validating string.split")
		local txt = "a-b-c"
		local split = string.split(txt, '-')

		assert_eq(#split, 3, "#t")
		assert_neq(split[1], '-', "t[1]")

		p("Validating string.toNickname")
		assert_eq(string.toNickname("tesT"), "Test", "f(tesT)")
		assert_eq(string.toNickname("teSt", true), "Test#0000", "f(teSt)")
	end)

	test("table extensions", function(expect)
		p("Validating table.add")
		local x = { 5 }
		table.add(x, { 8 })

		assert_eq(x[1], 5, "t[1]")
		assert_eq(x[2], 8, "t[2]")
		assert_eq(#x, 2, "#t")

		p("Validating table.arrayRange")
		local x = { 6, 7, 8, 9 }
		local arr = table.arrayRange(x, 2, 3)

		assert_eq(type(arr), "table", "type(t)")
		assert_eq(arr[1], 7, "t[1]")
		assert_eq(arr[2], 8, "t[2]")
		assert_eq(#arr, 2, "#t")

		local arr = table.arrayRange(x)

		assert_eq(arr[1], 6, "t[1]")
		assert_eq(arr[4], 9, "t[4]")

		local arr = table.arrayRange(x, 2, 1)

		assert_eq(#arr, 0, "#t")

		p("Validating table.copy")
		local x = { 6, function() end, false, { "a" } }
		local y = table.copy(x)

		assert_neq(x, y, "x")
		assert_eq(type(y), "table", "type(t)")
		assert_eq(y[1], x[1], "t[1]")
		assert_eq(y[2], x[2], "t[2]")
		assert_eq(y[3], x[3], "t[3]")
		assert_eq(type(y[4]), "table", "type(t[4])")
		assert_neq(y[4], x[4], "t[4]")
		assert_eq(y[4][1], "a", "t[4][1]")

		p("Validating table.fuse")
		local x = { 5 }
		local y = table.fuse(x, { 8 })

		assert_neq(x, y, "x")
		assert_eq(type(y), "table", "type(t)")
		assert_eq(y[1], x[1], "t[1]")
		assert_eq(y[2], 8, "t[2]")
		assert_eq(#x, 1, "#t")
		assert_eq(#y, 2, "#t")

		p("Validating table.join")
		local x = { 6, 6, 9 }
		local y = table.join(x, 1)

		assert_eq(type(y), "table", "type(t)")
		assert_eq(y[1], 6, "t[1]")
		assert_eq(y[2], 1, "t[2]")
		assert_eq(y[3], 6, "t[3]")
		assert_eq(y[4], 1, "t[4]")
		assert_eq(y[5], 9, "t[5]")
		assert_eq(#y, 5, "#t")
		assert_eq(#x, 3, "#t")

		p("Validating table.mapArray")
		local x = { 1, 2, 3 }
		local y = table.mapArray(x, function(z) return z * 10 end)

		assert_eq(type(y), "table", "type(t)")
		assert_eq(y[1], 10, "t[1]")
		assert_eq(y[2], 20, "t[2]")
		assert_eq(y[3], 30, "t[3]")
		assert_eq(#y, 3, "#t")
		assert_eq(#x, 3, "#t")

		p("Validating table.writeBytes")
		local x = { string.byte("ABC", 1, -1) }

		assert_eq(table.writeBytes(x), "ABC", "f(t)")
	end)

	test("utf8 extensions", function(expect)
		local text = "maçã é amanhã"
		local utf8 = string.utf8(text)

		assert_eq(type(utf8), "table", "type(t)")
		assert_eq(#utf8, 13, "#t")
		assert_eq(utf8[1], 'm', "t[1]")
		assert_eq(utf8[2], 'a', "t[2]")
		assert_eq(utf8[3], 'ç', "t[3]")
		assert_eq(utf8[4], 'ã', "t[4]")
	end)

	test("class extensions", function(expect)
		local class = table.setNewClass("test")

		local randomArg = math.random(666)
		class.new = function(self, arg)
			assert_eq(arg, randomArg, "arg")

			return setmetatable({
				data = arg / 2
			}, self)
		end

		local instance = class(randomArg)
		assert_eq(tostring(instance), "test", "str(t)")

		assert_eq(type(instance), "table", "type(t)")
		assert_eq(instance.data, randomArg / 2, "return")

		class.str = class.new
		class.strOld = "str"

		instance = class:strOld(randomArg)
		assert_eq(instance.data, randomArg / 2, "return deprecated")
	end)
end)