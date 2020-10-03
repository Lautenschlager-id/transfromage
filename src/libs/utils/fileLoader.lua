-- Optimization --
local io_popen = io.popen
local require = require
local string_format = string.format
local string_gmatch = string.gmatch
------------------

local isRunningOnWindows = string.sub(package.config, 1, 1) == '\\'

local osCommand
if isRunningOnWindows then
	-- for %a in ("path/*") do @echo %~na
	osCommand = "for %%a in (\"%s/*\") do @echo %%~na"
else
	-- ls 'path/' -1 | sed -e 's/\..*$//'
	osCommand = "ls '%s/' -1 | sed -e 's/\\..*$//'"
end

local requireFolder = function(pathToFolder)
	-- Assuming the path is valid
	local command = string_format(osCommand, "src/libs/" .. pathToFolder)

	-- Executes the os command and retrieves the output
	local fileExecute = io_popen(command)
	local allFiles = fileExecute:read("*a")
	fileExecute:close()

	local fileData = { }

	pathToFolder = pathToFolder .. "/"
	for file in string_gmatch(allFiles, "%S+") do
		file = pathToFolder .. file
		fileData[file] = require(file)
	end

	return fileData
end

return requireFolder