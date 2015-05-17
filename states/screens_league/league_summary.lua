local league_summary = {}
league_summary.name = "League Summary"

function league_summary:init()
	self.__z = 1
	--
	g.console:log("league_summary:init")
end

function league_summary:added()
	self:set_league()
end

function league_summary:update(dt)
	
end

function league_summary:draw()

end

function league_summary:set_league()
	self.league = g.engine.league_dict[g.vars.view.league_id]
	--
	g.ribbon:set_league(self.league)
end

return league_summary