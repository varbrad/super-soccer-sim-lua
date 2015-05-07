local navbar = {}
navbar.name = "Navbar"

function navbar:init()
	self.__z = 3
	--
	g.console:log("navbar:init")
end

function navbar:added()
	self.buttons = {}
	local team_league = g.db_manager.team_dict[g.vars.player.team_id].league
	local funcs = { function() g.vars.view.team_id = g.vars.player.team_id; g.state.switch(g.states.club_overview) end, function() g.vars.view.league_id = team_league.id; g.state.switch(g.states.league_overview) end, nil, nil }
	local imgs = { g.image.new("logos/128/"..g.vars.player.team_id..".png", {mipmap=true, w = 32, h=32}), g.image.new("logos/128/"..team_league.flag..team_league.level..".png", {mipmap=true, w=32, h=32}), nil, nil}
	for i = 1, 2 do
		self.buttons[i] = g.ui.button.new("", { x = 4, y = 4 + (i-1)*48, w = 44, h = 44, image = imgs[i], on_release = funcs[i] })
	end
end

function navbar:update(dt)
	for i = 1, #self.buttons do
		self.buttons[i]:update(dt)
	end
end

function navbar:draw()
	love.graphics.setColor(g.skin.colors[1])
	love.graphics.rectangle("fill", g.skin.navbar.x, g.skin.navbar.y, g.skin.navbar.w, g.skin.navbar.h)
	for i = 1, #self.buttons do
		self.buttons[i]:draw()
	end
end

function navbar:mousepressed(x, y, b)
	for i = 1, #self.buttons do
		self.buttons[i]:mousepressed(x, y, b)
	end
end

function navbar:mousereleased(x, y, b)
	for i = 1, #self.buttons do
		self.buttons[i]:mousereleased(x, y, b)
	end
end

return navbar