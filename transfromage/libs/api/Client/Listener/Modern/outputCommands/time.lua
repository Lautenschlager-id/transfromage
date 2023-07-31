------------------------------------------- Optimization -------------------------------------------
local tonumber = tonumber
----------------------------------------------------------------------------------------------------

local onTime = function(self, packet, connection, identifiers)
	packet:read8() -- ?
	packet:readUTF() -- $TempsDeJeu
	packet:read8() -- Total parameters (useless?)

	local time = { }
	time.day = tonumber(packet:readUTF())
	time.hour = tonumber(packet:readUTF())
	time.minute = tonumber(packet:readUTF())
	time.second = tonumber(packet:readUTF())

	--[[@
		@name time
		@desc Triggered when the command /time is requested.
		@param time<table> The account's time data.
		@struct @param {
			day = 0, -- Total days
			hour = 0, -- Total hours
			minute = 0, -- Total minutes
			second = 0 -- Total seconds
		}
	]]
	self.event:emit("time", time)
end

return { onTime, 6, 20 }