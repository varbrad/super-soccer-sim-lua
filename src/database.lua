local database = {}

database.database_folder = "db/"
database.file_extension = "sssdb"

database.team_list = {}
database.team_dict = {}
database.league_list = {}
database.league_dict = {}
database.vars = {}

-- Finds all available database files in the users save directory (will always include the default db)
function database.find_database_files()
	local files = love.filesystem.getDirectoryItems(database.database_folder)
	local db_files = {}
	for i=1, #files do
		local filepath = files[i]
		local name, extension = database.get_filename_and_extension(filepath)
		if extension==database.file_extension then
			local o = { name = name, path = filepath }
			table.insert(db_files, o)
		end
	end
	return db_files
end

-- Gets a preview look at a database given a database_folder path
function database.get_preview(file)
	local file_path = database.database_folder .. file.path
	local mount_dir = database.database_folder .. file.name
	assert(love.filesystem.mount(file_path, mount_dir), "Mount failed!")
	--
	local raw_teams_csv = love.filesystem.read(mount_dir.."/teams.csv")
	local raw_leagues_csv = love.filesystem.read(mount_dir.."/leagues.csv")
	local raw_nations_csv = love.filesystem.read(mount_dir.."/nations.csv")
	local raw_vars = love.filesystem.read(mount_dir.."/vars")
	--
	assert(love.filesystem.unmount(file_path), "Unmount failed!")
	--
	local teams = g.csv.use(raw_teams_csv, { header = true })
	local leagues = g.csv.use(raw_leagues_csv, { header = true })
	local nations = g.csv.use(raw_nations_csv, { header = true })
	--
	local team_count, league_count, nation_count = 0, 0, 0
	--
	database.team_list = {}
	database.team_dict = {}
	database.league_list = {}
	database.league_dict = {}
	database.nation_list = {}
	database.nation_dict = {}
	database.vars = raw_vars and loadstring("return " .. raw_vars)() or { year = 2015 }
	--
	for fields in teams:lines() do
		local team = database.create_team(fields)
		table.insert(database.team_list, team)
		database.team_dict[team.id] = team
	end
	--
	for fields in leagues:lines() do
		local league = database.create_league(fields)
		table.insert(database.league_list, league)
		database.league_dict[league.id] = league
	end
	--
	for fields in nations:lines() do
		local nation = database.create_nation(fields)
		table.insert(database.nation_list, nation)
		database.nation_dict[nation.code] = nation
	end
	-- Sort the list of nations in alphabetical order
	table.sort(database.nation_list, function(a, b) return a.short_name < b.short_name end)
	--
	raw_teams_csv, raw_leagues_csv, raw_nations_csv = nil, nil, nil
	--
	return true
end

function database.get_team(id) return database.team_dict[id] end
function database.get_league(id) return database.league_dict[id] end
function database.get_nation(flag) return database.nation_dict[flag] end

function database.set_view_team(id) database.vars.view.team_id = id end
function database.get_view_team() return database.team_dict[database.vars.view.team_id] end
function database.set_view_league(id) database.vars.view.league_id = id end
function database.get_view_league() return database.league_dict[database.vars.view.league_id] end

function database.set_player_team(id) database.vars.player.team_id = id end
function database.get_player_team() return database.team_dict[database.vars.player.team_id] end
function database.get_player_league() return database.get_player_team().refs.league end
function database.get_player_nation() return database.get_player_league().refs.nation end

