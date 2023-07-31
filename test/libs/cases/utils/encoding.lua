local getPasswordHash = require("transfromage/libs/utils/encoding/password")

require("wrapper")(function(test, transfromage, client)
	test("encoding", function(expect)
		p("Validating password")
		assert_eq(getPasswordHash("test1234"), "vW295cfeF44KIiDEWnsKAWNzrFm9Py/O3Dq+ZLfLh9c=",
			"f(test1234)")
	end)
end)