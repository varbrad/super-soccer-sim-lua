local club_overview = {}
club_overview.name = "Club Overview"

function club_overview:init()
	self.__z = 1
	--
	g.console:log("club_overview:init")
end

function club_overview:added()
	local height = g.skin.screen.h - g.skin.margin * 2
	local split_w = math.floor(g.skin.screen.w/3 - g.skin.margin * 1.5 + .5)
	local split_h = math.floor(g.skin.screen.h/2 - g.skin.margin * 1.5 + .5)
	local middle = g.skin.screen.w - g.skin.margin * 4 - split_w * 2
	self.fixture_list = g.components.fixture_list.new(g.skin.screen.x + g.skin.margin, g.skin.screen.y + g.skin.margin, split_w, height)
	self.league_table = g.components.league_table.new(self.fixture_list.x + self.fixture_list.w + g.skin.margin, self.fixture_list.y, middle, height, true) -- Show the current view_team
	self.league_graph = g.components.team_league_pos_graph.new(self.league_table.x + self.league_table.w + g.skin.margin, self.fixture_list.y, split_w, split_h)
	self.history_graph = g.components.team_league_history_graph.new(self.league_graph.x, g.skin.screen.y + g.skin.screen.h - g.skin.margin - split_h, split_w, split_h / 2, 20)
	local pcx, pcy = self.history_graph.x + split_w / 2, self.history_graph.y + self.history_graph.h * 1.5
	local pcr = (self.history_graph.h / 2) - g.skin.margin * 2
	self.piechart_wdl = g.ui.piechart.new({ x = pcx - pcr - g.skin.margin, y = pcy, radius = pcr })
	self.piechart_gd = g.ui.piechart.new({ x = pcx + pcr + g.skin.margin, y = pcy, radius = pcr })
	g.tween_alpha()
	self:set_team()
end

function club_overview:update(dt)
	self.fixture_list:update(dt)
	self.league_table:update(dt)
	self.piechart_wdl:update(dt)
	self.piechart_gd:update(dt)
end

function club_overview:draw()
	self.fixture_list:draw(g.tween.t_alpha)
	self.league_table:draw(g.tween.t_alpha)
	self.league_graph:draw(g.tween.t_alpha)
	self.history_graph:draw(g.tween.t_alpha)
	self.piechart_wdl:draw(g.tween.t_alpha)
	self.piechart_gd:draw(g.tween.t_alpha)
end

function club_overview:set_team()
	self.team = g.database.get_view_team()
	self.fixture_list:set(self.team)
	self.league_table:set(g.database.get_league(self.team.league_id), "small")
	self.league_graph:set(self.team)
	self.history_graph:set(self.team)
	--
	self.piechart_wdl:reset()
	self.piechart_gd:reset()
	local p, w, d = self.team.data.season.stats.p, self.team.data.season.stats.w, self.team.data.season.stats.d
	local gf, ga = self.team.data.season.stats.gf, self.team.data.season.stats.ga
	if p > 0 then
		w, d = math.floor(w * 100 / p + .5), math.floor(d * 100 / p + .5)
		gf = math.floor(gf * 100 / (gf+ga) + .5)
		self.piechart_wdl:add(g.skin.green, w):add(g.skin.yellow, d):add(g.skin.red)
		self.piechart_gd:add(g.skin.green, gf):add(g.skin.red)
		self.piechart_wdl:tween(g.skin.tween.time, g.skin.tween.type)
		self.piechart_gd:tween(g.skin.tween.time, g.skin.tween.type)
	end
	--
	g.ribbon:set_team(self.team)
end

function club_overview:keypressed(k, ir)
	if g.ribbon.searchbox.focus then return end
	if k=="l" then
		g.database.vars.player.team_id = g.database.vars.view.team_id
		g.state.refresh_all()
	end
end

function club_overview:mousepressed(x, y, b)
	self.fixture_list:mousepressed(x, y, b)
	self.league_table:mousepressed(x, y, b)
end

function club_overview:mousereleased(x, y, b)
	self.fixture_list:mousereleased(x, y, b)
	self.league_table:mousereleased(x, y, b)
end

return club_overview