function database.get_random_team() return database.team_list[love.math.random(1,#database.team_list)] end
function database.get_random_league() return database.league_list[love.math.random(1,#database.league_list)] end
function database.get_random_nation() return database.nation_list[love.math.random(1,#database.nation_list)] end

function database.setup()
	for i=#database.nation_list, 1, -1 do
		local nation = database.nation_list[i]
		database.setup_nation(nation)
	end
	for i=#database.league_list, 1, -1 do
		local league = database.league_list[i]
		database.setup_league(league)
	end
	for i=#database.team_list, 1, -1 do
		local team = database.team_list[i]
		database.setup_team(team)
	end
end

function database.process()
	for i=#database.nation_list, 1, -1 do
		local nation = database.nation_list[i]
		local ok = database.process_nation(nation)
		if not ok then
			--print(nation.short_name .. " removed as it had no leagues")
			database.nation_dict[nation.code] = nil
			table.remove(database.nation_list, i)
		end
		-- Sort nations league refs by level
		table.sort(nation.refs.leagues, function(a,b) return a.level < b.level end)
	end
	for i=#database.league_list, 1, -1 do
		local league = database.league_list[i]
		local ok = database.process_league(league)
		if not ok then
			--print(league.short_name .. " removed as it had no teams")
			database.league_dict[league.id] = nil
			table.remove(database.league_list, i)
		end
		-- Sort teams by long_name
		table.sort(league.refs.teams, function(a,b) return a.long_name < b.long_name end)
	end
	for i=#database.team_list, 1, -1 do
		local team = database.team_list[i]
		local ok = database.process_team(team)
		if not ok then
			--print(team.short_name .. " removed as it had no league")
			database.team_dict[team.id] = nil
			table.remove(database.team_list, i)
		end
	end
end

function database.new_game(player_team_id)
	local vars = database.vars
	vars.__type = "vars"
	-- vars.year = (set in database file)
	vars.week = 1
	vars.player = {}
	database.set_player_team(player_team_id) -- equiv. vars.player.team_id = player_team_id
	vars.view = {}
	vars.view.league_id = database.get_player_league()
	vars.view.team_id = player_team_id
	--
	local team = database.get_player_team()
	local def, mid, att = team.def, team.mid, team.att
	vars.players = g.players.generate_team(def, mid, att, team.refs.league.flag) -- Gets a preset team of 21 players based around team stats
	-- Inbox
	vars.inbox = {}
	-- Financial
	vars.finance = {}
	vars.finance.cash = g.players.total_wage_bill(vars.players) * love.math.random(85, 115) -- Possible DIFFICULTY level set here (e.g. hard = 50, easy = 150)
end

function database.new_season()
	-- DOESNT handle finalising older seasons!!!!
	for a=1, #database.nation_list do
		local nation = database.nation_list[a]
		--
		-- Don't need to add anything to the nations object
		--
		for b=1, #nation.refs.leagues do
			local league = nation.refs.leagues[b]
			--
			league.data.season = {}
			league.data.season.year = database.vars.year
			league.data.season.fixtures = g.engine.generate_league_fixtures(league)
			league.data.season.records = { min = {}, max = {} }
			--
			for c=1, #league.refs.teams do
				local team = league.refs.teams[c]
				--
				team.data.season = {}
				team.data.season.past_pos = {}
				team.data.season.stats = g.engine.new_team_stat_object()
				team.data.season.year = database.vars.year
				team.data.season.league = league.id
				--
			end
			--
			g.engine.sort_league(league)
			--
		end
	end
end

function database.end_season()
	for a = 1, #database.nation_list do
		local nation = database.nation_list[a]
		--
		for b = 1, #nation.refs.leagues do
			local league = nation.refs.leagues[b]
			--
			local league_season_records = league.data.season.records
			local league_alltime_records = league.data.history.records
			-- Did we break any historic records this season?
			for k,v in pairs(league_season_records.min) do
				if league_alltime_records.min[k]==nil or v.value < league_alltime_records.min[k].value then league_alltime_records.min[k] = v end
			end
			for k,v in pairs(league_season_records.max) do
				if league_alltime_records.max[k]==nil or v.value > league_alltime_records.max[k].value then league_alltime_records.max[k] = v end
			end
			--
			league.data.season.records = nil
			--
			local total_teams = #league.data.teams
			local lub_min, lub_max = league.level_up_boost_min, league.level_up_boost_max
			local ldb_min, ldb_max = league.level_down_boost_min, league.level_down_boost_max
			local top3 = {}
			--
			for c = 1, #league.refs.teams do
				local team = league.refs.teams[c]
				--
				local promoted, relegated = false, false
				local position = team.data.season.stats.pos
				-- If top 3 in the league, then add this teams id to the position of the leagues top3
				if position == 1 or position == 2 or position == 3 then
					top3[position] = team.id
				end
				--
				if league.level_up~=-1 and (position <= league.promoted or position <= league.promoted + (league.playoffs > 0 and 1 or 0)) then
					-- Promoted
					promoted = true
					team.league_id = league.level_up
					--
				elseif league.level_down~=-1 and total_teams - position < league.relegated then
					-- Relegated
					relegated = true
					team.league_id = league.level_down
					--
				end
				-- Random fluctuation in team quality, based on if they got promoted or relegated (boost vs decline)
				-- Also random fluctutaion by +-1 if they remained the same.
				-- Will eventually use a more advanced metric to determine this, but works OK for now.
				local b_min = promoted and lub_min or (relegated and ldb_min or -1)
				local b_max = promoted and lub_max or (relegated and ldb_max or 1)
				if not promoted and position==1 then -- Champions of the league
					b_min, b_max = -2, 2 -- Stop absolute monopolies on leagues
				end
				local r1, r2, r3 = love.math.random(b_min, b_max), love.math.random(b_min, b_max), love.math.random(b_min, b_max)
				team.def, team.mid, team.att = team.def + r1, team.mid + r2, team.att + r3
				--
				local compact_season = {}
				local s = team.data.season.stats
				compact_season.stats = { p=s.p, w=s.w, d=s.d, l=s.l, gf=s.gf, ga=s.ga, gd=s.gd, pts=s.pts, pos=s.pos}
				compact_season.league = team.data.season.league -- id, not ref
				compact_season.promoted_or_relegated = promoted and "P" or (relegated and "R" or nil)
				compact_season.league_team_count = total_teams
				compact_season.year = database.vars.year
				-- Did we break any league.data.history.records? Go through all stats
				--[[
				for k,v in pairs(team.data.season.stats) do
					if league_records[k]==nil or v > league_records[k].value then league_records[k] = { year = database.vars.year, value = v, team = team.id } end
				end
				--]]--
				table.insert(team.data.history.past_seasons, compact_season)
			end
			--
			table.insert(league.data.history.past_winners, { { team = top3[1] }, { team = top3[2] }, { team = top3[3] }, year = database.vars.year })
			--
		end
	end
	--
	for i=1, #database.league_list do
		local lge = database.league_list[i]
		lge.data.teams = {}
	end
	for i=1, #database.team_list do
		local team = database.team_list[i]
		local league = database.get_league(team.league_id)
		table.insert(league.data.teams, team.id)
	end
	-- We need to re-process for everything to get re-reffed!
	database.process()
	--
	database.vars.year = database.vars.year + 1
	database.vars.week = 1
end

function database.advance_week()
	database.vars.week = database.vars.week + 1
	if database.vars.week == 53 then
		database.end_season()
		database.new_season()
		return
	end
	-- Simulate all fixtures from the previous week
	for i = 1, #database.league_list do
		local league = database.league_list[i]
		local fixtures = league.data.season.fixtures
		for i=1, #fixtures do
			local f = fixtures[i]
			if f.week == database.vars.week - 1 then
				g.engine.simulate_fixture(f)
			elseif f.week > database.vars.week then
				break
			end
		end
		g.engine.update_league_table(league)
		-- Update W, D, L, etc. league.data.season.records!
		-- league.data.season.records needs to be reset too!
		league.data.season.records = { min = {}, max = {} }
		local season_records = league.data.season.records
		for i=1, #league.refs.teams do
			local team = league.refs.teams[i]
			local stats = team.data.season.stats
			for k,v in pairs(stats) do
				if season_records.min[k]==nil or v < season_records.min[k].value then season_records.min[k] = { team = team.id, value = v, year = g.database.vars.year } end
				if season_records.max[k]==nil or v > season_records.max[k].value then season_records.max[k] = { team = team.id, value = v, year = g.database.vars.year } end
			end
		end
		--
	end
	-- GAME
	-- Reduce the total cash of the club by the total_wage_bill
	local total_wage_bill = g.players.total_wage_bill(database.vars.players)
	database.vars.finance.cash = database.vars.finance.cash - total_wage_bill
	--
end

function database.save_game()
	-- Testing to see if this fixes the luajit 65,536 bug
	local t1 = love.timer.getTime()
	local data = {}
	for i=1, #database.team_list do
		-- strip its ref
		local t = database.team_list[i]
		t.refs = nil
		table.insert(data, g.ser(t))
	end
	for i=1, #database.league_list do
		local l = database.league_list[i]
		l.refs = nil;
		table.insert(data, g.ser(l))
	end
	for i=1, #database.nation_list do
		local n = database.nation_list[i]
		n.refs = nil;
		table.insert(data, g.ser(n))
	end
	table.insert(data, g.ser(database.vars))
	--
	love.filesystem.createDirectory("save")
	love.filesystem.write("save/save.sav", table.concat(data, "\f"))
	--
	g.console:print("Took " .. (love.timer.getTime()-t1) .. " seconds to save game!", g.skin.blue)
	--
	database.process()
	--
	g.notification:new("Game Saved!", "save")
end

function database.load_game()
	local t1 = love.timer.getTime()
	if not love.filesystem.exists("save/save.sav") then return false, "No saved game data found!" end
	database.team_list, database.league_list, database.nation_list, database.vars = {}, {}, {}, nil
	local data = love.filesystem.read("save/save.sav")
	for item_raw in string.gmatch(data, "([^\f]+)") do
		local item = loadstring(item_raw)()
		if item.__type == "team" then table.insert(database.team_list, item)
		elseif item.__type == "league" then table.insert(database.league_list, item)
		elseif item.__type == "nation" then table.insert(database.nation_list, item)
		elseif item.__type == "vars" then database.vars = item end
	end
	--
	database.build_dict()
	--
	database.process()
	--
	g.console:print("Took " .. (love.timer.getTime()-t1) .. " seconds to load game!", g.skin.green)
	--
	g.notification:new("Game Loaded!", "load")
	return true
end

function database.build_dict()
	database.team_dict, database.league_dict, database.nation_dict = {}, {}, {}
	for i=1, #database.team_list do
		local team = database.team_list[i]
		database.team_dict[team.id] = team
	end
	for i=1, #database.league_list do
		local league = database.league_list[i]
		database.league_dict[league.id] = league
	end
	for i=1, #database.nation_list do
		local nation = database.nation_list[i]
		database.nation_dict[nation.code] = nation
	end
end

function database.get_league_fixtures_for_week(league, week)
	local ret = {}
	if week==0 then return ret end
	local fixtures = league.data.season.fixtures
	for i=1, #fixtures do
		local fix = fixtures[i]
		if fix.week == week then
			table.insert(ret, fix)
		end
	end
	return ret
end

function database.get_filename_and_extension(filename)
	return filename:match("^([^%.]*)%.?(.*)$") -- "myfile.lua" -> "myfile", "lua"
end

-- Create team
function database.create_team(raw)
	local team = {}
	team.__type = "team"
	team.id = assert(tonumber(raw.id), "A team had no ID!")
	team.long_name = raw.long_name or "<LONG_NAME>"
	team.short_name = raw.short_name or "<SHORT_NAME>"
	team.def = tonumber(raw.def) or 50
	team.mid = tonumber(raw.mid) or 50
	team.att = tonumber(raw.att) or 50
	team.league_id = tonumber(raw.league_id) or 0
	team.color1 = love.graphics.hexToRgb(raw.color1) or { 255, 255, 255, 255 }
	team.color2 = love.graphics.hexToRgb(raw.color2) or { 255, 0, 0, 255 }
	team.color3 = raw.color3~="" and love.graphics.hexToRgb(raw.color3) or love.graphics.darken(team.color1)
	return team
end

function database.setup_team(team)
	team.data = {}
	team.data.history = {}
	team.data.history.honours = {}
	team.data.history.past_seasons = {}
	--
	local league = database.league_dict[team.league_id]
	if league then
		table.insert(league.data.teams, team.id)
	end
end

function database.process_team(team)
	if team.league_id == 0 then return false end
	team.refs = {}
	team.refs.league = database.league_dict[team.league_id]
	return true
end

--

function database.create_league(raw)
	local league = {}
	league.__type = "league"
	league.id = assert(tonumber(raw.id), "A league had no ID!")
	league.long_name = raw.long_name or "<LONG_NAME>"
	league.short_name = raw.short_name or "<SHORT_NAME>"
	league.code = raw.code or nil -- Used for team history graph. NOT UNIQUE, so dont use for anything unique sensitive
	league.level = tonumber(raw.level) or 1
	league.flag = assert(raw.flag, "A league had no flag!")
	league.color1 = love.graphics.hexToRgb(raw.color1) or { 50, 50, 87, 255 }
	league.color2 = love.graphics.hexToRgb(raw.color2) or { 255, 255, 255, 255 }
	league.color3 = raw.color3~="" and love.graphics.hexToRgb(raw.color3) or love.graphics.darken(league.color1)
	league.level_up = tonumber(raw.level_up) or -1
	league.level_up_boost_min = tonumber(raw.level_up_boost_min) or 0
	league.level_up_boost_max = tonumber(raw.level_up_boost_max) or 0
	league.level_down = tonumber(raw.level_down) or -1
	league.level_down_boost_min = tonumber(raw.level_down_boost_min) or 0
	league.level_down_boost_max = tonumber(raw.level_down_boost_max) or 0
	league.promoted = tonumber(raw.promoted) or 0
	league.relegated = tonumber(raw.relegated) or 0
	league.playoffs = tonumber(raw.playoffs) or 0
	league.r_playoffs = tonumber(raw.r_playoffs) or 0
	return league
end

function database.setup_league(league)
	-- Add the basic objects and structure to the league object
	league.data = {}
	league.data.teams = {}
	league.data.history = {}
	league.data.history.past_winners = {}
	league.data.history.records = { min = {}, max = {} }
	--
	local nation = database.nation_dict[league.flag]
	if nation then
		table.insert(nation.data.leagues, league.id)
	end
end

function database.process_league(league)
	league.refs = {}
	league.refs.teams = {}
	league.refs.nation = database.nation_dict[league.flag]
	if #league.data.teams < 1 or not league.refs.nation then return false end
	for i=1, #league.data.teams do
		table.insert(league.refs.teams, database.team_dict[league.data.teams[i]])
	end
	return true
end

--

function database.create_nation(raw)
	local nation = {}
	nation.__type = "nation"
	nation.id = assert(tonumber(raw.id), "A nation had no ID!")
	nation.code = assert(raw.code, "A nation had no nation code!")
	nation.short_name = raw.short_name or "<SHORT_NAME>"
	return nation
end

function database.setup_nation(nation)
	nation.data = {}
	nation.data.leagues = {} -- all league_ids
end

function database.process_nation(nation)
	nation.refs = {}
	nation.refs.leagues = {}
	--if #nation.data.leagues < 1 then return false end
	for i=1, #nation.data.leagues do
		table.insert(nation.refs.leagues, database.league_dict[nation.data.leagues[i]])
	end
	return true
end

-- Some debugging logging functions

function database.log_hierarchy()
	love.filesystem.write("hierarchy", "Hierarchy of database\n\n")
	for a=1, #database.nation_list do
		local nation = database.nation_list[a]
		love.filesystem.append("new_season", "" .. nation.short_name .. " (" .. nation.id .. ")\n")
		for b=1, #nation.refs.leagues do
			local league = nation.refs.leagues[b]
			love.filesystem.append("new_season", "\t" .. league.long_name .. " (" .. league.id .. ")\n")
			for c=1, #league.refs.teams do
				local team = league.refs.teams[c]
				love.filesystem.append("new_season", "\t\t" .. team.long_name .. " (" .. team.id .. ")\n")
			end
		end
	end
end

return database