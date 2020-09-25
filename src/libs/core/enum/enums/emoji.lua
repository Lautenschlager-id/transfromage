local enum = require("enum/init")

--[[@
	@name emote
	@desc The available emote IDs.
	@type int
]]
enum.emote = enum {
	dance               = 00,
	laugh               = 01,
	cry                 = 02,
	kiss                = 03,
	angry               = 04,
	clap                = 05,
	sleep               = 06,
	facepaw             = 07,
	sit                 = 08,
	confetti            = 09,
	flag                = 10,
	marshmallow         = 11,
	selfie              = 12,
	highfive            = 13,
	highfive_1          = 14,
	highfive_2          = 15,
	partyhorn           = 16,
	hug                 = 17,
	hug_1               = 18,
	hug_2               = 19,
	jigglypuff          = 20,
	kissing             = 21,
	kissing_1           = 22,
	kissing_2           = 23,
	carnaval            = 24,
	rockpaperscissors   = 25,
	rockpaperscissors_1 = 26,
	rockpaperscissor_2  = 27
}

--[[@
	@name emoticon
	@desc The available emoticon IDs.
	@type int
]]
enum.emoticon = enum {
	smiley    = 0,
	sad       = 1,
	tongue    = 2,
	angry     = 3,
	laugh     = 4,
	shades    = 5,
	blush     = 6,
	sweatdrop = 7,
	derp      = 8,
	OMG       = 9
}