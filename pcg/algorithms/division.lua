local tiles = require "pcg.tiles"

local M = {}



function M.divide(map, layer, config)
	assert(map, "You must provide a map")
	assert(layer, "You must provide a layer")

	config = config or {}
	config.floor = config.floor or tiles.FLOOR
	config.wall = config.wall or tiles.WALL
	config.door = config.door or tiles.DOOR
	config.wall_thickness = config.wall_thickness or 1

	pprint(config)

	local FLOOR = config.floor
	local WALL = config.wall
	local DOOR = config.door

	local threshold = config.wall_thickness + 1
	local divide_horisontal
	local divide_vertical
	divide_horisontal = function(x, y, w, h)
		local ratio = math.random(2, 8) / 10
		local w1 = math.floor(w * ratio)
		local w2 = w - 1 - w1
		if w1 >= threshold and w2 >= threshold then
			map.fill(layer, FLOOR, x, y, w1, h) -- left area
			map.fill(layer, FLOOR, x + w1 + 1, y, w2, h) -- right area

			divide_vertical(x, y, w1, h)
			divide_vertical(x + w1 + 1, y, w2, h)

			map.fill(layer, WALL, x + w1, y, config.wall_thickness, h) -- separator wall


			local dx = x + w1
			local dy = math.random(y, y + h - 1)
			map.fill(layer, DOOR, dx, dy, 1, config.wall_thickness) -- door
			map.fill(layer, FLOOR, dx - 1, dy, 1, config.wall_thickness) -- floor next to door
			map.fill(layer, FLOOR, dx + 1, dy, 1, config.wall_thickness) -- floor next to door
		end
	end

	divide_vertical = function(x, y, w, h)
		local ratio = math.random(2, 8) / 10
		local h1 = math.floor(h * ratio)
		local h2 = h - 1 - h1
		if h1 >= threshold and h2 >= threshold then
			map.fill(layer, FLOOR, x, y, w, h1) -- bottom area
			map.fill(layer, FLOOR, x, y + h1 + 1, w, h2) -- top area

			divide_horisontal(x, y, w, h1)
			divide_horisontal(x, y + h1 + 1, w, h2)

			map.fill(layer, WALL, x, y + h1, w, config.wall_thickness) -- separator wall

			local dx = math.random(x, x + w - 1)
			local dy = y + h1
			map.fill(layer, DOOR, dx, dy, config.wall_thickness, 1) -- door
			map.fill(layer, FLOOR, dx, dy - 1, config.wall_thickness, 1) -- floor next to door
			map.fill(layer, FLOOR, dx, dy + 1, config.wall_thickness, 1) -- floor next to door
		end
	end

	divide_horisontal(map.x + 1, map.y + 1, map.w - 2, map.h - 2)
end


return M