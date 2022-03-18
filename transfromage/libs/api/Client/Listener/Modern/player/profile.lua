------------------------------------------- Optimization -------------------------------------------
local string_toNickname = string.toNickname
----------------------------------------------------------------------------------------------------

local onProfileLoaded = function(self, packet, connection, identifiers)
	local data = { }
	data.playerName = packet:readUTF()
	data.id = packet:read32()
	data.registrationDate = packet:read32()
	data.role = packet:read8() -- enum.role

	data.gender = packet:read8() -- enum.gender
	data.tribeName = packet:readUTF()
	data.soulmate = string_toNickname(packet:readUTF())

	data.saves = { }
	data.saves.normal = packet:read32()
	data.shamanCheese = packet:read32()
	data.firsts = packet:read32()
	data.cheese = packet:read32()
	data.cheeses = data.cheese -- alias
	data.saves.hard = packet:read32()
	data.bootcamps = packet:read32()
	data.saves.divine = packet:read32()

	data.skillessSaves = { }
	data.skillessSaves.normal = packet:read32()
	data.skillessSaves.hard = packet:read32()
	data.skillessSaves.divine = packet:read32()

	data.titleId = packet:read16()
	data.totalTitles = packet:read16()
	local titles = { }
	for i = 1, data.totalTitles do
		titles[packet:read16()] = packet:read8() -- id, stars
	end
	data.titles = titles

	data.look = packet:readUTF()

	data.level = packet:read16()

	data.totalBadges = packet:read16() / 2
	local badges = { }
	for i = 1, data.totalBadges do
		badges[packet:read16()] = packet:read16() -- id, quantity
	end
	data.badges = badges

	data.totalModeStats = packet:read8()
	local modeStats, mode = { }
	for i = 1, data.totalModeStats do
		mode = packet:read8()
		modeStats[mode] = { }
		mode = modeStats[mode]

		mode.progress = packet:read32()
		mode.progressLimit = packet:read32()
		mode.imageId = packet:read16()
	end
	data.modeStats = modeStats

	data.orbId = packet:read8()
	data.totalOrbs = packet:read8()
	local orbs = { }
	for i = 1, data.totalOrbs do
		orbs[packet:read8()] = true -- Can't be optimized because totalOrbs may be < 2
	end
	data.orbs = orbs

	packet:readBool()

	data.adventurePoints = packet:read32()

	--[[@
		@name profileLoaded
		@desc Triggered when the profile of an player is loaded.
		@param data<table> The player profile data.
		@struct @data {
			playerName = "", -- The player's name.
			id = 0, -- The player id. It may be 0 if the player has no avatar.
			registrationDate = 0, -- The timestamp of when the player was created.
			role = 0, -- An enum from enum.role that specifies the player's role.
			gender = 0, -- An enum from enum.gender for the player's gender.
			tribeName = "", -- The name of the tribe.
			soulmate = "", -- The name of the soulmate.
			saves = {
				normal = 0, -- Total saves in normal mode.
				hard = 0, -- Total saves in hard mode.
				divine = 0 -- Total saves in divine mode.
			}, -- Total saves of the player.
			shamanCheese = 0, -- Number of cheese gathered as shaman.
			firsts = 0, -- Number of firsts.
			cheese = 0, -- Number of cheese gathered.
			bootcamps = 0, -- Number of bootcamps completed.
			titleId = 0, -- The id of the current title.
			totalTitles = 0, -- Number of titles unlocked.
			titles = {
				[id] = 0 -- The id of the title as index, the number of stars as value.
			}, -- The list of unlocked titles.
			look = "", -- The player's outfit code.
			level = 0, -- The player's level.
			totalBadges = 0, -- Number of unlocked badges.
			badges = {
				[id] = 0 -- The id of the badge as index, the quantity as value.
			}, -- The list of unlocked badges.
			totalModeStats = 0, -- The total of mode statuses.
			modeStats = {
				[id] = {
					progress = 0, -- The current score in the status.
					progressLimit = 0, -- The status score limit.
					imageId = 0 -- The image id of the status.
				} -- The status id.
			}, -- The list of mode statuses.
			orbId = 0, -- The id of the current shaman orb.
			totalOrbs = 0, -- Number of shaman orbs unlocked.
			orbs = {
				[id] = true -- The id of the shaman orb as index.
			}, -- The list of unlocked shaman orbs.
			adventurePoints = 0 -- Number of adventure points.
		}
	]]
	self.event:emit("profileLoaded", data)
end

return { onProfileLoaded, 8, 16 }