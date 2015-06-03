local image = {}
image.__index = image
image.__type = "Image"

local cache = {}

function image.new(path, settings)
	settings = settings or {}
	if not settings.absolute and type(path)=="string" then path = "assets/images/" .. path end
	--
	local i = {}
	setmetatable(i, image)
	if type(path)=="string" then
		if cache[path] then
			if type(cache[path])=="table" then
				i.img, i.img2 = cache[path][1], cache[path][2]
				if settings.mipmap==true then i.img:setMipmapFilter("nearest",0); i.img2:setMipmapFilter("nearest",0) end
			else
				i.img = cache[path]
				if settings.mipmap==true then i.img:setMipmapFilter("nearest",0) end
			end
		else
			if love.filesystem.exists(path) then
				i.img = love.graphics.newImage(path)
				if settings.mipmap==true then i.img:setMipmapFilter("nearest", 0) end
				cache[path] = i.img
			elseif settings.team then
				local imgdata = love.image.newImageData("assets/images/logos/team_default.png")
				local imgdata2 = love.image.newImageData("assets/images/logos/team_default_border.png")
				local c, c2 = settings.team.color1, settings.team.color2
				imgdata:mapPixel(function(x,y,r,g,b,a) r,g,b=c[1],c[2],c[3];return r,g,b,a end)
				imgdata2:mapPixel(function(x,y,r,g,b,a) r,g,b=c2[1],c2[2],c2[3];return r,g,b,a end)
				i.img = love.graphics.newImage(imgdata)
				i.img2 = love.graphics.newImage(imgdata2)
				i.img:setMipmapFilter("nearest", 0)
				i.img2:setMipmapFilter("nearest", 0)
				cache[path] = {i.img, i.img2}
			elseif settings.league then
				local imgdata = love.image.newImageData("assets/images/logos/league_default.png")
				local imgdata2 = love.image.newImageData("assets/images/logos/league_default_border.png")
				local c, c2 = settings.league.color2, settings.league.color1
				imgdata:mapPixel(function(x,y,r,g,b,a) r,g,b=c[1],c[2],c[3];return r,g,b,a end)
				imgdata2:mapPixel(function(x,y,r,g,b,a) r,g,b=c2[1],c2[2],c2[3];return r,g,b,a end)
				i.img = love.graphics.newImage(imgdata)
				i.img2 = love.graphics.newImage(imgdata2)
				i.img:setMipmapFilter("nearest", 0)
				i.img2:setMipmapFilter("nearest", 0)
				cache[path] = { i.img, i.img2 }
			else
				-- Make some crappy img_data thing
				i.no_image = true
			end
		end
	else
		i.img = love.graphics.newImage(path)
		if settings.mipmap==true then i.img:setMipmapFilter("nearest",0) end
	end
	i.__w, i.__h = i.no_image and (settings.w or 0) or i.img:getWidth(), i.no_image and (settings.h or 0) or i.img:getHeight()
	i.__aspect = i.__h~=0 and i.__w / i.__h or 1
	--
	i.x, i.y = settings.x or 0, settings.y or 0
	i.w, i.h = settings.w or i.__w, settings.h or i.__h
	i.color = settings.color or nil
	i.alpha = settings.alpha or nil
	i.sx, i.sy = i.w / i.__w, i.h / i.__h
	return i
end

function image:resize(w, h)
	self.w, self.h = w or self.__w, h or self.__h
	self.sx, self.sy = self.w / self.__w, self.h / self.__h
	return self
end

function image:constrain_w(w)
	self.w, self.h = w, w / self.__aspect
	self.sx, self.sy = self.w / self.__w, self.h / self.__h
	return self
end

function image:constrain_h(h)
	self.w, self.h = h * self.__aspect, h
	self.sx, self.sy = self.w / self.__w, self.h / self.__h
	return self
end

-- Can provide offsets
function image:draw(ox, oy, sx, sy)
	ox, oy = ox or 0, oy or 0
	sx, sy = sx or 1, sy or 1
	if self.color then love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.alpha or self.color[4] or 255) end
	if self.no_image then
		love.graphics.rectangle("fill", self.x + ox, self.y + oy, self.w, self.h)
	else
		love.graphics.draw(self.img, self.x + ox, self.y + oy, 0, self.sx * sx, self.sy * sy)
		if self.img2 then love.graphics.draw(self.img2, self.x + ox, self.y + oy, 0, self.sx * sx, self.sy * sy) end
	end
end

return image