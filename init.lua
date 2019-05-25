require("extensions")

do
	local isSemi
	local update = io.open("autoupdate", 'r') or io.open("autoupdate.txt", 'r')
	if not update then
		update = io.open("semiautoupdate", 'r') or io.open("semiautoupdate.txt", 'r')
		isSemi = true
	end

	if update then
		update:close()

		coroutine.wrap(function()
			local pkg = require("deps/transfromage/package")
			if pkg then
				local version = pkg.version
				local _, lastVersion = require("coro-http").request("GET", "https://raw.githubusercontent.com/Lautenschlager-id/Transfromage/master/package.lua")
				if lastVersion then
					lastVersion = string.match(lastVersion, "version = \"(.-)\"")
					if version ~= lastVersion then
						local confirmation
						if isSemi then
							repeat
								os.log("↑info↓[UPDATE]↑ New version ↑highlight↓Transfromage@" .. lastVersion .. "↑ available.")
								os.log("↑info↓[UPDATE]↑ Update it now? ( ↑success↓Y↑ / ↑error↓N↑ )")
								confirmation = string.upper(io.read())
							until confirmation == 'N' or confirmation == 'Y'
						else
							confirmation = 'Y'
						end

						if confirmation == 'Y' then
							for i = 1, #pkg.files do
								os.remove("deps/transfromage/" .. pkg.files[i]) -- avoids permissions error
							end
							os.execute("lit install Lautenschlager-id/transfromage") -- Installs the new lib
							os.execute("luvit " .. table.concat(args, ' ')) -- Luvit's command
							return os.exit()
						end
					end
				end
			else
				os.log("↑failure↓[WARNING]↑ Could not find the file ↑highlight↓package.lua↑.")
			end
		end)()
	end
end

return {
    client = require("client"),
    enum = require("enum"),
    byteArray = require("bArray"),
    encode = require("encode"),
    translation = require("translation")
}