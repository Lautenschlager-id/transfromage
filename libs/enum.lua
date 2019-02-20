local e = function(list, __index, ignoreConflit)
	local reversed = { }

	for k, v in next, list do
		if not ignoreConflit and reversed[v] then
			return error("Enumeration conflict in '" .. tostring(k) .. "' and '" .. tostring(reversed[v]) .. "'")
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
			return error("Can not overwrite enumerations.")
		end,
		__metatable = "enumeration"
	})
end

local enum = { }

-- Functions
enum._checkEnum = function(enumeration, value)
	if type(enumeration) ~= "table" then
		return false
	end
	if getmetatable(enumeration) ~= "enumeration" then
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
	@desc The action identifiers (C_CC, Tribulle, ...) for packets.
	@type table
]]
enum.identifier = e {
	bulle          = e { 44, 01 },
	command        = e { 06, 26 },
	community      = e { 08, 02 },
	correctVersion = e { 26, 03 },
	emote          = e { 08, 01 },
	emoticon       = e { 08, 05 },
	heartbeat      = e({ 26, 26 }, nil, true),
	initialize     = e { 28, 01 },
	modList        = e { 26, 05 },
	joinTribeHouse = e { 16, 01 },
	login          = e { 26, 08 },
	loadLua        = e { 29, 01 },
	message        = e { 60, 03 },
	os             = e { 28, 17 },
	packetOffset   = e { 44, 22 },
	room           = e { 05, 38 },
	roomMessage    = e({ 06, 06 }, nil, true)
}

--[[@
	@desc The ID of each community.
	@type int
]]
enum.community = e {
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
	@desc The ID of each chat community.
	@type int
]]
enum.chatCommunity = e {
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
	@desc Miscellaneous connection settings.
	@type table
]]
enum.setting = e {
	port = e { 3724, 6112, 44444, 44440, 5555, 443 }
}

--[[@
	@desc Possible states for the whisper.
	@type int
]]
enum.whisperState = e {
	enabled        = 1,
	disabledPublic = 2,
	disabledAll    = 3
}

--[[@
	@desc The id for staff role identifiers.
	@type int
]]
enum.role = e {
	normal        = 00,
	moderator     = 05,
	administrator = 10,
	mapcrew       = 11,
	funcorp       = 13
}

--[[@
	@desc The profile gender id.
	@type int
]]
enum.gender = {
	none   = 0,
	female = 1,
	male   = 2
}

--[[@
	@desc The available emote ids.
	@type int
]]
enum.emote = e {
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
	@desc The available emoticon ids.
	@type int
]]
enum.emoticon = e {
	OMG       = 0,
	smiley    = 1,
	sad       = 2,
	tongue    = 3,
	angry     = 4,
	[":D"]    = 5,
	shades    = 6,
	blush     = 7,
	sweatdrop = 8,
	derp      = 9
}

return enum