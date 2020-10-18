local Client = require("./Client/init")

local createListener = require("./Client/utils/_internal/createListener")
local folderLoader = require("utils/folderLoader")

------------------------------------------- Optimization -------------------------------------------
local require   = require
local table_add = table.add
local type      = type
----------------------------------------------------------------------------------------------------

-- Tools
folderLoader("api/Client/utils")

-- Init Listeners
local _, listenerTypes = folderLoader("api/Client/Listener")

local listenerObjects = { }
for t = 1, #listenerTypes do
	listenerObjects[t] = require(listenerTypes[t] .. "/init")
end

-- Get Listeners
local listeners
local files, folders

for t = 1, #listenerTypes do
	listeners = { }

	files, folders = folderLoader(listenerTypes[t], true)
	table_add(listeners, files) -- legacy and tribulle from modern

	for f = 1, #folders do
		files = folderLoader(folders[f], true)
		table_add(listeners, files)
	end

	-- Create Listeners
	t = listenerObjects[t]
	for l = 1, #listeners do
		l = listeners[l]
		if type(l[1]) == "table" then
			for sl = 1, #l do
				sl = l[sl]
				createListener(t, sl[1], sl[2], sl[3])
			end
		else
			createListener(t, l[1], l[2], l[3]) -- l[3] may be nil when tribulle
		end
	end
end

-- Create Senders
_, folders = folderLoader("api/Client/Sender")

for f = 1, #folders do
	folderLoader(folders[f], true)
end

return Client