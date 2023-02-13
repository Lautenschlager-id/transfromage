------------------------------------------- Optimization -------------------------------------------
local fs_readdirSync = require("fs").readdirSync
local require        = require
local string_sub     = string.sub
----------------------------------------------------------------------------------------------------

--[[@
	@name folderLoader
	@desc Loads all files in a specifc path.
	@param path<string> A path in the API's source with .lua files.
	@param asArray?<boolean> Whether the return value should be an array or an object. @default false
	@returns table A list or object of the required data.
	@returns table A list of folders required.
]]
local folderLoader = function(path, asArray)
	path = path .. "/"

	local data = fs_readdirSync("deps/transfromage/libs/" .. path) -- scandir is slower

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
			if name ~= "_internal" and string_sub(name, 1, 1) ~= '.' then
				totalFolders = totalFolders + 1
				folders[totalFolders] = path .. name
			end
		end
	end

	return files, folders
end

return folderLoader