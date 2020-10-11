local enum = require("api/enum/init")

enum.timer = enum({
	listenerLoop     = 0010,
	login            = 3500,
	socketTimeout    = 3500,
	triggerFailLogin = 2000,
}, true)