local ngl = {}
ngl.name = "New Game Load"

function ngl:init()
	self.__z = 1
	self.timer = g.timer.new()
	self.message = "Loading"
	self.loading = {}
	self.loading.image = love.graphics.newImage("assets/images/misc/loading.png")
	self.loading.width = self.loading.image:getWidth()
	self.loading.height = self.loading.image:getHeight()
	self.loading.x = math.floor(g.width/2 - self.loading.width/2)
	self.loading.y = math.floor(g.height/2 - self.loading.height/2)
	self.loading.rotation = 0
	self:draw()
	--
	g.console:log("ngl:init")
end

function ngl:added()
	self.timer.clear() -- Clear the local timer
	self:rotate_loading()
	--
	g.db_manager.load("db/teams.csv", "db/leagues.csv")
	-- Go to the menu state
end

function ngl:update(dt)
	self.timer.update(dt)
end

function ngl:draw()
	love.graphics.setColor(255,255,255,255)
	g.font.set("regular", 24)
	love.graphics.printf(self.message, 0, self.loading.y + self.loading.height + 10, g.width, "center")
	love.graphics.draw(self.loading.image, self.loading.x + self.loading.width/2, self.loading.y + self.loading.height/2, self.loading.rotation, 1, 1, self.loading.width/2, self.loading.height/2)
end

--

function ngl:rotate_loading()
	self.loading.rotation = 0
	self.timer.tween(1, self.loading, {rotation = math.pi * 2}, "linear", function() self:rotate_loading() end)
end

return ngl