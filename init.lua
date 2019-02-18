if not table.add then
	require("utils")
end

do
	local autoupdate = io.open("autoupdate", 'r') or io.open("autoupdate.txt", 'r')
	local semiupdate = not autoupdate and (io.open("semiautoupdate", 'r') or io.open("semiautoupdate.txt", 'r'))
	if autoupdate or semiupdate then
		if autoupdate then
			autoupdate:close()
		end
		if semiupdate then
			semiupdate:close()
		end

		coroutine.wrap(function()
			local pkg = require("deps/transfromage/package")
			if pkg then
				local version = pkg.version
				local _, lastVersion = require("coro-http").request("GET", "https://raw.githubusercontent.com/Lautenschlager-id/Transfromage/master/package.lua")
				if lastVersion then
					lastVersion = string.match(lastVersion, "version = \"(.-)\"")
					if version ~= lastVersion then
						local toUpdate
						if semiupdate then
							repeat
								print("There is a new version of transfromage available [" .. lastVersion .. "]. Update it now? (Y/N)")
								toUpdate = string.lower(io.read())
							until toUpdate == 'n' or toUpdate == 'y'
						else
							toUpdate = 'y'
						end

						if toUpdate == 'y' then
							for i = 1, #pkg.files do
								os.remove("deps/transfromage/" .. pkg.files[i])
							end
							os.execute("lit install Lautenschlager-id/transfromage") -- Installs the new lib
							os.execute("luvit " .. table.concat(args, ' ')) -- Luvit's command
							return os.exit()
						end
					end
				end
			end
		end)()
	end
end

return {
    client = require("client"),
    enum = require("enum"),
    byteArray = require("byteArray")
}