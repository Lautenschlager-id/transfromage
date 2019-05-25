local http = require("coro-http")
local enum = require("enum")
local zlibDecompress = require("miniz").inflate

local cache = {
	--[language] = { data }
	_format = { }, -- Formated line ( %1 → %s )
	_gender = { }, -- Gender line ( "a(b|c)" → { "ab", "ac" } )
	_verified = { } -- Lines without nested default verified, ( != "@language" )
}

local translation = { }
--[[@
	@desc Downloads a Transformice language file.
	@param language<enum.language> An enum from @see language. (index or value) @default en
]]
translation.download = coroutine.makef(function(language)
	language = enum._validate(enum.language, enum.language.en, language, string.format(enum.error.invalidEnum, "download", "language", "language"))
	if not language then return end

	local head, body = http.request("GET", "http://transformice.com/langues/tfz_" .. language)
	if head.code ~= 200 then -- The enum must prevent it, but we never know
		return error("↑failure↓[TRANSLATION]↑ Language ↑highlight↓" .. language .. "↑ could not be downloaded. File not found in Transformice archives.", enum.errorLevel.low)
	end

	body = zlibDecompress(body, 1) -- Decodes
	body = string.utf8(body) -- Makes it UTF8 (Lua's gmatch can't handle it)

	local data = { } -- Resets

	local tmpData, index, value = ''
	-- data = string.split(body, "[^¤]+")
	for char = 1, #body do
		if body[char] == '¤' then
			index, value = string.match(tmpData, "^(.-)=(.*)$")
			data[index] = value
			tmpData = ''
		else
			tmpData = tmpData .. body[char]
		end
	end

	cache[language] = data
end)
--[[@
	@desc Deletes translation lines that are not going to be used. (Saves process)
	@desc If the whitelist parameters are not set, it will delete the whole translation data.
	@param language<enum.language> An enum from @see language that was downloaded before.
	@param whitelist?<table> A set ([index]=true) of indexes that must not be deleted.
	@param whitelistPattern?<string> A pattern to match various indexes at once, these indexes won't be deleted.
]]
translation.free = function(language, whitelist, whitelistPattern)
	language = string.lower(language)
	if not cache[language] then
		return error("↑failure↓[TRANSLATION]↑ Language ↑highlight↓" .. language .. "↑ was not downloaded yet.", enum.errorLevel.low)
	end

	if not whitelist and not whitelistPattern then
		cache[language] = nil
		cache._format[language] = nil
		cache._gender[language] = nil
		return
	end

	for code in next, cache[language] do
		if (whitelist and not whitelist[code]) or (whitelistPattern and not string.find(code, whitelistPattern)) then
			cache[language][code] = nil
			if cache._format[language] then
				cache._format[language][code] = nil
			elseif cache._gender[language] then
				cache._gender[language][code] = nil
			end
		end
	end
end
--[[@
	@desc Gets a translation line.
	@param language<enum.language> An enum from @see language that was downloaded before.
	@param index?<string> The code of the translation line.
	@param raw?<boolean> Whether the translation line must be sent in raw mode or filtered. @default false
	@returns string,table The translation line. If @index is nil, then it's the translation table (index = value). If @index exists, it may be the string, or @raw string, or a table if it has gender differences ({ male, female }). It may not exist.
	@returns boolean,nil If not @raw, the value is a boolean true if return #1 is table.
]]
translation.get = function(language, index, raw)
	language = string.lower(language)
	if not cache[language] then
		return error("↑failure↓[TRANSLATION]↑ Language ↑highlight↓" .. language .. "↑ was not downloaded yet.", enum.errorLevel.low)
	end

	if not index then
		return table.copy(cache[language])
	end
	if cache[language][index] then
		if raw then
			return cache[language][index]
		end

		-- Default values from other communities (@en, @fr) are handled if the translation table was downloaded
		local formatValue = cache[language][index]
		if not (cache._verified[language] and cache._verified[language][index]) then
			local depLang = string.match(formatValue, "^@(..)$")
			if depLang then
				if cache[depLang] and cache[depLang][index] then
					formatValue = cache[depLang][index]
				end
			else
				if not cache._verified[language] then
					cache._verified[language] = { }
				end	
				if not cache._verified[language][index] then
					cache._verified[language][index] = true
				end
			end
		end

		-- Changes %%%d to %d, so it can be constructed with string.format
		if not cache._format[language] then
			cache._format[language] = { }
		end
		if not cache._format[language][index] then
			cache._format[language][index] = string.gsub(formatValue, "%%%d", "%s")
		end

		-- Handles the gender system (male|female)
		if not (cache._gender[language] and cache._gender[language][index] == false) and string.find(cache._format[language][index], '|', nil, true) then
			if not cache._gender[language] then
				cache._gender[language] = { }
			end

			if not cache._gender[language][index] then
				local male, changes = string.gsub(cache._format[language][index], "%((.-)|.-%)", "%1")
				local female = string.gsub(cache._format[language][index], "%(.-|(.-)%)", "%1")
				cache._gender[language][index] = (changes > 0 and  ({ male, female }) or false) -- Cache possible non-translated lines with |
			end

			if cache._gender[language][index] then
				return table.copy(cache._gender[language][index]), true
			end
		end

		return cache._format[language][index], false
	end
end

return translation