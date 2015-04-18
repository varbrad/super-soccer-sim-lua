local splash = {}
splash.name = "Splash"

function splash:init()
	self.timer = g.timer.new()
end

function splash:added()
	self.timer.clear() -- Clear the local timer
	print(g.skin.colors[1][1])
end

function splash:update(dt)
	self.timer.update(dt)
end

function splash:draw()

end

return splash