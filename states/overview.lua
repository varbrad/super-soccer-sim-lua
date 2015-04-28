local overview = {}
overview.name = "Overview"

function overview:init()
	self.__z = 1
	--
	g.console:log("overview:init")
end

function overview:added()
	g.db_manager.load("db/teams.csv", "db/leagues.csv")
	--
	g.state.swap(self, g.states.club_overview)
end

function overview:update(dt)
	
end

function overview:draw()

end

return overview