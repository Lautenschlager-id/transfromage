local enum = require("api/enum/init")

enum.timer = enum({
	listenerLoop     = 0010,
	socketTimeout    = 3500,
	triggerFailLogin = 2000,
}, true)