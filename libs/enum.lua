-- Optimization --
local debug_traceback = debug.traceback
------------------

local enum = setmetatable({ }, {
	--[[@
		@name enum
		@desc Creates a new enumeration.
		@param list<table> The table that will become an enumeration.
		@param ignoreConflict?<boolean> If the system should ignore value conflicts. (if there are identical values in @list) @default false
		@param __index?<function> A function to handle the __index metamethod of the enumeration. It receives the given index and @list.
		@returns enum A new enumeration.
	]]
	__call = function(_, list, ignoreConflit, __index)
		local reversed = { }

		for k, v in next, list do
			if not ignoreConflit and reversed[v] then
				return error("↑failure↓[ENUM]↑ Enumeration conflict in ↑highlight↓" .. tostring(k)
					.. "↑ and ↑highlight↓" .. tostring(reversed[v]) .. "↑", -2)
			end
			reversed[v] = k
		end

		return setmetatable({ }, {
			__index = function(_, index)
				if __index then
					index = __index(index, list)
				end
				return list[index]
			end,
			__call = function(_, value)
				return reversed[value]
			end,
			__pairs = function()
				return next, list
			end,
			__len = function()
				return #list
			end,
			__newindex = function()
				return error("↑failure↓[ENUM]↑ Can not overwrite enumerations.", -2)
			end,
			__metatable = "enumeration"
		})
	end
})

-- Functions
--[[@
	@name _exists
	@desc Checks whether the inserted enumeration is valid or not.
	@param enumeration<enum> An enumeration object, the source of the value.
	@param value<*> The value (index or value) of the enumeration.
	@returns int,boolean Whether @value is part of @enumeration or not. It's returned 0 if the value is a value, 1 if it is an index, and false if it's not a valid enumeration.
]]
enum._exists = function(enumeration, value)
	if type(enumeration) ~= "table" or getmetatable(enumeration) ~= "enumeration" then
		return false
	end

	-- Value = 0, Index = 1
	if enumeration(value) then -- "00"
		return 0
	elseif enumeration[value] then -- "EN"
		return 1
	end
	return false
end
--[[@
	@name _validate
	@desc Validates an enumeration.
	@param enumeration<enum> An enumeration object, the source of the value.
	@param default<*> The default value of the enumeration
	@param value?<string,number> The value (index or value) of the enumeration.
	@param errorMsg?<string> The error message when the enumeration exists but is invalid.
	@returns * The value associated to the source enumeration, or the default value if nil.
]]
enum._validate = function(enumeration, default, value, errorMsg)
	value = tonumber(value) or value
	if value then
		local exists = enum._exists(enumeration, value)

		if not exists then
			return error((errorMsg or "↑failure↓[ENUM]↑ Invalid enumeration\n" ..
				tostring(debug_traceback())), -2)
		end

		if exists == 1 then
			value = enumeration[value]
		end
	else
		value = default
	end

	return value
end

