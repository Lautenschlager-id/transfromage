local fs = require("fs")

------------------------------------------- Optimization -------------------------------------------
local coroutine_wrap = coroutine.wrap
local fs_scandirSync = fs.scandirSync
local fs_rmdirSync = fs.rmdirSync
local io_read = io.read
local os_execute = os.execute
local os_exit = os.exit
local os_remove = os.remove
local require = require
local string_lower = string.lower
local string_match = string.match
local table_concat = table.concat
----------------------------------------------------------------------------------------------------

local APISettings = require("./settings")
local APIPackage = require("./package")

repeat
	local update = APISettings.update
	if not update then break end
	update = string_lower(update)

	local http_request = require("coro-http").request
	local isLatestVersion = coroutine_wrap(function()
		local _, githubAPIPackage = http_request("GET", "https://raw.githubusercontent.com/\z
			Lautenschlager-id/Transfromage/master/package.lua")

		local lastReleasedVersion = string_match(githubAPIPackage, "version = \"(.-)\"")
		return APIPackage.version == lastReleasedVersion
	end)

	if isLatestVersion() then break end

	local performUpdate = (update == "auto")
	if update == "ask" then
		repeat
			os_log("↑info↓[UPDATE]↑ New version ↑highlight↓Transfromage@" .. lastVersion .. "↑ \z
				available.")
			os_log("↑info↓[UPDATE]↑ Update it now? ( ↑success↓Y↑ / ↑error↓N↑ )")
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
		deleteCurrentFiles("deps/transfromage")

		-- Installs the updated version of the API
		os_execute("lit install Lautenschlager-id/transfromage")

		-- Executes everything again
		os_execute("luvit " .. table_concat(args, ' '))

		os_exit()
	end

	installLatestVersion()
until true

return APIPackage.version