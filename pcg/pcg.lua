local M = {}

function M.fill(tilemap_url, tilemap_layer, tile, x, y, w, h)
	for xi = x, x + w - 1 do
		for yi = y, y + h - 1 do
			tilemap.set_tile(tilemap_url, tilemap_layer, xi, yi, tile)
		end
	end
end

return M