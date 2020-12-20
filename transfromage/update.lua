local fs = require("fs")

local apiPackage = require("./package")
local enum = require("api/enum")

------------------------------------------- Optimization -------------------------------------------
local fs_scandirSync = fs.scandirSync
local fs_rmdirSync   = fs.rmdirSync
local http_request   = require("coro-http").request
local io_read        = io.read
local logMessages    = enum.logMessages
local enum_url       = enum.url
local os_execute     = os.execute
local os_exit        = os.exit
local os_log         = os.log
local os_remove      = os.remove
local string_lower   = string.lower
local string_match   = string.match
local table_concat   = table.concat
----------------------------------------------------------------------------------------------------

@#IF UPDATE
repeat
	local update = _G.PREPDIR_SETTINGS.UPDATE
	update = string_lower(update)

	local isLatestVersion = coroutine.wrap(function()
		local _, githubAPIPackage = http_request("GET", enum_url.apiPackage)

		local latestReleasedVersion = string_match(githubAPIPackage, "version = \"(.-)\"")
		return apiPackage.version == latestReleasedVersion
	end)

	if isLatestVersion() then break end

	local performUpdate = (update == "auto")
	if update == "permission" then
		repeat
			os_log(logMessages.newVersion, latestVersion)
			os_log(logMessages.confirmUpdate)
			performUpdate = string_lower(io_read())
		until performUpdate == 'n' or performUpdate == 'y'

		if performUpdate == 'n' then break end

		performUpdate = true
	end

	if not performUpdate then break end

	local deleteCurrentFiles
	deleteCurrentFiles = function(path)
		path = path .. "/"

		for element, eType in fs_scandirSync(path) do
			element = path .. element

			if eType == "file" then
				os_remove(element)
			elseif eType == "directory" then
				deleteCurrentFiles(element)
			end
		end

		fs_rmdirSync(path)
	end

	local installLatestVersion = function()
		-- Lit won't update existing files, so all previous files must be deleted first.
		deleteCurrentFiles("deps/Transfromage")

		-- Installs the updated version of the API
		os_execute("lit install Lautenschlager-id/transfromage")

		-- Executes everything again
		os_execute("luvit " .. table_concat(args, ' '))

		os_exit()
	end

	installLatestVersion()
until true
@#ENDIF

return apiPackage.version