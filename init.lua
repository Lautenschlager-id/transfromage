require("extensions")

-- Optimization --
local coroutine_wrap = coroutine.wrap
local io_open = io.open
local io_read = io.read
local os_execute = os.execute
local os_exit = os.exit
local os_log = os.log
local os_remove = os.remove
local string_match = string.match
local string_upper = string.upper
local table_concat = table.concat
------------------

local pkg = require("package")

do
	local isSemi
	local update = io_open("autoupdate", 'r') or io_open("autoupdate.txt", 'r')
	if not update then
		update = io_open("semiautoupdate", 'r') or io_open("semiautoupdate.txt", 'r')
		isSemi = true
	end

	if update then
		update:close()

		coroutine_wrap(function()
			local version = pkg.version
			local _, lastVersion = require("coro-http").request("GET", "https://raw.githubusercontent.com/Lautenschlager-id/Transfromage/master/package.lua")
			if lastVersion then
				lastVersion = string_match(lastVersion, "version = \"(.-)\"")
				if version ~= lastVersion then
					local confirmation
					if isSemi then
						repeat
							os_log("↑info↓[UPDATE]↑ New version ↑highlight↓Transfromage@" .. lastVersion .. "↑ available.")
							os_log("↑info↓[UPDATE]↑ Update it now? ( ↑success↓Y↑ / ↑error↓N↑ )")
							confirmation = string_upper(io_read())
						until confirmation == 'N' or confirmation == 'Y'
					else
						confirmation = 'Y'
					end

					if confirmation == 'Y' then
						for i = 1, #pkg.files do
							os_remove("deps/transfromage/" .. pkg.files[i]) -- avoids permissions error
						end
						os_execute("lit install Lautenschlager-id/transfromage") -- Installs the new lib
						os_execute("luvit " .. table_concat(args, ' ')) -- Luvit's command
						return os_exit()
					end
				end
			end
		end)()
	end
end

return {
	version = (pkg and pkg.version or nil),
	client = require("client"),
	enum = require("enum"),
	byteArray = require("bArray"),
	encode = require("encode"),
	translation = require("translation")
}
