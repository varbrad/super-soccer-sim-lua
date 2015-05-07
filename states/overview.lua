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
	for i=1, #g.db_manager.leagues do
		local league = g.db_manager.leagues[i]
		local str = g.db_manager.average_strength(league)
		g.console:print(league.short_name.."\tDEF: "..str[1].."\tMID: "..str[2].."\tATT: "..str[3], g.skin.blue)
	end
	--
	g.state.add(g.states.navbar)
	g.state.add(g.states.ribbon)
	g.state.add(g.states.club_overview)
	g.state.remove(self)
end

function overview:update(dt)
	
end

function overview:draw()
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.print("Loading", g.width/2, g.height/2)
end

return overview