local tiles = require "pcg.tiles"

local M = {}

local WALL_SIDES = { 97, 112, 113, 114 }
local FLOOR_TILES = { 83, 84, 93, 93, 93, 93, 93, 93, 26, 94 }

local function random_tile(list)
	return list[math.random(1, #list)]
end


function M.apply(map, layer_level, layer_shadows)
	assert(map, "You must provide a map")
	assert(layer_level, "You must provide a level layer")
	assert(layer_shadows, "You must provide a shadow layer")
	local LEVEL = layer_level
	local SHADOW = layer_shadows
	local FLOOR = tiles.FLOOR
	local WALL = tiles.WALL
	local copy = map.duplicate()
	for tile, x, y in copy.tiles(LEVEL) do
		local left = copy.get_tile(LEVEL, x - 1, y)
		local right = copy.get_tile(LEVEL, x + 1, y)
		local down_left = copy.get_tile(LEVEL, x - 1, y - 1)
		local down_right = copy.get_tile(LEVEL, x + 1, y - 1)
		local top_left = copy.get_tile(LEVEL, x - 1, y + 1)
		local top_right = copy.get_tile(LEVEL, x + 1, y + 1)
		local below = copy.get_tile(LEVEL, x, y - 1)
		local far_below = copy.get_tile(LEVEL, x, y - 2)
		local above = copy.get_tile(LEVEL, x, y + 1)
		local above_left = copy.get_tile(LEVEL, x - 1, y + 1)
		local above_right = copy.get_tile(LEVEL, x + 1, y + 1)
		local far_above = copy.get_tile(LEVEL, x, y + 2)
		local far_above_right = copy.get_tile(LEVEL, x + 1, y + 2)
		local far_above_left = copy.get_tile(LEVEL, x - 1, y + 2)
						
		local floor_left = left == FLOOR
		local floor_right = right == FLOOR
		local floor_above = above == FLOOR
		local floor_below = below == FLOOR
		local floor_far_below = far_below == FLOOR
		local floor_down_left = down_left == FLOOR
		local floor_down_right = down_right == FLOOR
		local floor_top_left = top_left == FLOOR
		local floor_top_right = top_right == FLOOR

		local floor_left_right = floor_left and floor_right
		local floor_above_below = floor_above and floor_below
		
		local wall_left_right = not floor_left and not floor_right
		local wall_above_below = not floor_above and not floor_below
		local wall_top_left_right = not floor_top_left and not floor_top_right
		local wall_down_left_right = not floor_down_left and not floor_down_right

		if tile == tiles.WALL then
			if wall_left_right and wall_above_below and wall_top_left_right and wall_down_left_right and not floor_far_below then
				if far_above == FLOOR or far_above_left == FLOOR or far_above_right == FLOOR then
					map.set_tile(LEVEL, random_tile(WALL_SIDES), x, y)
				else
					map.set_tile(LEVEL, 0, x, y)
				end
			-- single pillar
			elseif floor_left_right and floor_above_below then
				map.set_tile(LEVEL, 40, x, y)
			-- single pillar
			elseif floor_above_below and (left == WALL or right == WALL) then
				map.set_tile(LEVEL, 40, x, y)
			-- left end of horizontal wall
			elseif left == FLOOR and right == WALL and above == FLOOR and below == WALL and far_below == FLOOR then
				map.set_tile(LEVEL, 119, x, y)
			-- right edge of horizontal wall
			elseif right == FLOOR and left == WALL and above == FLOOR and below == WALL and far_below == FLOOR then
				map.set_tile(LEVEL, 86, x, y)
			-- top edge of vertical wall
			elseif above == FLOOR and below == WALL and left == FLOOR and right == FLOOR and down_left == FLOOR and down_right == FLOOR then
				map.set_tile(LEVEL, 99, x, y)
			-- bottom edge of vertical wall
			elseif above == WALL and below == WALL and far_below == FLOOR and down_left == FLOOR and down_right == FLOOR then
				map.set_tile(LEVEL, 96, x, y)
			-- side of the wall
			elseif below == FLOOR and above == WALL then
				map.set_tile(LEVEL, random_tile(WALL_SIDES), x, y)
			-- bottom edge of wall (with highlight)
			elseif below == WALL and far_below == FLOOR then
				map.set_tile(LEVEL, 106, x, y)
			-- standard wall
			else
				map.set_tile(LEVEL, 85, x, y)
			end

			-- corner wall shadow
			if below == FLOOR and down_left == WALL and above == WALL then
				map.set_tile(SHADOW, 60, x, y)
			end
		elseif tile == tiles.FLOOR then
			map.set_tile(LEVEL, random_tile(FLOOR_TILES), x, y)
			-- corner shadow
			if above == WALL and left == WALL then
				map.set_tile(SHADOW, 61, x, y)
			-- top shadow
			elseif above == WALL then
				map.set_tile(SHADOW, 69, x, y)
			-- left shadow
			elseif left == WALL and above_left == WALL then
				map.set_tile(SHADOW, 62, x, y)
			end
		end
	end
	map.to_tilemap()
end

return M