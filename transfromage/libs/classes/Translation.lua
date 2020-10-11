local enum = require("api/enum")

------------------------------------------- Optimization -------------------------------------------
local enum_error      = enum.error
local enum_errorLevel = enum.errorLevel
local enum_language   = enum.language
local enum_url        = enum.url
local enum_validate   = enum._validate
local http_request    = require("coro-http").request
local next            = next
local setmetatable    = setmetatable
local string_find     = string.find
local string_format   = string.format
local string_gsub     = string.gsub
local string_match    = string.match
local string_split    = string.split
local table_copy      = table.copy
local zlibDecompress  = require("miniz").inflate
----------------------------------------------------------------------------------------------------

local downloadedTranslations = { }

local getOfficialTranslationsData = coroutine.makef(function(language)
	local head, body = http_request("GET", string_format(enum_url.translation, language))
	if head.code ~= 200 then -- The enum must prevent it, but we never know
		return error(enum_error.translationFailure, enum_errorLevel.low, language)
	end

	body = zlibDecompress(body, 1) -- Decodes

	return string_split(body, "\n-\n", true)
end)

local Translation = table.setNewClass("Translation")

--[[@
	@name translation.download
	@desc Downloads a Transformice language file.
	@param language<enum.language> An enum from @see language. (index or value) @default en
	@param f?<function> A function to be executed when the language is downloaded.
	@returns boolean,nil Whether the language has been downloaded.
]]
Translation.new = function(self, language, onDownload)
	language = enum_validate(enum_language, enum_language.en, language,
		string_format(enum_error.invalidEnum, "download", "language", "language"))
	if not language then return end

	-- Caches all translation lines
	local body, totalLines = getOfficialTranslationsData(language)

	local data = { }

	local index, value
	for content = 1, totalLines do
		content = body[content]
		if content ~= '' then
			index, value = string_match(content, "^(.-)=(.*)$")
			data[index] = value
		end
	end

	local translation = setmetatable({
		language = language,
		data = data,
		_dataWithLuaFormatting = { }, -- Formatted line ( %1 → %s )
		_dataWithGendersHandled = { }, -- Gender line ( "a(b|c)" → { "ab", "ac" } )
		_indexWithDependentLangChecked = { } -- Lines without nested default verified, ( != "@language" )
	}, self)

	downloadedTranslations[language] = translation

	if onDownload then
		onDownload(translation)
	end

	return translation
end

--[[@
	@name translation.free
	@desc Deletes translation lines that are not going to be used. (Saves process)
	@desc If the whitelist parameters are not set, it will delete the whole translation data.
	@param language<enum.language> An enum from @see language that was downloaded before.
	@param whitelist?<table> A set ([index]=true) of indexes that must not be deleted.
	@param whitelistPattern?<string> A pattern to match various indexes at once, these indexes won't be deleted.
	@returns boolean,nil Whether the given data got deleted successfully.
]]
Translation.free = function(self, whitelist, whitelistPattern)
	if not whitelist and not whitelistPattern then
		downloadedTranslations[self.language] = nil
		return true
	end

	local data = self.data
	local dataWithLuaFormatting = self._dataWithLuaFormatting
	local dataWithGendersHandled = self._dataWithGendersHandled
	local indexWithDependentLangChecked = self._indexWithDependentLangChecked

	for code in next, data do
		if not (whitelist and whitelist[code])
			and not (whitelistPattern and string_find(code, whitelistPattern)) then
			data[code] = nil
			dataWithLuaFormatting[code] = nil
			dataWithGendersHandled[code] = nil
			indexWithDependentLangChecked[code] = nil
		end
	end

	return self
end

local checkDependentLanguageForIndex = function(translation, index)
	-- Default values from other communities (@en, @fr) are handled if the translation table was downloaded
	local indexWithDependentLangChecked = translation._indexWithDependentLangChecked

	local rawValue = translation.data[index]

	if not indexWithDependentLangChecked[index] then
		local dependentLanguage = string_match(rawValue, "^@(%w%w)$")

		if dependentLanguage then
			local downloadedTranslation = downloadedTranslations[dependentLanguage]

			if downloadedTranslation and downloadedTranslation[index] then
				return downloadedTranslation[index]
			end
		else
			if not indexWithDependentLangChecked[index] then
				indexWithDependentLangChecked[index] = true
			end
		end
	end

	return rawValue
end

local formatDataAsLua = function(self, rawValue)
	-- Changes %%%d to %d, so it can be constructed with string_format
	local dataWithLuaFormatting = self._dataWithLuaFormatting

	if not dataWithLuaFormatting[index] then
		rawValue = string_gsub(rawValue, "%%%d", "%s")
		dataWithLuaFormatting[index] = rawValue
	end

	return rawValue
end

local handleGenders = function(self)
	-- Handles the gender system (male|female)
	local dataWithGendersHandled = self._dataWithGendersHandled

	if dataWithGendersHandled[index] == false
		or not string_find(dataWithGendersHandled[index], '|', nil, true) then return end

	if not dataWithGendersHandled[index] then
		local dataWithLuaFormatting = self._dataWithLuaFormatting[index]

		local male, changes = string_gsub(dataWithLuaFormatting, "%((.-)|.-%)", "%1")
		local female = string_gsub(dataWithLuaFormatting, "%(.-|(.-)%)", "%1")

		-- Cache possible non-translated lines with |
		dataWithGendersHandled[index] = (changes > 0 and { male, female } or false)
	end

	if dataWithGendersHandled[index] then
		return table_copy(dataWithGendersHandled[index]), true
	end
end

--[[@
	@name translation.get
	@desc Gets a translation line.
	@param language<enum.language> An enum from @see language that was downloaded before.
	@param index?<string> The code of the translation line.
	@param raw?<boolean> Whether the translation line must be sent in raw mode or filtered. @default false
	@returns string,table The translation line. If @index is nil, then it's the translation table (index = value). If @index exists, it may be the string, or @raw string, or a table if it has gender differences ({ male, female }). It may not exist.
	@returns boolean,nil If not @raw, the value is a boolean true if return #1 is table.
]]
Translation.get = function(self, index, raw)
	local data = self.data

	if not index then
		return table_copy(data)
	end

	if data[index] then
		if raw then
			return data[index]
		end

		local rawValue = checkDependentLanguageForIndex(self, index)

		rawValue = formatDataAsLua(self, rawValue)

		local formattedValue, hasGender = handleGenders(self, rawValue)

		return formattedValue or rawValue, hasGender
	end
end

--[[@
	@name translation.set
	@desc Sets the value of translation codes.
	@param language<enum.language> An enum from @see language that was downloaded before.
	@param setPattern<string> The pattern to match all translation line codes that will be edited.
	@param f<function> The function to be executed over the current translation line. Receives (value, code).
	@oaram isPlain?<boolean> Whether the pattern is plain (no pattern) or not. @default false
	@returns boolean,nil Whether the given daata was set successfully.
]]
Translation.set = function(self, setPattern, f, isPlain)
	local data = self.data
	local dataWithLuaFormatting = self._dataWithLuaFormatting
	local dataWithGendersHandled = self._dataWithGendersHandled
	local indexWithDependentLangChecked = self._indexWithDependentLangChecked

	for code, value in next, data do
		if string_find(code, setPattern, nil, isPlain) then
			data[code] = f(value, code)

			dataWithLuaFormatting[code] = nil
			dataWithGendersHandled[code] = nil
			indexWithDependentLangChecked[code] = nil
		end
	end

	return self
end

return Translation