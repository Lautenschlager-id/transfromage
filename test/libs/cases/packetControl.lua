local Buffer = require("transfromage/libs/classes/Buffer")
local ByteArray = require("transfromage/libs/classes/ByteArray")

require("wrapper")(function(test, transfromage, client)
	test("buffer", function(expect)
		local buffer = Buffer()

		assert(buffer:receive(1) == nil)

		buffer:push({ 65, 66, 67 })

		assert(buffer._count == 3)
		assert(buffer.queue[1] == 65)
		assert(buffer.queue[2] == 66)
		assert(buffer.queue[3] == 67)

		assert(type(buffer:receive(0)) == "table")
		assert(buffer:receive(1)[1] == 65)
		assert(buffer:receive(1)[1] == 66)

		buffer:push("D")

		assert(buffer:receive(1)[1] == 67)
		assert(buffer:receive(1)[1] == 68)
	end)

	test("byte array", function(expect)
		local byteArray = ByteArray({ 65, 66, 67 })

		p("Validating duplicate")
		local copy = byteArray:duplicate()

		assert(byteArray.stack[1] == 65)
		assert(byteArray.stack[2] == 66)
		assert(byteArray.stack[3] == 67)

		assert(copy.stack[1] == 65)
		assert(copy.stack[2] == 66)
		assert(copy.stack[3] == 67)

		copy.stack[1] = 666

		assert(copy.stack[1] == 666)
		assert(byteArray.stack[1] == 65)


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

		assert(byteArray.stackLen == len)
		assert(byteArray.stack[1] == 1)
		assert(byteArray.stack[byteArray.stackLen] == 0)

		p("Validating read")
		local firstTwo = byteArray:read8(2)
		assert(firstTwo[1] == 1)
		assert(firstTwo[2] == 2)
		assert(byteArray:read8() == 0xFF)

		len = len - 3
		assert(byteArray.stackLen == len)

		assert(byteArray:read16() == 0xFFFF)
		assert(byteArray:read24() == 0xFFFFFF)
		assert(byteArray:read32() == 0x7FFFFFFF)

		len = len - 2 - 3 - 4
		assert(byteArray.stackLen == len)

		assert(byteArray:readUTF() == utf)
		assert(byteArray:readBigUTF() == bigUtf)

		len = len - (0xFFFF + 2) - (0xFFFFFF + 3)
		assert(byteArray.stackLen == len)

		assert(byteArray:readBool() == true)
		assert(byteArray:readBool() == false)

		len = len - 1 - 1
		assert(byteArray.stackLen == len)

		-- TO_DO: ByteArray.readSigned16
	end)
end)