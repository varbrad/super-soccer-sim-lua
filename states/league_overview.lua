local league_overview = {}
league_overview.name = "League Overview"

function league_overview:init()
	self.__z = 1
	--
	g.console:log("league_overview:init")
end

function league_overview:added(id)
	self.league_id = id or 1
	self:set_league(self.league_id)
end

function league_overview:update(dt)
	
end

function league_overview:draw()

end

function league_overview:set_league(id)
	local league = g.db_manager.league_dict[self.league_id]
	g.ribbon:set_league(league)
end

function league_overview:keypressed(k, ir)
	local old_id = self.league_id
	if k=="left" then self.league_id = self.league_id - 1 end
	if k=="right" then self.league_id = self.league_id + 1 end
	if k=="left" or k=="right" then
		local l = g.db_manager.league_dict[self.league_id]
		if l==nil then
			self.league_id = old_id
			return
		else
			g.ribbon:set_league(l)
		end
	end
end

return league_overview