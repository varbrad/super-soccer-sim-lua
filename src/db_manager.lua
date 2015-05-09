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
		team.__type = "team"
		if team.id then team.id = tonumber(team.id) end
		if team.league_id then team.league_id = tonumber(team.league_id) else team.league_id = 0 end -- default league id to 0 if not present
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
		if league.id then league.id = tonumber(league.id) end
		league.__type = "league"
		league.teams = {}
		league.history = {}
		league.history.past_winners = {}
		league.level_up = tonumber(league.level_up) or -1
		league.level_up_boost_min = tonumber(league.level_up_boost_min) or 0
		league.level_up_boost_max = tonumber(league.level_up_boost_max) or 0
		league.level_down = tonumber(league.level_down) or -1
		league.level_down_boost_min = tonumber(league.level_down_boost_min) or 0
		league.level_down_boost_max = tonumber(league.level_down_boost_max) or 0
		league.promoted = tonumber(league.promoted) or 0
		league.relegated = tonumber(league.relegated) or 0
		league.playoffs = tonumber(league.playoffs) or 0
		league.r_playoffs = tonumber(league.r_playoffs) or 0
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
		team.color1 = hex(team.color1) or g.skin.black
		team.color2 = hex(team.color2) or g.skin.white
		team.color3 = hex(team.color3) or love.graphics.darken(team.color1)
		team.att = tonumber(team.att) or 50
		team.mid = tonumber(team.mid) or 50
		team.def = tonumber(team.def) or 50
		team.history = {}
		team.history.honours = {}
		team.season = {}
		team.season.past_pos = {}
		team.season.stats = dbm.new_stats()
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
		if league.id == 0 or #league.teams==0 then
			league.active = false
			league.season.fixtures = {}
		else
			league.active = true
			league.season.fixtures = dbm.generate_fixtures(league)
		end
		dbm.sort_league(league)
	end
	g.console:print("All leagues fully processed", g.skin.green)
	for i=1, #dbm.teams do
		local team = dbm.teams[i]
		team.season.fixtures = dbm.get_team_fixtures(team, team.league)
	end
end

function dbm.end_of_season()
	for i=1, #dbm.teams do
		local team = dbm.teams[i]
		if team.league.active then
			-- Lets figure out if this team should be promoted or relegated
			local promoted = team.league.promoted
			local relegated = team.league.relegated
			local final_pos = team.season.stats.pos
			--
			local total_teams = #team.league.teams
			local old_id = team.league_id
			if team.league.level_up~=-1 and (final_pos <= promoted or final_pos <= promoted + (team.league.playoffs > 0 and 1 or 0)) then
				-- promoted
				team.league_id = team.league.level_up
				-- give this team a random boost to their stats (to help cope with the higher league!)
				local boost_min, boost_max = dbm.league_dict[old_id].level_up_boost_min, dbm.league_dict[old_id].level_up_boost_max
				local r1, r2, r3 = love.math.random(boost_min, boost_max), love.math.random(boost_min, boost_max), love.math.random(boost_min, boost_max)
				team.def, team.mid, team.att = team.def + r1, team.mid + r2, team.att +  r3
			elseif team.league.level_down~=-1 and total_teams - final_pos < relegated then
				-- relegated
				team.league_id = team.league.level_down
				-- give htis team a negative boost to lower their ability
				local boost_min, boost_max = dbm.league_dict[old_id].level_down_boost_min, dbm.league_dict[old_id].level_down_boost_max
				local r1, r2, r3 = love.math.random(boost_min, boost_max), love.math.random(boost_min, boost_max), love.math.random(boost_min, boost_max)
				team.def, team.mid, team.att = team.def + r1, team.mid + r2, team.att +  r3
			else
				-- give teams a random + or -
				local r1, r2, r3 = love.math.random(-1, 1), love.math.random(-1, 1), love.math.random(-1, 1)
				if love.math.random() > 0.7 then team.def, team.mid, team.att = team.def + r1, team.mid + r2, team.att + r3 end
			end
			if team.def > 100 then team.def = 100 end
			if team.mid > 100 then team.mid = 100 end
			if team.att > 100 then team.att = 100 end
		end
	end
	for i=1, #dbm.leagues do
		local league = dbm.leagues[i]
		dbm.sort_league(league)
		table.insert(league.history.past_winners, {{ team = league.teams[1] }, { team = league.teams[2] }, { team = league.teams[3] }, season = g.vars.season})
		league.teams = {}
	end
	for i=1, #dbm.teams do
		local team = dbm.teams[i]
		team.league = dbm.league_dict[team.league_id]
		table.insert(team.league.teams, team)
		team.season = {}
		team.season.past_pos = {}
		team.season.stats = dbm.new_stats()
	end
	for i=1, #dbm.leagues do
		local league = dbm.leagues[i]
		if league.active then
			league.season = {}
			league.season.fixtures = dbm.generate_fixtures(league)
			dbm.sort_league(league)
		end
	end
	for i=1, #dbm.teams do
		local team = dbm.teams[i]
		team.season.fixtures = dbm.get_team_fixtures(team, team.league)
	end
	g.console:print("Season "..g.vars.season.."/"..(g.vars.season+1).." finished.", g.skin.blue)
	g.vars.week = 1
	g.vars.season = g.vars.season + 1
	g.console:print("New Season generated", g.skin.green)
	g.console:hr()
	g.state.refresh_all()
