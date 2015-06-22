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
		pos = -1, p = 0, w = 0, d = 0, l = 0, gf = 0, ga = 0, gd = 0, pts = 0, cs = 0,
		hp = 0, hw = 0, hd = 0, hl = 0, hgf = 0, hga = 0, hgd = 0, hpts = 0, hcs = 0,
		ap = 0, aw = 0, ad = 0, al = 0, agf = 0, aga = 0, agd = 0, apts = 0, acs = 0
	}
end

local rand = { min = -5, max = 5 }
local p_chance = { home = .017, away = .014, home_min = .0003, away_min = .0003 }
local u_chance = 0.033
local att_weight, mid_weight, boost_weight = 0.05, 0.04, 0.0035
local min_chance = -0.004
function engine.simulate_fixture(f)
	if f.finished then return end
	engine.begin_fixture(f)
	while not f.finished do
		engine.step_fixture(f) -- Will automatically finish up the fixture once over (and flag with f.finished = true)
	end
end

function engine.begin_fixture(f, advanced) -- advanced is boolean, if true then simulate stats as well
	if f.finished then return end
	local home = g.database.get_team(f.home)
	local away = g.database.get_team(f.away)
	--
	local h_attack = home.att - away.def
	local a_attack = away.att - home.def
	local midfield = home.mid - away.mid

	-- Assign random modifier
	h_attack = h_attack + love.math.random(rand.min, rand.max)
	a_attack = a_attack + love.math.random(rand.min, rand.max)
	midfield = midfield + love.math.random(rand.min, rand.max)

	-- Assign scoring chance
	local h_chance = p_chance.home
	local a_chance = p_chance.away
	local h_attack_chance = (h_attack/100) * att_weight
	local a_attack_chance = (a_attack/100) * att_weight
	local midfield_chance = (midfield/100) * mid_weight
	local h_attack_boost = (h_attack/100) * boost_weight
	local a_attack_boost = (a_attack/100) * boost_weight
	--
	if h_attack_chance < min_chance then h_attack_chance = min_chance end
	if a_attack_chance < min_chance then a_attack_chance = min_chance end
	--
	h_chance = h_chance + h_attack_chance + h_attack_boost + midfield_chance
	a_chance = a_chance + a_attack_chance + a_attack_boost - midfield_chance
	if h_chance < p_chance.home_min then h_chance = p_chance.home_min end
	if a_chance < p_chance.away_min then a_chance = p_chance.away_min end
	--
	f.home_score, f.away_score = 0, 0
	f.h_chance, f.a_chance = h_chance, a_chance
	f.minute = 0
	--
	if advanced then
		f.advanced = true
		g.console:print(home.short_name .. " chance is " .. f.h_chance * 100 .. "%", g.skin.red)
		g.console:print(away.short_name .. " chance is " .. f.a_chance * 100 .. "%", g.skin.red)
		--
		f.possession_home = 1 -- Points of posssesion home
		f.possession_away = 1
		f.on_target_home = 0
		f.on_target_away = 0
		f.off_target_home = 0
		f.off_target_away = 0
		--
		f.possession = "-"
	end
end

function engine.step_fixture(f)
	if f.finished then return end
	f.started = true
	--
	if f.minute == 90 then
		engine.finish_fixture(f)
		return
	elseif f.minute == 45 then
		f.minute = "HT"
		f.half_time = { f.home_score, f.away_score }
		return
	elseif f.minute == "HT" then
		f.minute = 45
	end
	--
	f.minute = f.minute + 1
	--
	local h_g = f.h_chance > love.math.random()
	local a_g = f.a_chance > love.math.random()
	if h_g and a_g then h_g, a_g = false, false end
	if h_g then f.home_score = f.home_score + 1 end
	if a_g then f.away_score = f.away_score + 1 end
	--
	if f.advanced then
		-- Advanced stats
		local c_1, c_2 = f.h_chance * 13 > love.math.random(), f.a_chance * 12 > love.math.random()
		f.possession_home = f.possession_home + love.math.random(1, 3)
		f.possession_away = f.possession_away + love.math.random(1, 3)
		if c_1 then f.possession_home = f.possession_home + love.math.random(5, 8) end
		if c_2 then	f.possession_away = f.possession_away + love.math.random(5, 8) end
		f.possession = math.floor(f.possession_home * 100 / (f.possession_home + f.possession_away) + .5)
		--
		local c_1, c_2 = f.h_chance * 7 > love.math.random(), f.a_chance * 7 > love.math.random()
		if h_g then f.on_target_home = f.on_target_home + 1 end
		if a_g then f.on_target_away = f.on_target_away + 1 end
		if c_1 then
			if love.math.random() > 0.55 then
				f.on_target_home = f.on_target_home + 1
			else
				f.off_target_home = f.off_target_home + 1
			end
		end
		if c_2 then
			if love.math.random() > 0.55 then
				f.on_target_away = f.on_target_away + 1
			else
				f.off_target_away = f.off_target_away + 1
			end
		end
	end
end

function engine.finish_fixture(f)
	if f.home_score > f.away_score then
		f.winner = f.home
		f.result_code = "1"
	elseif f.away_score > f.home_score then
		f.winner = f.away
		f.result_code = "2"
	else
		f.draw = true
		f.result_code = "X"
	end
	f.finished = true
	f.minute = "FT"
	-- Remove unnecessary chance data
	f.h_chance, f.a_chance = nil, nil
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
			hs.cs, hs.hcs = hs.cs + (fix.away_score==0 and 1 or 0), hs.hcs + (fix.away_score==0 and 1 or 0)
			as.cs, as.acs = as.cs + (fix.home_score==0 and 1 or 0), as.acs + (fix.home_score==0 and 1 or 0)
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