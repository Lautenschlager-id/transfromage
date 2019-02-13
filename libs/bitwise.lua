-- https://pastebin.com/raw/Nw3y1A42
local bitwise = { }

bitwise.lshift = function(x, by)
	return x * 2 ^ by
end

bitwise.rshift = function(x, by)
	return math.floor(x / 2 ^ by)
end

bitwise.band = function(a, b)
	local p, c = 1, 0
	while a > 0 and b > 0 do
		local ra, rb = a % 2, b % 2
		if ra + rb > 1 then
		  c = c + p
		end
		a, b, p = (a - ra) / 2, (b - rb) / 2, p * 2
	end
	return c
end

bitwise.bxor = function(a, b)
	local r = 0
	for i = 0, 31 do
		local x = a / 2 + b / 2
		if x ~= math.floor (x) then
			r = r + 2^i
		end
		a = math.floor(a / 2)
		b = math.floor(b / 2)
	end
	return r
end

return bitwise