local dbm = {}

local hex = love.graphics.hexToRgb

dbm.teams = {}
dbm.team_dict = {}
dbm.leagues = {}
dbm.league_dict = {}

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
		dbm.team_dict[team.id] = team
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
		league.teams = {}
		dbm.leagues[#dbm.leagues+1] = league
		dbm.league_dict[league.id] = league
	end
	-- Leagues initial load complete
	g.console:print(#dbm.leagues .. " leagues loaded from db", g.skin.blue)
	-- Now need to process data and link everything together
	for i=1, #dbm.teams do
		local team = dbm.teams[i]
		team.league = dbm.league_dict[team.league_id]
		table.insert(team.league.teams, team)
		team.color_1 = hex(team.color_1) or g.skin.black
		team.color_2 = hex(team.color_2) or g.skin.white
		team.color_3 = hex(team.color_3) or g.skin.black
	end
end

return dbm