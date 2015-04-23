local menu = {}
menu.name = "Menu"

function menu:init()
	self.__z = 1
	self.timer = g.timer.new()
	self.logo = g.image.new("assets/images/misc/logo.png")
	self.logo.x, self.logo.y = g.width/2 - self.logo.w/2, g.skin.margin
	--
	g.console:log("menu:init")
end

function menu:added()
	self.timer.clear() -- Clear the local timer
end

function menu:update(dt)
	self.timer.update(dt)
end

function menu:draw()
	love.graphics.setColor(255,255,255,255)
	g.image.draw(self.logo)
end

return menu