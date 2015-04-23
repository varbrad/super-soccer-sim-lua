local image = {}

local cache = {}

function image.new(path, x, y)
	local i = {}
	if cache[path] then
		i.img = cache[path]
	else
		i.img = love.graphics.newImage(path)
		cache[path] = i.img
	end
	i.x, i.y = x or 0, y or 0
	i.w, i.h = i.img:getWidth(), i.img:getHeight()
	return i
end

function image.draw(image)
	love.graphics.draw(image.img, image.x, image.y)
end

return image