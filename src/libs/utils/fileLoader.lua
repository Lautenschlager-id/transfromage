local fs_readdirSync = require("fs").readdirSync

-- Optimization --
local require = require
local string_sub = string.sub
------------------

local folderLoader = function(path, asArray)
	local data = fs_readdirSync(path)

	local totalFiles, totalFolders = 0, 0
	local files, folders = { }, { }

	for name = 1, #data do
		name = data[name]

		if string_sub(name, -4) == ".lua" then -- is file
			name = string_sub(name, 1, -5)

			if name ~= "init" then
				totalFiles = totalFiles + 1
				files[(asArray and totalFiles or name)] = require(path .. name)
			end
		else
			if name ~= "_internal" then
				totalFolders = totalFolders + 1
				folders[totalFolders] = path .. name
			end
		end
	end

	return files, folders
end

return folderLoader