-- Enums
--[[@
	@name chatCommunity
	@desc The ID of each chat community.
	@type int
]]
enum.chatCommunity = enum {
	en = 01,
	fr = 02,
	ru = 03,
	br = 04,
	es = 05,
	cn = 06,
	tr = 07,
	vk = 08,
	pl = 09,
	hu = 10,
	nl = 11,
	ro = 12,
	id = 13,
	de = 14,
	e2 = 15,
	ar = 16,
	ph = 17,
	lt = 18,
	jp = 19,
	ch = 20,
	fi = 21,
	cz = 22,
	hr = 23,
	sk = 24,
	bg = 25,
	lv = 26,
	he = 27,
	it = 28,
	et = 29,
	az = 30,
	pt = 31
}
--[[@
	@name community
	@desc The ID of each community.
	@type int
]]
enum.community = enum {
	en = 00,
	fr = 01,
	ru = 02,
	br = 03,
	es = 04,
	cn = 05,
	tr = 06,
	vk = 07,
	pl = 08,
	hu = 09,
	nl = 10,
	ro = 11,
	id = 12,
	de = 13,
	e2 = 14,
	ar = 15,
	ph = 16,
	lt = 17,
	jp = 18,
	ch = 19,
	fi = 20,
	cz = 21,
	sk = 22,
	hr = 23,
	bg = 24,
	lv = 25,
	he = 26,
	it = 27,
	et = 29,
	az = 30,
	pt = 31
}
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
--[[@
	@name error
	@desc The API error messages.
	@type string
]]
enum.error = enum {
	invalidEnum = "↑failure↓[%s]↑ ↑highlight↓%s↑ must be a valid ↑highlight↓%s↑ enumeration.",
}
--[[@
	@name errorLevel
	@desc The API error levels.
	@type int
]]
enum.errorLevel = enum {
	low  = -2,
	high = -1
}
--[[@
	@name game
	@desc The ID of each game.
	@type int
]]
enum.game = enum {
	unknown      = 00,
	none         = 01,
	transformice = 04,
	fortoresse   = 06,
	bouboum      = 07,
	nekodancer   = 15,
	deadmaze     = 17
}
--[[@
	@name gender
	@desc The profile gender ID.
	@type int
]]
enum.gender = {
	none   = 0,
	female = 1,
	male   = 2
}
--[[@
	@name identifier
	@desc The action identifiers (identifiers, Tribulle, ...) for packets.
	@type table
]]
enum.identifier = enum {
	bulle           = enum { 60, 03 },
	bulleConnection = enum { 44, 01 },
	cafeData        = enum { 30, 40 },
	cafeState       = enum { 30, 45 },
	cafeLike        = enum { 30, 46 },
	cafeLoadData    = enum { 30, 41 },
	cafeNewTopic    = enum { 30, 44 },
	cafeSendMessage = enum { 30, 43 },
	command         = enum { 06, 26 },
	community       = enum { 08, 02 },
	correctVersion  = enum { 26, 03 },
	emote           = enum { 08, 01 },
	emoticon        = enum { 08, 05 },
	heartbeat       = enum({ 26, 26 }, true),
	initialize      = enum { 28, 01 },
	joinTribeHouse  = enum { 16, 01 },
	loadLua         = enum { 29, 01 },
	loginSend       = enum { 26, 08 },
	modList         = enum { 26, 05 },
	os              = enum { 28, 17 },
	packetOffset    = enum { 44, 22 },
	room            = enum { 05, 38 },
	roomList        = enum { 26, 35 },
	roomMessage     = enum({ 06, 06 }, true)
}
--[[@
	@name language
	@desc The available community translation file communities.
	@type string
]]
enum.language = enum {
	en = "en",
	fr = "fr",
	ru = "ru",
	br = "br",
	es = "es",
	cn = "cn",
	tr = "tr",
	vk = "vk",
	pl = "pl",
	hu = "hu",
	nl = "nl",
	ro = "ro",
	id = "id",
	de = "de",
	ar = "ar",
	ph = "ph",
	lt = "lt",
	jp = "jp",
	ch = "ch",
	fi = "fi",
	cz = "cz",
	sk = "sk",
	hr = "hr",
	bg = "bg",
	lv = "lv",
	he = "he",
	it = "it",
	et = "et",
	az = "az",
	pt = "pt"
}
--[[@
	@name role
	@desc The ID for staff role identifiers.
	@type int
]]
enum.role = enum {
	normal        = 00,
	moderator     = 05,
	administrator = 10,
	mapcrew       = 11,
	funcorp       = 13
}
--[[@
	@name roomMode
	@desc The available room modes.
	@type int
]]
enum.roomMode = enum {
	normal    = 01,
	bootcamp  = 02,
	vanilla   = 03,
	survivor  = 08,
	racing    = 09,
	music     = 10,
	defilante = 11,
	village   = 16,
	module    = 18
}
--[[@
	@name setting
	@desc Miscellaneous connection settings.
	@type *
]]
enum.setting = {
	gameVersion = 666,
	mainIp      = "51.75.130.180",
	port        = { 11801, 12801, 13801, 14801 }
}
--[[@
	@name url
	@desc URLs used in the API.
	@type string
]]
enum.url = enum {
	translation = "http://transformice.com/langues/tfz_%s",
	authKeys    = "https://api.tocu.tk/get_transformice_keys.php?tfmid=%s&token=%s"
}
--[[@
	@name whisperState
	@desc Possible states for the whisper.
	@type int
]]
enum.whisperState = enum {
	enabled        = 1,
	disabledPublic = 2,
	disabledAll    = 3
}

return enum
