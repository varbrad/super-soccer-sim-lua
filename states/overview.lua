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
	self.team_id = 1
	g.ribbon:reset()
	g.ribbon:set_header("Hello!")
end

function overview:update(dt)

end

function overview:draw()

end

function overview:keypressed(k, ir)
	local old = self.team_id
	if k=="left" then self.team_id = self.team_id - 1 end
	if k=="right" then self.team_id = self.team_id + 1 end
	--
	if g.db_manager.teams[self.team_id]==nil then self.team_id = old end
	local team = g.db_manager.teams[self.team_id]
	g.ribbon:set_team(team)
end

return overview