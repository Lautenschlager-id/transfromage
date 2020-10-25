local getPasswordHash = require("transfromage/libs/utils/encoding/password")

require("wrapper")(function(test, transfromage, client)
	test("encoding", function(expect)
		-- TO_DO: loginCipher

		-- TO_DO: packetCipher

		p("Validating password")
		assert(getPasswordHash("test1234") == "vW295cfeF44KIiDEWnsKAWNzrFm9Py/O3Dq+ZLfLh9c=")
	end)
end)