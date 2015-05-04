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
		if settings.mipmap==true then i.img:setMipmapFilter("nearest",0) end
	else
		if love.filesystem.exists(path) then
			i.img = love.graphics.newImage(path)
			if settings.mipmap==true then i.img:setMipmapFilter("nearest", 0) end
			cache[path] = i.img
		else
			i.no_image = true
			g.console:print("An Image Could Not Be Loaded.\t\t("..path..")", g.skin.red)
		end
	end
	i.__w, i.__h = i.no_image and (settings.w or 0) or i.img:getWidth(), i.no_image and (settings.h or 0) or i.img:getHeight()
	--
	i.x, i.y = settings.x or 0, settings.y or 0
	i.w, i.h = settings.w or i.__w, settings.h or i.__h
	i.color = settings.color or nil
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
	if self.color then love.graphics.setColor(self.color) end
	if self.no_image then
		love.graphics.rectangle("fill", self.x + ox, self.y + oy, self.w, self.h)
	else
		love.graphics.draw(self.img, self.x + ox, self.y + oy, 0, self.sx * sx, self.sy * sy)
	end
end

return image