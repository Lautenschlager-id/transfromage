------------------------------------------- Optimization -------------------------------------------
local setmetatable = setmetatable
local string_sub   = string.sub
local table_copy   = table.copy
----------------------------------------------------------------------------------------------------

local Player = table.setNewClass("Player")

Player.new = function(self, playerName)
	return setmetatable({
		playerName = playerName,
		id = nil,
		isShaman = nil,
		isDead = nil,
		score = nil,
		hasCheese = nil,
		title = nil,
		titleStars = nil,
		gender = nil,
		look = nil,
		mouseColor = nil,
		shamanColor = nil,
		nameColor = nil,
		isSouris = nil,
		isVampire = nil,
		hasWon = nil,
		winPosition = nil,
		winTimeElapsed = nil,
		movingRight = nil,
		movingLeft = nil,
		isBlueShaman = nil,
		isPinkShaman = nil,
		x = nil,
		y = nil,
		vx = nil,
		vy = nil,
		isDucking = nil,
		isJumping = nil,
		_index = nil
	}, self)
end

Player.update = function(self, packet)
	self.id = packet:read32() -- Temporary id

	self.isShaman = packet:readBool()
	self.isDead = packet:readBool()

	self.score = packet:read16()

	self.hasCheese = packet:readBool()

	self.title = packet:read16()
	self.titleStars = packet:read8() - 1

	self.gender = packet:read8()

	packet:readUTF() -- ?

	self.look = packet:readUTF() -- Class Shop/Outfit? : Outfit:new():load(packet, i)

	packet:readBool() -- ?

	self.mouseColor = packet:read32()
	self.shamanColor = packet:read32()

	packet:read32() -- ?

	local color = packet:read32()
	self.nameColor = (color == 0xFFFFFFFF and -1 or color)

	-- Custom or non-updated data
	self.isSouris = (string_sub(self.playerName, 1, 1) == '*')
	self.isVampire = false

	self.hasWon = false
	self.winPosition = -1
	self.winTimeElapsed = -1

	self.movingRight = false
	self.movingLeft = false

	self.isBlueShaman = false
	self.isPinkShaman = false

	self.x = 0
	self.y = 0
	self.vx = 0
	self.vy = 0

	self.isDucking = false
	self.isJumping = false

	return self
end

Player.copy = function(self)
	return table_copy(self, true)
end

return Player