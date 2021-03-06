local league_results_grid = {}
league_results_grid.name = "League Results Grid"

function league_results_grid:init()
	self.__z = 1
	--
	g.console:log("league_results_grid:init")
end

function league_results_grid:added()
	local w, h = g.skin.screen.w - g.skin.margin * 2, g.skin.screen.h - g.skin.margin * 2
	local w80 = w * .8
	self.result_grid = g.components.result_grid.new(g.skin.screen.x + g.skin.margin, g.skin.screen.y + g.skin.margin, w80, h)
	self.league_table = g.components.league_table.new(self.result_grid.x + self.result_grid.w + g.skin.margin, self.result_grid.y, w - w80 - g.skin.margin, h)
	g.tween_alpha()
	self:set_league()
end

function league_results_grid:update(dt)
	self.result_grid:update(dt)
	self.league_table:update(dt)
end

function league_results_grid:draw()
	self.result_grid:draw(g.tween.t_alpha)
	self.league_table:draw(g.tween.t_alpha)
end

function league_results_grid:set_league()
	self.league = g.database.get_view_league()
	self.result_grid:set(self.league)
	self.league_table:set(self.league, "small")
	--
	g.ribbon:set_league(self.league)
end

function league_results_grid:mousepressed(x, y, b)
	self.result_grid:mousepressed(x, y, b)
	self.league_table:mousepressed(x, y, b)
end

function league_results_grid:mousereleased(x, y, b)
	self.result_grid:mousereleased(x, y, b)
	self.league_table:mousereleased(x, y, b)
end

return league_results_grid