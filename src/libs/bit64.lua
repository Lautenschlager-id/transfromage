-- Thanks to @Turkitutu's samples at https://pastebin.com/raw/Nw3y1A42

-- Optimization --
local math_floor = math.floor
------------------

local bit64 = { }

--[[@
	@name lshift
	@desc Shifts an integer number to the left.
	@param x<int> An integer.
	@param disp<int> Quantity of bits to be left-shifted in @x.
	@returns int The integer @x shifted @disp bits to the left.
]]
bit64.lshift = function(x, disp)
	return x * 2 ^ disp
end

--[[@
	@name rshift
	@desc Shifts an integer number to the right.
	@param x<int> An integer.
	@param disp<int> Quantity of bits to be right-shifted in @x.
	@returns int The integer @x shifted @disp bits to the right.
]]
bit64.rshift = function(x, disp)
	return math_floor(x / 2 ^ disp)
end

--[[@
	@name band
	@desc Performs the bitwise _& (and)_ operation between two integers.
	@param x<int> The first integer.
	@param y<int> The second integer.
	@returns int The result of the & operation.
]]
bit64.band = function(x, y)
	-- x > y; \sum_{n=0}^{\lfloor \log_{2}(x) \rfloor} 2^n (\lfloor \dfrac{x}{2^n} \rfloor mod 2)(\lfloor \dfrac{y}{2^n} \rfloor mod 2)
	local aux = 1
	local out = 0

	local mX, mY
	while x > 0 and y > 0 do
		mX = x % 2
		mY = y % 2

		if (mX + mY) > 1 then
			out = out + aux
		end

		x = (x - mX) / 2
		y = (y - mY) / 2
		aux = aux * 2
	end

	return out
end

--[[@
	@name bxor
	@desc Performs the bitwise _^ (xor)_ operation between two integers.
	@param x<int> The first integer.
	@param y<int> The second integer.
	@returns int The result of the ^ operation.
]]
bit64.bxor = function(x, y)
	-- x > y; \sum_{n=0}^{\lfloor \log_{2}(x) \rfloor} 2^n [(\lfloor \dfrac{x}{2^n} \rfloor + \lfloor \dfrac{y}{2^n} \rfloor) mod 2)]
	local out = 0

	local aux
	for n = 0, 31 do
		aux = (x / 2) + (y / 2)
		if aux % 1 ~= 0 then
			out = out + 2 ^ n
		end

		x = math_floor(x / 2)
		y = math_floor(y / 2)
	end

	return out
end

return bit64