local league_stats = {}
league_stats.name = "League Stats"

function league_stats:init()
	self.__z = 1
	--
	g.console:log("league_stats:init")
end

function league_stats:added()
	self.highest_scorers = g.components.
	self:set()
end

function league_stats:update(dt)
	self.league_table:update(dt)
end

function league_stats:draw()
	self.league_table:draw()
end

function league_stats:set()
	self.league = g.db_manager.league_dict[g.vars.view.league_id]
	self.league_table:set(self.league)
	--
	g.ribbon:set_league(self.league)
end

function league_stats:keypressed(k, ir)
	
end

function league_stats:mousepressed(x, y, b)

end

function league_stats:mousereleased(x, y, b)

end

return league_stats