local engine = {}

-- Engine handles with modifying and processing all the data, fixtures, events, seasons, etc in database

function engine.generate_league_fixtures(league)
	local teams = league.data.teams
	-- First, shuffle the order of the teams in the league.data.teams array
	engine.shuffle(teams)
	-- Make fixtures object
	local fixtures = {}
	local round, fixture = {}, nil
	local games_per_week = #teams/2
	-- Initial fixture setup round
	for i=1,#teams,2 do
		fixture = {}
		fixture.home = teams[i]
		fixture.away = teams[i+1]
		fixture.type = "L"
		round[#round+1] = fixture
	end
	fixtures[1] = round
	-- We now need to rotate the fixture list to generate all fixtures
	for a=2,#teams-1 do
		round, fixture = {}, nil
		for n=1,games_per_week do
			fixture = { type = "L" }
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
			f={type="L"}
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
	local full_list = {}
	for i=1, #final_fixtures do
		local fixes = final_fixtures[i]
		for a=1, #fixes do
			local f = fixes[a]
			f.week = i
			table.insert(full_list, f)
		end
	end
	-- full_list now has EVERY league fixture, sort by week and then by home short name
	table.sort(full_list, function(a,b)
		if a.week < b.week then return true
		elseif a.week > b.week then return false
		else return g.database.get_team(a.home).short_name < g.database.get_team(b.home).short_name end
	end)
	--
	return full_list
end

function engine.get_team_league_fixtures(league, team)
	local fixtures = league.data.season.fixtures
	local team_f = {}
	for i=1, #fixtures do
		local f = fixtures[i]
		if f.home==team.id or f.away==team.id then table.insert(team_f, f) end
	end
	table.sort(team_f, function(a,b) return a.week < b.week end)
	return team_f
end

function engine.new_team_stat_object()
	return {
		pos = -1, p = 0, w = 0, d = 0, l = 0, gf = 0, ga = 0, gd = 0, pts = 0,
		hp = 0, hw = 0, hd = 0, hl = 0, hgf = 0, hga = 0, hgd = 0, hpts = 0,
		ap = 0, aw = 0, ad = 0, al = 0, agf = 0, aga = 0, agd = 0, apts = 0
	}
end

function engine.simulate_fixture(f)
	local home = g.database.get_team(f.home)
	local away = g.database.get_team(f.away)
	--
	f.home_score = love.math.random(0, 3)
	f.away_score = love.math.random(0, 3)
	if f.home_score > f.away_score then
		f.result_code = "1"
		f.winner = f.home
	elseif f.away_score > f.home_score then
		f.result_code = "2"
		f.winner = f.away
	else
		f.result_code = "X"
		f.draw = true
	end
	f.finished = true
end

function engine.update_league_table(league)
	for i = 1, #league.refs.teams do
		league.refs.teams[i].data.season.stats = engine.new_team_stat_object()
	end
	local fixtures = league.data.season.fixtures
	for i = 1, #fixtures do
		local fix = fixtures[i]
		if fix.finished then
			local home, away = g.database.get_team(fix.home), g.database.get_team(fix.away)
			local hs, as = home.data.season.stats, away.data.season.stats
			hs.p = hs.p+1;					hs.hp = hs.hp+1
			hs.gf = hs.gf+fix.home_score;	hs.hgf = hs.hgf+fix.home_score
			hs.ga = hs.ga+fix.away_score;	hs.hga = hs.hga+fix.away_score
			hs.gd = hs.gf-hs.ga;			hs.hgd = hs.hgf-hs.hga
			as.p = as.p+1;					as.ap = as.ap+1
			as.gf = as.gf+fix.away_score;	as.agf = as.agf+fix.away_score
			as.ga = as.ga+fix.home_score;	as.aga = as.aga+fix.home_score
			as.gd = as.gf-as.ga;			as.agd = as.agf-as.aga
			if fix.result_code=="1" then -- Home win
				hs.w = hs.w+1;	hs.hw = hs.hw+1
				as.l = as.l+1;	as.al = as.al+1
			elseif fix.result_code=="2" then -- Away win
				hs.l = hs.l+1;	hs.hl = hs.hl+1
				as.w = as.w+1;	as.aw = as.aw+1
			elseif fix.result_code=="X" then -- Draw
				hs.d = hs.d+1;	hs.hd = hs.hd+1
				as.d = as.d+1;	as.ad = as.ad+1
			end
			hs.pts = hs.w*3+hs.d;	hs.hpts = hs.hw*3+hs.hd
			as.pts = as.w*3+as.d;	as.apts = as.aw*3+as.ad
		else
			break
		end
	end
	--
	engine.sort_league(league)
	local week = g.database.vars.week - 1
	if week > #league.refs.teams*2 - 2 then week = #league.refs.teams*2 - 2 end
	for k=1, #league.refs.teams do
		league.refs.teams[k].data.season.past_pos[week] = league.refs.teams[k].data.season.stats.pos
	end
end

--

function engine.format_position(p)
	local last = string.sub(p, -1)
	if p>10 and p<20 then return p.."th" end
	if last=="1" then return p.."st" end
	if last=="2" then return p.."nd" end
	if last=="3" then return p.."rd" end
	return p.."th"
end

-- Sorting functions

function engine.sort_league(league)
	table.sort(league.refs.teams, engine.sort_standard)
	for i=1, #league.refs.teams do
		league.refs.teams[i].data.season.stats.pos = i
	end
end

function engine.sort_standard(a,b)
	local c,d = a,b
	a,b = a.data.season.stats, b.data.season.stats
	if a.pts > b.pts then return true
	elseif a.pts < b.pts then return false
	elseif a.gd > b.gd then return true
	elseif a.gd < b.gd then return false
	elseif a.gf > b.gf then return true
	elseif a.gf < b.gf then return false
	else return engine.sort_short_name(c, d) end
end

function engine.sort_long_name(a, b) return a.long_name < b.long_name end
function engine.sort_short_name(a, b) return a.short_name < b.short_name end

function engine.shuffle(list)
	local a = #list
	for i = a, 2, -1 do
		local j = love.math.random(1, i)
		list[i], list[j] = list[j], list[i]
	end
	return list
end

return engine