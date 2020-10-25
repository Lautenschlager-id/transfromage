require("wrapper")(function(test, transfromage, client)
	test("coroutine extensions", function(expect)
		assert(coroutine.makef(function(...)
			assert(select('#', ...) == 3)

			return coroutine.running()
		end)(1, 2, 3))
	end)

	test("log extensions", TO_DO)

	test("math extensions", TO_DO)

	test("string extensions", function(expect)
		-- TO_DO: string.fixEntity

		p("Validating string.getBytes")
		local txt = "abc"
		local firstChar = string.byte(string.sub(txt, 1, 1))
		local lastChar = string.byte(string.sub(txt, -1, -1))

		local bytes = string.getBytes(txt)

		assert(#bytes == #txt)
		assert(bytes[1] == firstChar)
		assert(bytes[#bytes] == lastChar)

		local longBytes = string.getBytes(string.rep(txt, 8100 / #txt))

		assert(#longBytes == 8100)
		assert(longBytes[1] == firstChar)
		assert(longBytes[#longBytes] == lastChar)

		p("Validating string.split")
		local txt = "a-b-c"
		local split = string.split(txt, '-')

		assert(#split == 3)
		assert(split[1] ~= '-')

		p("Validating string.toNickname")
		assert(string.toNickname("tesT") == "Test")
		assert(string.toNickname("teSt", true) == "Test#0000")
	end)

	test("table extensions", function(expect)
		p("Validating table.add")
		local x = { 5 }
		table.add(x, { 8 })

		assert(x[1] == 5)
		assert(x[2] == 8)
		assert(#x == 2)

		p("Validating table.arrayRange")
		local x = { 6, 7, 8, 9 }
		local arr = table.arrayRange(x, 2, 3)

		assert(type(arr) == "table")
		assert(arr[1] == 7)
		assert(arr[2] == 8)
		assert(#arr == 2)

		local arr = table.arrayRange(x)

		assert(arr[1] == 6)
		assert(arr[4] == 9)

		local arr = table.arrayRange(x, 2, 1)

		assert(#arr == 0)

		p("Validating table.copy")
		local x = { 6, function() end, false, { "a" } }
		local y = table.copy(x)

		assert(x ~= y)
		assert(type(y) == "table")
		assert(y[1] == x[1])
		assert(y[2] == x[2])
		assert(y[3] == x[3])
		assert(type(y[4]) == "table")
		assert(y[4] ~= x[4])
		assert(y[4][1] == "a")

		p("Validating table.fuse")
		local x = { 5 }
		local y = table.fuse(x, { 8 })

		assert(x ~= y)
		assert(type(y) == "table")
		assert(y[1] == x[1])
		assert(y[2] == 8)
		assert(#x == 1)
		assert(#y == 2)

		p("Validating table.join")
		local x = { 6, 6, 9 }
		local y = table.join(x, 1)

		assert(type(y) == "table")
		assert(y[1] == 6)
		assert(y[2] == 1)
		assert(y[3] == 6)
		assert(y[4] == 1)
		assert(y[5] == 9)
		assert(#y == 5)
		assert(#x == 3)

		p("Validating table.mapArray")
		local x = { 1, 2, 3 }
		local y = table.mapArray(x, function(z) return z * 10 end)

		assert(type(y) == "table")
		assert(y[1] == 10)
		assert(y[2] == 20)
		assert(y[3] == 30)
		assert(#y == 3)
		assert(#x == 3)

		p("Validating table.writeBytes")
		local x = { string.byte("ABC", 1, -1) }

		assert(table.writeBytes(x) == "ABC")
	end)

	test("utf8 extensions", function(expect)
		local text = "maçã é amanhã"
		local utf8 = string.utf8(text)

		assert(type(utf8) == "table")
		assert(#utf8 == 13)
		assert(utf8[1] == 'm')
		assert(utf8[2] == 'a')
		assert(utf8[3] == 'ç')
		assert(utf8[4] == 'ã')
	end)
end)