local Client = require("api/Client/init")

local ByteArray = require("classes/ByteArray")
local createListener = require("api/Client/utils/_internal/createListener")
local modernListener = require("api/Client/Listener/Modern/init")

------------------------------------------- Optimization -------------------------------------------
local coroutine_makef = coroutine.makef
----------------------------------------------------------------------------------------------------

--[[@
	@name insertPacketListener
	@desc Inserts a new function to the packet parser.
	@param C<int> The C packet.
	@param CC<int> The CC packet.
	@param f<function> The function to be triggered when the @C-@CC packets are received. The parameters are (self, packet, connection, identifiers).
	@param append?<boolean> 'true' if the function should be appended to the (C, CC) listener, 'false' if the function should overwrite the (C, CC) listener. @default false
]]
Client.insertModernListener = function(self, C, CC, f, append, coro)
	local currentListener = modernListener[C]
	currentListener = currentListener and currentListener[CC]

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

	createListener(modernListener, finalListener, C, CC)
end