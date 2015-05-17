local database = {}

database.database_folder = "db/"
database.file_extension = "sssdb"

database.team_list = {}
database.team_dict = {}
database.league_list = {}
database.league_dict = {}

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

function database.get_filename_and_extension(filename)
	return filename:match("^([^%.]*)%.?(.*)$") -- "myfile.lua" -> "myfile", "lua"
end

-- Create team
function database.create_team(raw)
	local team = {}
	team.id = assert(tonumber(raw.id), "A team had no ID!")
	team.long_name = raw.long_name or "<LONG_NAME>"
	team.short_name = raw.short_name or "<SHORT_NAME>"
	team.def = tonumber(raw.def) or 50
	team.mid = tonumber(raw.mid) or 50
	team.att = tonumber(raw.att) or 50
	team.league_id = tonumber(raw.league_id) or 0
	team.color1 = love.graphics.hexToRgb(raw.color1) or { 255, 255, 255, 255 }
	team.color2 = love.graphics.hexToRgb(raw.color2) or { 255, 0, 0, 255 }
	team.color3 = love.graphics.hexToRgb(raw.color3) or love.graphics.darken(raw.color1)
	return team
end

function database.setup_team(team)
	team.data = {}
	team.data.history = {}
	team.data.history.honours = {}
	team.data.history.past_seasons = {}
end

function database.create_league(raw)
	local league = {}
	--id,long_name,short_name,level,flag,color1,color2,color3,level_up,level_up_boost_min,level_up_boost_max,level_down,level_down_boost_min,level_down_boost_max,promoted,relegated,playoffs,r_playoffs
	league.id = assert(tonumber(raw.id), "A league had no ID!")
	league.long_name = raw.long_name or "<LONG_NAME>"
	league.short_name = raw.short_name or "<SHORT_NAME>"
	league.level = tonumber(raw.level) or 1
	league.flag = assert(raw.flag, "A league had no flag!")
	league.color1 = love.graphics.hexToRgb(raw.color1) or { 50, 50, 87, 255 }
	league.color2 = love.graphics.hexToRgb(raw.color2) or { 255, 255, 255, 255 }
	league.color3 = love.graphics.hexToRgb(raw.color3) or love.graphics.darken(raw.color1)
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
end

function database.create_nation(raw)
	local nation = {}
	nation.id = assert(tonumber(raw.id), "A nation had no ID!")
	nation.code = assert(raw.code, "A nation had no nation code!")
	nation.short_name = raw.short_name or "<SHORT_NAME>"
	return nation
end

function database.setup_nation(nation)
	nation.data = {}
	nation.data.leagues = {} -- all league_ids
end

return database