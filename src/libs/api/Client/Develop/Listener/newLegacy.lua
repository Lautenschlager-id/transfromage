local legacyListener = require("Client/Listener/Legacy/init")

local Client = require("api/Client/init")
local ByteArray = require("classes/ByteArray")

local createListener = require("Client/utils/createListener")

------------------------------------------- Optimization -------------------------------------------
local coroutine_makef = coroutine.makef
local table_copy = table.copy
----------------------------------------------------------------------------------------------------

--[[@
	@name insertOldPacketListener
	@desc Inserts a new function to the old packet parser.
	@param C<int> The C packet.
	@param CC<int> The CC packet.
	@param f<function> The function to be triggered when the @C-@CC packets are received. The parameters are (self, data, connection, oldIdentifiers).
	@param append?<boolean> 'true' if the function should be appended to the (C, CC) listener, 'false' if the function should overwrite the (C, CC) listener. @default false
]]
Client.insertLegacyListener = function(self, C, CC, f, append, coro)
	local currentListener = legacyListener[C]
	currentListener = currentListener and currentListener[CC]

	local finalListener = f

	if coro then
		finalListener = coroutine_makef(f)
	end

	if append and currentListener then
		local unappendedFinalListener = finalListener

		finalListener = function(data, ...)
			currentListener(table_copy(data), ...)
			unappendedFinalListener(data, ...)
		end
	end

	createListener(legacyListener, C, CC, finalListener)
end