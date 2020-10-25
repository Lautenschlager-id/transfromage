local uv = require("uv")

local killConnections = require("./killConnections")

------------------------------------------- Optimization -------------------------------------------
local os_exit          = os.exit
local timer_setTimeout = require("timer").setTimeout
local uv_new_signal    = uv.new_signal
local uv_signal_start  = uv.signal_start
----------------------------------------------------------------------------------------------------

local clients, totalClients = { }, 0

local isKillingProcess = false
local killProcess = function()
	if isKillingProcess then return end
	isKillingProcess = true

	for c = 1, totalClients do
		killConnections(clients[c])
	end

	timer_setTimeout(100, os_exit)
end

local isListeningSigterm = false
local killOnSigterm = function(client)
	if isListeningSigint then
		-- Adds new client to the list
		totalClients = totalClients + 1
		clients[totalClients] = client
		return
	end
	isListeningSigint = true

	uv_signal_start(uv_new_signal(), "sigint", killProcess)
	uv_signal_start(uv_new_signal(), "sighup", killProcess)
end

return killOnSigterm