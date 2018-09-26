local M = {}


function M.create(tilemap_url, layer_ids)
	assert(tilemap_url, "You must provide a tilemap url")
	assert(layer_ids, "You must provide a list of layers")
	local x, y, w, h = tilemap.get_bounds(tilemap_url)
	local layers = {}
	for _,layer in ipairs(layer_ids) do
		layers[layer] = {}
	end

	local instance = {
		x = x, y = y,
		w = w, h = h,
		tilemap_url = tilemap_url,
		layer_ids = layer_ids,
	}

	local function xy_to_i(x, y)
		return (y * w) + x
	end

	local function on_map(tx, ty)
		return tx >= x and tx <= (x + w - 1) and ty >= y and ty <= (y + h - 1)
	end

	function instance.on_map(x, y)
		return on_map(x, y)
	end

	function instance.xy_to_i(x, y)
		return xy_to_i(x, y)
	end

	function instance.get_tile(layer, tx, ty)
		if on_map(tx, ty) then
			return layers[layer][xy_to_i(tx, ty)]
		end
	end

	function instance.set_tile(layer, tile, tx, ty)
		assert(tile)
		layers[layer][xy_to_i(tx, ty)] = tile
	end

	function instance.on_map(tx, ty)
		return on_map(tx, ty)
	end
	
	function instance.fill(layer, tile, x, y, w, h)
		assert(layers[layer], ("Layer '%s' does not exist"):format(tostring(layer)))
		if not x then
			x = instance.x
			w = w or instance.w
		else
			w = w or 1
		end
		if not y then
			y = instance.y
			h = h or instance.h
		else
			h = h or 1
		end
		local tiles = layers[layer]
		for xi = x, x + w - 1 do
			for yi = y, y + h - 1 do
				tiles[xy_to_i(xi, yi)] = tile
			end
		end
	end

	function instance.clear(layer)
		assert(layers[layer], ("Layer '%s' does not exist"):format(tostring(layer)))
		w = w or 1
		h = h or 1
		local tiles = layers[layer]
		for xi = x, x + w - 1 do
			for yi = y, y + h - 1 do
				tiles[xy_to_i(xi, yi)] = 0
			end
		end
	end

	function instance.duplicate()
		local copy = M.create(tilemap_url, layer_ids)
		for _,layer in ipairs(layer_ids) do
			for tile, x, y in instance.tiles(layer) do
				copy.set_tile(layer, tile, x, y)
			end
		end
		return copy
	end


	function instance.layers()
		return pairs(layers)
	end

	function instance.tiles(layer)
		assert(layer, "You must provide a layer")
		local fn = coroutine.wrap(function()
			local tiles = layers[layer]
			for xi = x, x + w - 1 do
				for yi = y, y + h - 1 do
					local tile = tiles[xy_to_i(xi, yi)]
					coroutine.yield(tile, xi, yi)
				end
			end
		end)
		return fn
	end

	function instance.to_tilemap()
		for layer, tiles in instance.layers() do
			for tile, x, y in instance.tiles(layer) do
				if tile then
					tilemap.set_tile(tilemap_url, layer, x, y, tile)
				end
			end
		end
		return instance
	end

	function instance.from_tilemap()
		for layer, tiles in instance.layers() do
			for xi = x, x + w - 1 do
				for yi = y, y + h - 1 do
					tiles[xy_to_i(xi, yi)] = tilemap.get_tile(tilemap_url, layer, xi, yi)
				end
			end
		end
		return map
	end

	return instance
end

return M