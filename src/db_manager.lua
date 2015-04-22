local dbm = {}

dbm.teams = {}
dbm.leagues = {}

-- Paths to the teams and leagues .csv files
function dbm.load(teams, leagues)
	local team_file = love.filesystem.read(teams)
	local league_file = love.filesystem.read(leagues)
	teams = g.csv.use(team_file, { header = true } )
	leagues = g.csv.use(league_file, { header = true } )
	--
	for fields in teams:lines() do
		local team = {}
		for k, v in pairs(fields) do
			team[k] = v
			if team[k] == "" then team[k] = nil end
		end
		dbm.teams[#dbm.teams+1] = team
	end
	-- Teams initial load in complete
	g.console:print(#dbm.teams .. " teams loaded from db", g.skin.blue)
	--
	for fields in leagues:lines() do
		local league = {}
		for k, v in pairs(fields) do
			league[k] = v
			if league[k] == "" then league[k] = nil end
		end
		dbm.leagues[#dbm.leagues+1] = league
	end
	-- Leagues initial load complete
	g.console:print(#dbm.leagues .. " leagues loaded from db", g.skin.blue)
end

return dbm