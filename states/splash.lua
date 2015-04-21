local splash = {}
splash.name = "Splash"

function splash:init()
	self.__z = 1
	self.timer = g.timer.new()
	self.message = "Loading"
	splash:draw()
	--
	g.console:log("splash:init")
end

function splash:added()
	self.timer.clear() -- Clear the local timer
	--
	g.db_manager.load("../db/teams.csv", "../db/leagues.csv")
	--
	self.message = self.message .. "\nDB Loaded"
end

function splash:update(dt)
	self.timer.update(dt)
end

function splash:draw()
	love.graphics.setColor(255,255,255,255)
	love.graphics.print(self.message, 10, 10)
end

return splash