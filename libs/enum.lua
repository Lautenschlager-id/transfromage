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
				index = __index(index)
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
	message        = e { 60, 03 },
	command        = e { 06, 26 },
	community      = e { 08, 02 },
	correctVersion = e { 26, 03 },
	heartbeat      = e({ 26, 26 }, nil, true),
	initialize     = e { 28, 01 },
	joinTribeHouse = e { 16, 01 },
	login          = e { 26, 08 },
	loadLua        = e { 29, 01 },
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
	bu = 24,
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
	cz = 24,
	sk = 25,
	hr = 26,
	bg = 27,
	lv = 28,
	he = 29,
	it = 30,
	et = 31,
	az = 32,
	pt = 33
}

--[[@
	@desc Miscellaneous connection settings.
	@type table
]]
enum.setting = e {
	port = e { 3724, 6112, 44444, 44440, 5555, 443 }
}

return enum