end

-- Calculates average strengths of teams in league
function dbm.average_strength(league)
	local str = {0, 0, 0}
	local c = #league.teams
	for i=1, c do
		local t = league.teams[i]
		str[1] = str[1] + t.def
		str[2] = str[2] + t.mid
		str[3] = str[3] + t.att
	end
	str[1], str[2], str[3] = math.floor(str[1] / c + .5), math.floor(str[2] / c + .5), math.floor(str[3] / c + .5)
	return str
end

function dbm.format_position(p)
	local last = string.sub(p, -1)
	if p>10 and p<20 then return p.."th" end
	if last=="1" then return p.."st" end
	if last=="2" then return p.."nd" end
	if last=="3" then return p.."rd" end
	return p.."th"
end

function dbm.generate_fixtures(league) -- Generates all league fixtures for a season
	print("League is ", league.short_name, "teams = ",#league.teams)
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

function dbm.advance_week()
	g.vars.week = g.vars.week + 1
	if g.vars.week > 52 then g.vars.week=52; return end
	for i, league in ipairs(dbm.leagues) do
		local fixtures = nil
		if league.season.fixtures then fixtures = league.season.fixtures[g.vars.week-1] end
		if fixtures then
			for k=1, #fixtures do
				local f = fixtures[k]
				dbm.simulate_fixture(f)
			end
			dbm.calculate_league(league)
		end
	end
end

function dbm.sort_league(league)
	table.sort(league.teams, dbm.sort_standard)
	for i=1, #league.teams do
		league.teams[i].season.stats.pos = i
	end
end

function dbm.sort_standard(a,b)
	local c,d = a,b
	a,b = a.season.stats, b.season.stats
	if a.pts > b.pts then return true
	elseif a.pts < b.pts then return false
	elseif a.gd > b.gd then return true
	elseif a.gd < b.gd then return false
	elseif a.gf > b.gf then return true
	elseif a.gf < b.gf then return false
	else return c.short_name < d.short_name end
end

function dbm.shuffle(t)
	local a = #t
	for i = a, 2, -1 do
		local j = love.math.random(1, i)
		t[i], t[j] = t[j], t[i]
	end
	return t
end

function dbm.calculate_league(league)
	for i=1, #league.teams do
		league.teams[i].season.stats = dbm.new_stats()
	end
	dbm.sort_league(league)
	if g.vars.week==1 then return end
	local to_week = g.vars.week-1
	if to_week > #league.season.fixtures then to_week = #league.season.fixtures end
	for i=1,to_week do
		local fixtures = league.season.fixtures[i]
		for n=1,#fixtures do
			local fix = fixtures[n]
			local home,away = fix.home, fix.away
			local hs,as = home.season.stats, away.season.stats
			hs.p = hs.p+1;					hs.hp = hs.hp+1
			hs.gf = hs.gf+fix.home_score;	hs.hgf = hs.hgf+fix.home_score
			hs.ga = hs.ga+fix.away_score;	hs.hga = hs.hga+fix.away_score
			hs.gd = hs.gf-hs.ga;			hs.hgd = hs.hgf-hs.hga
			as.p = as.p+1;					as.ap = as.ap+1
			as.gf = as.gf+fix.away_score;	as.agf = as.agf+fix.away_score
			as.ga = as.ga+fix.home_score;	as.aga = as.aga+fix.home_score
			as.gd = as.gf-as.ga;			as.agd = as.agf-as.aga
			if fix.winner==home then
				hs.w = hs.w+1;	hs.hw = hs.hw+1
				as.l = as.l+1;	as.al = as.al+1
			elseif fix.winner==away then
				hs.l = hs.l+1;	hs.hl = hs.hl+1
				as.w = as.w+1;	as.aw = as.aw+1
			elseif fix.draw then
				hs.d = hs.d+1;	hs.hd = hs.hd+1
				as.d = as.d+1;	as.ad = as.ad+1
			end
			hs.pts = hs.w*3+hs.d;	hs.hpts = hs.hw*3+hs.hd
			as.pts = as.w*3+as.d;	as.apts = as.aw*3+as.ad
		end
		dbm.sort_league(league)
		for k=1,#league.teams do
			league.teams[k].season.past_pos[to_week] = league.teams[k].season.stats.pos;
		end
	end
end

local rand = {min=-5,max=5}
local preset_chance = {home=0.017, away=0.0134; home_min=0.0003; away_min=0.0003}
local upset_chance = 0.033
local att_weight, mid_weight, boost_weight = 0.05, 0.04, 0.0035
local min_chance = -0.004
-- Should determine the winner, and finish the fixture. Optional s1 and s2 score params.
function dbm.simulate_fixture(f,s1,s2)
	--
	-- SIMUALTE THE GAME!
	local home_attack = f.home.att - f.away.def
	local away_attack = f.away.att - f.home.def
	local midfield = f.home.mid - f.away.mid
	-- 2. Assign a random modifier (rand.min -> rand.max)
	home_attack = home_attack + love.math.random(rand.min, rand.max)
	away_attack = away_attack + love.math.random(rand.min, rand.max)
	midfield = midfield + love.math.random(rand.min, rand.max)
	-- 3. Assign 'scoring chance'
	local home_chance = preset_chance.home
	local away_chance = preset_chance.away
	local home_attack_chance = (home_attack/100) * att_weight
	local away_attack_chance = (away_attack/100) * att_weight
	local midfield_chance = (midfield/100) * mid_weight
	local home_attack_boost = (home_attack/100) * boost_weight
	local away_attack_boost = (away_attack/100) * boost_weight
	-- 4. Check if chances are smaller than minimums
	if home_attack_chance < min_chance then home_attack_chance = min_chance end
	if away_attack_chance < min_chance then away_attack_chance = min_chance end
	-- 5. Sum chances
	home_chance = home_chance + home_attack_chance + home_attack_boost + midfield_chance
	away_chance = away_chance + away_attack_chance + away_attack_boost - midfield_chance
	if home_chance < preset_chance.home_min then home_chance = preset_chance.home_min end
	if away_chance < preset_chance.away_min then away_chance = preset_chance.away_min end
	--
	f.home_score, f.away_score = 0, 0
	for i=1,90 do
		if i==46 then f.half_time = {f.home_score,f.away_score} end
		local h_g = home_chance > love.math.random()
		local a_g = away_chance > love.math.random()
		if h_g and a_g then h_g, a_g = false, false end
		if h_g then f.home_score = f.home_score + 1 end
		if a_g then f.away_score = f.away_score + 1 end
	end
	if upset_chance > love.math.random() then
		if love.math.random() > .5 then f.away_score = f.home_score else f.home_score, f.away_score = f.away_score, f.home_score end
	end
	--
	if f.home_score > f.away_score then
		f.winner = f.home
		f.loser = f.away
	elseif f.away_score > f.home_score then
		f.winner = f.away
		f.loser = f.home
	else
		f.draw = true
	end
	f.finished = true
end

function dbm.new_stats()
	return {pos=-1;p=0;w=0;d=0;l=0;gf=0;ga=0;gd=0;pts=0;	hp=0;hw=0;hd=0;hl=0;hgf=0;hga=0;hgd=0;hpts=0;	ap=0;aw=0;ad=0;al=0;agf=0;aga=0;agd=0;apts=0;}
end


return dbm