local bg = {}
bg.name = "Background"

function bg:init()
	self.__z = 0
	self.flux = g.flux:group()
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
	self.index = love.math.random(1,#self.images)
	self:set()
	if g.settings.background_cycle then bg:start_cycling() end
	--
	g.console:log("background:init")
end

function bg:set()
	self.image = self.images[self.index]
end

function bg:start_cycling()
	local next_index = self.index==#self.images and 1 or self.index + 1
	self.image2 = self.images[next_index]
	self.image2.alpha = 0
	self.flux:to(self.image2, g.settings.background_cycle_time, {alpha = 255}):oncomplete(function() self.index = next_index; self:set(); self:start_cycling() end)
end

function bg:stop_cycling()
	self.flux = g.flux:group()
	self.image2 = nil
end

function bg:update(dt)
	self.flux:update(dt)
end

function bg:draw()
	love.graphics.setColor(255, 255, 255, 255)
	self.image:draw()
	if self.image2 then
		love.graphics.setColor(255, 255, 255, self.image2.alpha)
		self.image2:draw()
	end
end

return bg
