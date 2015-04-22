local menu = {}
menu.name = "Menu"

function menu:init()
	self.__z = 1
	self.timer = g.timer.new()
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
end

return menu