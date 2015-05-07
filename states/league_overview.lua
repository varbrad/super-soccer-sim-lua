local league_overview = {}
league_overview.name = "League Overview"

function league_overview:init()
	self.__z = 1
	--
	g.console:log("league_overview:init")
end

function league_overview:added()
	local split_h = g.skin.screen.h/2 - g.skin.margin *1.5
	local split_w = g.skin.screen.w/2 - g.skin.margin *1.5
	local height = g.skin.screen.h - g.skin.margin * 2
	self.league_table = g.components.league_table.new(g.skin.screen.x + g.skin.margin, g.skin.screen.y + g.skin.margin, split_w, height, nil, "default")
	self.upcoming = g.components.fixture_group.new(g.skin.screen.x + g.skin.margin * 2 + self.league_table.w, g.skin.screen.y + g.skin.margin, split_w, split_h) 
	self.results = g.components.fixture_group.new(self.upcoming.x, self.upcoming.y + self.upcoming.h + g.skin.margin, self.upcoming.w, self.upcoming.h)
	self:set_league()
end

function league_overview:update(dt)
	self.league_table:update(dt)
	self.upcoming:update(dt)
	self.results:update(dt)
end

function league_overview:draw()
	self.league_table:draw()
	self.upcoming:draw()
	self.results:draw()
end

function league_overview:set_league()
	self.league = g.db_manager.league_dict[g.vars.view.league_id]
	self.league_table:set(self.league)
	self.upcoming:set(self.league, g.vars.week, false)
	self.results:set(self.league, g.vars.week-1, true)
	--
	g.ribbon:set_league(self.league)
end

function league_overview:keypressed(k, ir)
	if g.ribbon.searchbox.focus then return end
	local old_id = g.vars.view.league_id
	local id = old_id
	if k=="left" then id = id - 1 end
	if k=="right" then id = id + 1 end
	if k=="left" or k=="right" then
		local l = g.db_manager.league_dict[id]
		if l then
			g.vars.view.league_id = id
			self:set_league()
		end
	end
end

function league_overview:mousepressed(x, y, b)
	self.league_table:mousepressed(x, y, b)
	self.upcoming:mousepressed(x, y, b)
	self.results:mousepressed(x, y, b)
end

function league_overview:mousereleased(x, y, b)
	self.league_table:mousereleased(x, y, b)
	self.upcoming:mousereleased(x, y, b)
	self.results:mousereleased(x, y, b)
end

return league_overview