-- Using v1.5.0
-- This bot is going to join its tribe house and
-- spawn a different textarea (using lua) 10 times
-- and then leave the room.

local transfromage = require("transfromage")
local client = transfromage.client()

local timer = require("timer")

client:once("ready", function()
	print("Ready to connect!")
	client:connect("NICKNAME#0000", "PASSWORD")
end)

client:once("connection", function()
	print("Connected!")
	client:joinTribeHouse()
end)

client:on("joinTribeHouse", function()
	local uses, t = 0
	t = timer.setInterval(10 * 1000, function()
		uses = uses + 1
		if uses == 10 then
			timer.clearInterval(t)
			-- Leaving the room after the 10th
			timer.setTimeout(1 * 1000, function()
				client:enterRoom("*#bolodefchoco")
			end)
		end

		client:loadLua("ui.addTextArea(" .. uses .. ", '', nil, math.random(100, 700), math.random(100, 300), math.random(100, 300), math.random(100, 300), math.random(0xFFFFFF), math.random(0xFFFFFF), 1, true)")
	end)
end)

client:start("PLAYER_ID", "API_TOKEN")
