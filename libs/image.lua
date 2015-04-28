local image = {}
image.__index = image
image.__type = "Image"

local cache = {}

function image.new(path, settings)
	path = "assets/images/" .. path
	settings = settings or {}
	--
	local i = {}
	setmetatable(i, image)
	if cache[path] then
		i.img = cache[path]
	else
		if not love.filesystem.exists(path) then return nil end
		i.img = love.graphics.newImage(path)
		if settings.mipmap==true then i.img:setMipmapFilter("nearest", 0) end
		cache[path] = i.img
	end
	i.__w, i.__h = i.img:getWidth(), i.img:getHeight()
	--
	i.x, i.y = settings.x or 0, settings.y or 0
	i.w, i.h = settings.w or i.__w, settings.h or i.__h
	i.sx, i.sy = i.w / i.__w, i.h / i.__h
	return i
end

function image:resize(w, h)
	self.w, self.h = w or self.__w, h or self.__h
	self.sx, self.sy = self.w / self.__w, self.h / self.__h
	return self
end

-- Can provide offsets
function image:draw(ox, oy, sx, sy)
	ox, oy = ox or 0, oy or 0
	sx, sy = sx or 1, sy or 1
	love.graphics.draw(self.img, self.x + ox, self.y + oy, 0, self.sx * sx, self.sy * sy)
end

return image