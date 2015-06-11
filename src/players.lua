local players = {}

function players.generate_player(settings)
	settings = settings or {}
	local p = {}
	p.age = settings.age or love.math.random(18, 33)
	p.rating = settings.rating or love.math.random(60, 70)
	p.potential = settings.potential or love.math.random(65, 75)
	if p.rating > p.potential then p.potential = p.rating + 10 end
	p.nationality = players.generate_nationality(settings.nationality_data)
	p.first_name, p.last_name = players.generate_name(p.nationality)
	p.form = love.math.random(-5, 5)
	p.contract_wage = players.generate_wage(p.age, p.rating)
	p.contract_time = love.math.random(1, 5)
	p.position = settings.position or "gk"
	p.position_value = p.position=="gk" and 1 or p.position=="df" and 2 or p.position=="mf" and 3 or 4
	p.value = players.generate_value(p)
	return p
end

function players.generate_team(def, mid, att, nation)
	-- Generate a total of 21 players with stats roughly equal (give or take +-2 or so) to the incoming stats of a team
	-- GK = 3		-- DF = 7		-- MF = 7		-- AT = 4
	local p = {}
	local gk = { {0, 3}, {-2, 1}, {-3, -1} }
	for i = 1, 3 do -- 1st = 0, 3 (avg 1.5), 2nd = -2, 1 (avg -.5), 3rd = -3, -1 (avg -2), total averages = +1.5, -.5, -2 = total -1 (GK is special, should be -1)
		local rating = def + love.math.random(gk[i][1], gk[i][2])
		local settings = { rating = rating, position = "gk" }
		settings.nationality_data = { {70, nation}, {30, "other"} }
		table.insert(p, players.generate_player(settings))
	end
	-- 1st = 2, 5 (avg 3.5), 2nd = 1, 3 (avg 2), 3rd = -1, 1 (avg 0), 4th = -3, 1 (avg -1), 5th = -5, -2 (avg -3.5), 6th = -5, -2 (avg -3.5), 7th = -6, -2 (avg -4)
	-- Averages = 3.5, 2.0, 0.0, -1.0, -3.5, -3.5, -4
	local df = { {3, 5}, {0, 2}, {-2, 1}, {-3, 1}, {-5, -2}, {-6, -3}, {-7, -3} }
	for i = 1, #df do
		local rating = def + love.math.random(df[i][1], df[i][2])
		local age = (i==6 or i==7) and love.math.random(17,20) or nil -- Last 2 players will auto be under 21
		local settings = { rating = rating, position = "df", age = age}
		settings.nationality_data = { {70, nation}, {30, "other"} }
		table.insert(p, players.generate_player(settings))
	end
	--
	for i=1, #df do
		local rating = mid + love.math.random(df[i][1], df[i][2])
		local age = (i==5 or i==7) and love.math.random(17,20) or nil
		local settings = { rating = rating, position = "mf", age = age}
		settings.nationality_data = { {70, nation}, {30, "other"} }
		table.insert(p, players.generate_player(settings))
	end
	--
	local at = { {1, 4}, {-1, 1}, {-2, 1}, {-6, -2} }
	local random_under21 = love.math.random(1,#at)
	for i=1, #at do
		local rating = att + love.math.random(at[i][1], at[i][2])
		age = i==random_under21 and love.math.random(17,20) or nil
		local settings = { rating = rating, position = "at", age = age}
		settings.nationality_data = { {70, nation}, {30, "other"} }
		table.insert(p, players.generate_player(settings))
	end
	--
	players.sort_by_rating(p)
	--
	for i = 1, #p do
		local plyr = p[i]
		g.console:log(plyr.first_name .. " " .. plyr.last_name .. " : " .. plyr.age .. " - Wage: " .. plyr.contract_wage .. " - Value " .. plyr.value)
	end
	--
	return p
end

function players.get_position_players(pos, plyrs)
	local l = {}
	for i=1, #plyrs do if plyrs[i].position==pos then table.insert(l,plyrs[i]) end end
	table.sort(l, function(a,b) return a.rating > b.rating end)
	return l
end

function players.get_ratings(plyrs)
	local gks = players.get_position_players("gk", plyrs)
	local dfs = players.get_position_players("df", plyrs)
	local mfs = players.get_position_players("mf", plyrs)
	local ats = players.get_position_players("at", plyrs)
	players.sort_by_rating(gks); players.sort_by_rating(dfs); players.sort_by_rating(mfs); players.sort_by_rating(ats)
	--
	local def = gks[1].rating * .2 + dfs[1].rating * .2 + dfs[2].rating * .2 + dfs[3].rating * .2 + dfs[4].rating * .2
	local mid = mfs[1].rating * .25 + mfs[2].rating * .25 + mfs[3].rating * .25 + mfs[4].rating * .25
	local att = ats[1].rating * .5 + ats[2].rating * .5
	return def, mid, att
end

function players.get_rating_color(rating)
	if rating >= 96 then return g.skin.rating_colors.a_plus
	elseif rating >= 93 then return g.skin.rating_colors.a
	elseif rating >= 90 then return g.skin.rating_colors.a_minus
	elseif rating >= 86 then return g.skin.rating_colors.b_plus
	elseif rating >= 83 then return g.skin.rating_colors.b
	elseif rating >= 80 then return g.skin.rating_colors.b_minus
	elseif rating >= 76 then return g.skin.rating_colors.c_plus
	elseif rating >= 73 then return g.skin.rating_colors.c
	elseif rating >= 70 then return g.skin.rating_colors.c_minus
	elseif rating >= 66 then return g.skin.rating_colors.d_plus
	elseif rating >= 63 then return g.skin.rating_colors.d
	elseif rating >= 60 then return g.skin.rating_colors.d_minus
	else return g.skin.rating_colors.f end
end

function players.sort_by_rating(players)
	table.sort(players, function(a,b) return a.rating > b.rating end)
end

function players.generate_nationality(data)
	local rand = love.math.random(1, 100)
	local count = 0
	for i=1, #data do
		local val, nat = data[i][1], data[i][2]
		count = count + val
		if rand <= count then
			if nat=="other" then
				return g.database.nation_list[love.math.random(1,#g.database.nation_list)].code
			else
				return nat
			end
		end
	end
end

function players.generate_name(nationality) --5% chance of a random nationality name being produced
	local nat1, nat2 = nationality, nationality
	local rand = love.math.random(1, 100)
	if rand < 8 then -- Random last nationality
		nat2 = g.database.get_random_nation().code
	elseif rand < 12 then
		nat1 = g.database.get_random_nation().code
		nat2 = nat1
	end
	local first = g.names[nat1] and g.names[nat1].first_names[love.math.random(1, #g.names[nat1].first_names)] or "<FIRST>"
	local last = g.names[nat2] and g.names[nat2].surnames[love.math.random(1, #g.names[nat2].surnames)] or "<LAST>"
	return first, last
end

local function round_to_nearest_n(value, unit)
	return math.floor(value / unit + .5) * unit
end

local value_list = {
	{ 5, 0 }, { 10, 50 }, { 15, 150 }, { 20, 350 }, { 25, 750 },
	{ 30, 1500 }, { 35, 3000 }, { 40, 5000 }, { 45, 8000 },
	{ 50, 16000 }, { 55, 30000 }, { 60, 120000 }, { 65, 350000 },
	{ 70, 1100000 }, { 75, 4000000 }, { 80, 10000000 },
	{ 85, 24000000 }, { 90, 48000000 }, { 95, 80000000 },
	{ 100, 115000000 }
}
function players.generate_value(player)
	local age, rating = player.age, player.rating
	local age_bonus = age < 22 and 1 or age > 30 and (30-age) - 1 or 0
	-- peak_age_diff will be between 0 and roughly 11
	local potential_diff = player.potential - player.rating
	if age >= 27 then potential_diff = -1 end -- If over 27, we probably will never hit our potential_diff
	rating = rating + age_bonus + (potential_diff * .1)
	--
	for i = 1, #value_list do
		local data = value_list[i]
		if data[1] >= rating then
			local max_value = data[2]
			local min_value = value_list[i-1][2]
			local diff = rating - value_list[i-1][1]
			local value = min_value + (max_value - min_value) * (diff / 5)
			local len_value = #tostring(value)
			if len_value < 3 then len_value = 3 end
			local round_unit = 10 ^ (len_value - 2)
			local rounded = round_to_nearest_n(value, round_unit)
			return rounded -- No rand_bonus, calculate that yourself!
		end
	end
end

local wage_list = { -- First number is rating, second is wage in £ per week.
	{ 5, 1 }, { 10, 5 }, { 15, 10 }, { 20, 15 }, { 25, 20 },
	{ 30, 25 }, { 35, 40 }, { 40, 70 }, { 45, 130 }, { 50, 250 },
	{ 55, 550 }, { 60, 1000 }, { 65, 3000 }, { 70, 7000 },
	{ 75, 22000 }, { 80, 60000 }, { 85, 110000 }, { 90, 170000 },
	{ 95, 240000 }, { 100, 350000 }
}
function players.generate_wage(age, rating)
	--
	local eff_rating = rating
	if age < 24 then eff_rating = eff_rating + age - 24 end
	eff_rating = eff_rating + love.math.random(-1, 1)
	for i=1, #wage_list do
		local data = wage_list[i]
		if data[1] >= eff_rating then
			local max_wage = data[2]
			local min_wage = wage_list[i-1][2]
			local diff = eff_rating - wage_list[i-1][1] -- 74 - 70 = 4
			local wage = min_wage + (max_wage - min_wage) * (diff / 5)
			local len_wage = #tostring(wage)
			if len_wage < 3 then len_wage = 3 end
			local round_unit = 10 ^ (len_wage - 2)
			local rounded = round_to_nearest_n(wage, round_unit)
			local rand_bonus = love.math.random(-2, 2) * round_unit
			return rounded + rand_bonus
		end
	end
end

function players.total_wage_bill(players)
	local c = 0
	for i=1, #players do
		c = c + players[i].contract_wage
	end
	return c
end

return players