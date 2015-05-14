local bg = {}
bg.name = "Background"

function bg:init()
	self.__z = 0
	--
	self.images = {}
	local path = "assets/images/bg/"
	local files = love.filesystem.getDirectoryItems(path)
	for i=1, #files do
		local f_name = files[i]
		local is_file = love.filesystem.isFile(path..f_name)
		if is_file then
			local image = g.image.new(path..f_name, { absolute = true, w = g.width, h = g.height })
			table.insert(self.images, image)
		end
	end
	--
	bg:set_image(7)
	--
	g.console:log("background:init")
end

function bg:set_image(index)
	self.index = index or self.index or 1
	self.image = self.images[self.index]
end

function bg:draw()
	love.graphics.setColor(123, 123, 123, 255)
	self.image:draw()
end

return bg
