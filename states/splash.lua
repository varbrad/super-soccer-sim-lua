local splash = {}
splash.name = "Splash"

function splash:init()
	self.__z = 1
	self.timer = g.timer.new()
	self.x, self.y = 50, 50
end

function splash:added()
	self.timer.clear() -- Clear the local timer
end

function splash:update(dt)
	self.timer.update(dt)
	self.x = self.x + 10*dt
	self.y = self.y + 16*dt
end

function splash:draw()
	love.graphics.setColor(255,90,95,255)
	love.graphics.circle("fill",self.x, self.y,20)
end

function splash:keypressed(k, ir)

end

function splash:mousepressed(x, y, b)
	self.x, self.y = x, y
end

return splash