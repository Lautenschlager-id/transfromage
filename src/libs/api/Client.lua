local Client = require("Client/init")

local folderLoader = require("utils/folderLoader")

local createListener = require("api/Client/utils/createListener")

-- Optimization --
local table_add = table.add
------------------

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
		createListener(t, l[1], l[2], l[3]) -- l[3] may be nil when tribulle
	end
end

-- Create Senders
_, folders = folderLoader("api/Client/Sender")

for f = 1, #folders do
	folderLoader(folders[f], true)
end

return Client