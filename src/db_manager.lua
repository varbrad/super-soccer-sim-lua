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
		if team.league_id then team.league_id = tonumber(team.league_id) else team.league_id = 0 end -- default league id to 0 if not present
		dbm.teams[#dbm.teams+1] = team
		dbm.team_dict[tonumber(team.id)] = team
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
		dbm.league_dict[tonumber(league.id)] = league
	end
	-- Leagues initial load complete
	g.console:print(#dbm.leagues .. " leagues loaded from db", g.skin.blue)
	-- Now need to process data and link everything together
		for i=1, #dbm.teams do
		local team = dbm.teams[i]
		team.league = dbm.league_dict[team.league_id]
		table.insert(team.league.teams, team)
		team.color1 = hex(team.color1) or g.skin.black
		team.color2 = hex(team.color2) or g.skin.white
		team.color3 = hex(team.color3) or love.graphics.darken(team.color1)
		team.season = {}
		team.season.stats = { w=0; d=0; l=0; gf=0; ga=0; }
	end
	g.console:print("All teams fully processed", g.skin.green)
	-- Now process league data
	for i=1, #dbm.leagues do
		local league = dbm.leagues[i]
		league.color1 = hex(league.color1) or g.skin.black
		league.color2 = hex(league.color2) or g.skin.white
		league.color3 = hex(league.color3) or love.graphics.darken(league.color1)
		if league.flag==nil then league.flag="" end
		--
		league.season = {}
		league.season.fixtures = dbm.generate_fixtures(league)
		dbm.sort_league(league)
	end
	g.console:print("All leagues fully processed", g.skin.green)
	for i=1, #dbm.teams do
		local team = dbm.teams[i]
		team.season.fixtures = dbm.get_team_fixtures(team, team.league)
	end
end

function dbm.generate_fixtures(league)
	local teams = league.teams
	if #teams==0 then return {} end
	-- First, shuffle the order of the teams in the league.data.teams array
	dbm.shuffle(teams)
	-- Make fixtures object
	local fixtures = {}
	local round, fixture = {}, nil
	local games_per_week = #teams/2
	-- Initial fixture setup round
	for i=1,#teams,2 do
		fixture = {}
		fixture.home = teams[i]
		fixture.away = teams[i+1]
		round[#round+1] = fixture
	end
	fixtures[1] = round
	-- We now need to rotate the fixture list to generate all fixtures
	for a=2,#teams-1 do
		round, fixture = {}, nil
		for n=1,games_per_week do
			fixture = {}
			if n==1 then
				fixture.home = fixtures[a-1][1].home
				fixture.away = fixtures[a-1][n+1].home
			elseif n==games_per_week then
				fixture.home = fixtures[a-1][n].away
				fixture.away = fixtures[a-1][n-1].away
			else
				fixture.home = fixtures[a-1][n+1].home
				fixture.away = fixtures[a-1][n-1].away
			end
			round[#round+1] = fixture
		end
		fixtures[a] = round
	end
	-- We now have half of all fixtures, we need to mirror all fixtures for away legs.
	for a=1,#teams-1 do
		local r,f = {},nil
		for n=1,games_per_week do
			f={}
			f.home=fixtures[a][n].away
			f.away=fixtures[a][n].home
			r[#r+1]=f
		end
		fixtures[#fixtures+1]=r
	end
	-- We now have a complete fixture list, but in a crap order. Zig-zag around to
	-- generate a good order for fixtures.
	local final_fixtures = {}
	local alt=false
	for i=1,#fixtures do
		local s = i
		if s==#fixtures/2+1 then alt=false end
		if alt then
			if s > #fixtures/2 then s=s-#fixtures/2
			else s = s + #fixtures/2 end
		end
		final_fixtures[#final_fixtures+1] = fixtures[s]
		alt = not alt
	end
	-- Sort each fixture round by team names
	for i=1,#fixtures do
		local r = fixtures[i]
		table.sort(r,function(a,b) return a.home.short_name < b.home.short_name end)
	end
	g.console:print("Generated "..#final_fixtures*games_per_week.." fixtures for "..league.short_name)
	return final_fixtures
end

function dbm.get_team_fixtures(team, league)
	local fixtures = {}
	local lge_fixtures = league.season.fixtures
	for i=1,#lge_fixtures do
		local round = lge_fixtures[i]
		for k=1,#round do
			local f = round[k]
			if f.home==team or f.away==team then
				fixtures[i] = f
				break
			end
		end
	end
	return fixtures
end

function dbm.sort_league(league)
	table.sort(league.teams, function(a,b)
		if a.short_name < b.short_name then return true end
		return false
	end)
end

function dbm.shuffle(t)
	local a = #t
	for i = a, 2, -1 do
		local j = love.math.random(1, i)
		t[i], t[j] = t[j], t[i]
	end
	return t
end

return dbm