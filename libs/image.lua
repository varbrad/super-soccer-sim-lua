local image = {}

local cache = {}

function image.new(path, x, y, sx, sy)
	local i = {}
	if cache[path] then
		i.img = cache[path]
	else
		i.img = love.graphics.newImage(path)
		cache[path] = i.img
	end
	i.x, i.y = x or 0, y or 0
	i.w, i.h = i.img:getWidth(), i.img:getHeight()
	i.__w, i.__h = i.w, i.h
	i.__sx, i.__sy = sx or 1, sy or 1
	return i
end

function image.set_size(i, w, h)
	if w==nil and h==nil then i.sx, i.sy, i.w, i.h = 1, 1, i.__w, i.__h; return end
	i.sx, i.sy = w / i.__w, h / i.__h
	i.w, i.h = w, h
end

-- Can provide offsets
function image.draw(image, ox, oy)
	ox, oy = ox or 0, oy or 0
	love.graphics.draw(image.img, image.x + ox, image.y + oy, 0, image.sx, image.sy)
end

return image