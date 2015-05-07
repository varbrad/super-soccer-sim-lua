local league_full_table = {}
league_full_table.name = "League Full Table"

function league_full_table:init()
	self.__z = 1
	--
	g.console:log("league_full_table:init")
end

function league_full_table:added()
	self.league_table = g.components.league_table.new(g.skin.screen.x + g.skin.margin, g.skin.screen.y + g.skin.margin, g.skin.screen.w - g.skin.margin * 2, g.skin.screen.h - g.skin.margin * 2, nil, "full")
	self:set_league()
end

function league_full_table:update(dt)
	self.league_table:update(dt)
end

function league_full_table:draw()
	self.league_table:draw()
end

function league_full_table:set_league()
	self.league = g.db_manager.league_dict[g.vars.view.league_id]
	self.league_table:set(self.league)
	--
	g.ribbon:set_league(self.league)
end

function league_full_table:keypressed(k, ir)
	
end

function league_full_table:mousepressed(x, y, b)
	self.league_table:mousepressed(x, y, b)
end

function league_full_table:mousereleased(x, y, b)
	self.league_table:mousereleased(x, y, b)
end

return league_full_table