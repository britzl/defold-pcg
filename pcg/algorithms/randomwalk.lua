local direction = require "pcg.direction"

local M = {}

function M.walk(map, layer, tile, config)
	assert(map, "You must provide a map")
	assert(layer, "You must provide a layer")
	assert(tile, "You must provide a tile")
	config = config or {}
	config.walkers = config.walkers or 1 
	config.steps = config.steps or 200
	assert(config.walkers > 0)
	assert(config.steps > 0)

	for walkers=1,config.walkers do
		local tx = math.floor((map.x + map.w - 1) / 2)
		local ty = math.floor((map.y + map.h - 1) / 2)
		for steps=1,config.steps do
			map.fill(layer, tile, tx, ty)
			local dx, dy = direction.random_orthogonal()
			tx = tx + dx
			ty = ty + dy
			if not map.on_map(tx, ty) then
				break
			end
		end
	end
end


return M