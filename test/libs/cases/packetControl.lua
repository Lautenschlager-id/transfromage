local Buffer = require("transfromage/libs/classes/Buffer")
local ByteArray = require("transfromage/libs/classes/ByteArray")

require("wrapper")(function(test, transfromage, client)
	test("buffer", function(expect)
		local buffer = Buffer()

		assert_eq(buffer:receive(1), nil, "f(1)")

		buffer:push({ 65, 66, 67 })

		assert_eq(buffer._count, 3, "count")
		assert_eq(buffer.queue[1], 65, "t[1]")
		assert_eq(buffer.queue[2], 66, "t[2]")
		assert_eq(buffer.queue[3], 67, "t[3]")

		assert_eq(type(buffer:receive(0)), "table", "type(t)")
		assert_eq(buffer:receive(1)[1], 65, "f(1)[1]")
		assert_eq(buffer:receive(1)[1], 66, "f(1)[1]")

		buffer:push("D")

		assert_eq(buffer:receive(1)[1], 67, "f(1)[1]")
		assert_eq(buffer:receive(1)[1], 68, "f(1)[1]")
	end)

	test("byte array", function(expect)
		local byteArray = ByteArray({ 65, 66, 67 })

		p("Validating duplicate")
		local copy = byteArray:duplicate()

		assert_eq(byteArray.stack[1], 65, "t[1]")
		assert_eq(byteArray.stack[2], 66, "t[2]")
		assert_eq(byteArray.stack[3], 67, "t[3]")

		assert_eq(copy.stack[1], 65, "t[1]")
		assert_eq(copy.stack[2], 66, "t[2]")
		assert_eq(copy.stack[3], 67, "t[3]")

		copy.stack[1] = 666

		assert_eq(copy.stack[1], 666, "t[1]")
		assert_eq(byteArray.stack[1], 65, "t[1]")


		p("Validating write")
		local utf = string.rep('A', 0xFFFF)
		local bigUtf = string.rep('A', 0xFFFFFF)

		local byteArray = ByteArray()
			:write8(1, 2, 0xFF)
			:write16(0xFFFF)
			:write24(0xFFFFFF)
			:write32(0x7FFFFFFF)
			:writeUTF(utf)
			:writeBigUTF(bigUtf)
			:writeBool(true)
			:writeBool(false)

		local len = (3 + 2 + 3 + 4 + (0xFFFF + 2) + (0xFFFFFF + 3) + 1 + 1)

		assert_eq(byteArray.stackLen, len, "stackLen")
		assert_eq(byteArray.stack[1], 1, "t[1]")
		assert_eq(byteArray.stack[byteArray.stackLen], 0, "t[-1]")

		p("Validating read")
		local firstTwo = byteArray:read8(2)
		assert_eq(firstTwo[1], 1, "t[1]")
		assert_eq(firstTwo[2], 2, "t[1]")
		assert_eq(byteArray:read8(), 0xFF, "r8()")

		len = len - 3
		assert_eq(byteArray.stackLen, len, "stackLen")

		assert_eq(byteArray:read16(), 0xFFFF, "r16()")
		assert_eq(byteArray:read24(), 0xFFFFFF, "r24()")
		assert_eq(byteArray:read32(), 0x7FFFFFFF, "r32()")

		len = len - 2 - 3 - 4
		assert_eq(byteArray.stackLen, len, "stackLen")

		assert_eq(byteArray:readUTF(), utf, "rUTF()")
		assert_eq(byteArray:readBigUTF(), bigUtf, "rBUTF()")

		len = len - (0xFFFF + 2) - (0xFFFFFF + 3)
		assert_eq(byteArray.stackLen, len, "stackLen")

		assert_eq(byteArray:readBool(), true, "rBool()")
		assert_eq(byteArray:readBool(), false, "rBool()")

		len = len - 1 - 1
		assert_eq(byteArray.stackLen, len, "stackLen")

		-- TO_DO: ByteArray.readSigned16
	end)
end)