local enum = require("api/enum/init")

--[[@
	@name identifier
	@desc The action identifiers (identifiers, Tribulle, ...) for packets.
	@type table
]]
enum.identifier = enum {
	bulle                  = enum { 60, 03 },
	bulleConnection        = enum { 44, 01 },
	cafeData               = enum { 30, 40 },
	cafeState              = enum { 30, 45 },
	cafeLike               = enum { 30, 46 },
	cafeLoadData           = enum { 30, 41 },
	cafeNewTopic           = enum { 30, 44 },
	cafeSendMessage        = enum { 30, 43 },
	command                = enum { 06, 26 },
	correctVersion         = enum { 26, 03 },
	emote                  = enum { 08, 01 },
	emoticon               = enum { 08, 05 },
	heartbeat              = enum({ 26, 26 }, true),
	initialize             = enum { 28, 01 },
	joinTribeHouse         = enum { 16, 01 },
	acceptTribeHouseInvite = enum { 16, 02 },
	language               = enum { 176, 01 },
	loadLua                = enum { 29, 01 },
	loginSend              = enum { 26, 08 },
	modList                = enum { 26, 05 },
	os                     = enum { 28, 17 },
	packetOffset           = enum { 44, 22 },
	room                   = enum { 05, 38 },
	roomList               = enum { 26, 35 },
	roomMessage            = enum({ 06, 06 }, true),
	roomPassword           = enum { 05, 39 },
	shopState              = enum { 08, 20 }
}

--[[@
	@name setting
	@desc Miscellaneous connection settings.
	@type *
]]
enum.setting = {
	mainIP      = "37.187.29.8",
	port        = { 11801, 12801, 13801, 14801 },
	gameVersion = 666
}

--[[@
	@name url
	@desc URLs used in the API.
	@type string
]]
enum.url = enum {
	translation  = "http://transformice.com/langues/tfm-%s.gz",
	gameSettings = "https://cheese.formice.com/api/tfm/ip",
	apiPackage   = "https://raw.githubusercontent.com/Lautenschlager-id/Transfromage/master/\z
		package.lua"
}
