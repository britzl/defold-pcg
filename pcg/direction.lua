local M = {}


local ORTHOGONAL = {
	{ x = -1, y = 0 },
	{ x = 1, y = 0 },
	{ x = 0, y = -1 },
	{ x = 0, y = 1 },
}
function M.random_orthogonal()
	local dir = ORTHOGONAL[math.random(1, 4)]
	return dir.x, dir.y
end


return M