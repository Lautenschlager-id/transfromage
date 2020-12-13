local Client = require("api/Client/init")

local ByteArray = require("classes/ByteArray")
local createListener = require("api/Client/utils/_internal/createListener")
local tribulleListener = require("api/Client/Listener/Tribulle/init")

------------------------------------------- Optimization -------------------------------------------
local coroutine_makef = coroutine.makef
----------------------------------------------------------------------------------------------------

--[[@
	@name insertTribulleListener
	@desc Inserts a new function to the tribulle (60, 3) packet parser.
	@param tribulleId<int> The tribulle id.
	@param f<function> The function to be triggered when this tribulle packet is received. The parameters are (self, packet, connection, tribulleId).
	@param append?<boolean> 'true' if the function should be appended to the (C, CC, tribulle) listener, 'false' if the function should overwrite the (C, CC) listener. @default false
]]
Client.insertTribulleListener = function(self, tribulleID, f, append, coro)
	local currentListener = tribulleListener[tribulleID]

	local finalListener = f

	if coro ~= false then
		finalListener = coroutine_makef(f)
	end

	if append and currentListener then
		local unappendedFinalListener = finalListener

		finalListener = function(packet, ...)
			currentListener(ByteArray:new(packet.stack), ...)
			unappendedFinalListener(packet, ...)
		end
	end

	createListener(tribulleListener, finalListener, C, CC)
end