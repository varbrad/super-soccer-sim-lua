local navbar = {}
navbar.name = "Navbar"

function navbar:init()
	self.__z = 3
	--
	g.console:log("navbar:init")
end

function navbar:added()
	self:set()
end

function navbar:set()
	local team = g.database.get_player_team()
	local league = g.database.get_player_league()
	self.buttons = {}
	if team==nil then return end
	self.color1, self.color2 = team.color3, team.color1
	local btn_w = g.skin.navbar.w - g.skin.navbar.border - g.skin.margin * 2
	local btn_x = math.floor((g.skin.navbar.w-g.skin.navbar.border)/2 - btn_w/2 + .5)
	local funcs = { function() g.database.vars.view.team_id = team.id; g.state.switch(g.states.club_overview) end, function() g.database.vars.view.league_id = league.id; g.state.switch(g.states.league_overview) end, nil, nil }
	local imgs = { g.image.new("logos/"..team.id..".png", {mipmap=true, w = 32, h = 32, team = team}), g.image.new("logos/"..league.flag..league.level..".png", {mipmap=true, w=32, h=32, league=league}), nil, nil}
	for i = 1, 2 do
		self.buttons[i] = g.ui.button.new("", { x = btn_x, y = btn_x + (i-1)*(btn_w + g.skin.margin), w = btn_w, h = btn_w, image = imgs[i], on_release = funcs[i] })
		self.buttons[i]:set_colors(team.color1, team.color2, team.color3)
	end
end

function navbar:update(dt)
	for i = 1, #self.buttons do
		self.buttons[i]:update(dt)
	end
end

function navbar:draw()
	love.graphics.setColorAlpha(self.color1, g.skin.navbar.alpha)
	love.graphics.rectangle("fill", g.skin.navbar.x, g.skin.navbar.y, g.skin.navbar.w, g.skin.navbar.h)
	for i = 1, #self.buttons do
		self.buttons[i]:draw()
	end
	love.graphics.setColorAlpha(self.color2, g.skin.navbar.alpha)
	love.graphics.rectangle("fill", g.skin.navbar.x + g.skin.navbar.w - g.skin.navbar.border, g.skin.navbar.y, g.skin.navbar.border, g.skin.navbar.h)
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