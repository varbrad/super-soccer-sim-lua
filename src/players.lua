local players = {}

function players.generate_player(settings)
	settings = settings or {}
	local p = {}
	p.first_name, p.last_name = players.generate_name()
	p.age = settings.age or love.math.random(18, 33)
	p.rating = settings.rating or love.math.random(60, 70)
	p.potential = settings.potential or love.math.random(65, 75)
	if p.rating > p.potential then p.potential = p.rating + 10 end
	p.nationality = settings.nationality or "en"
	p.form = love.math.random(-5, 5)
	p.position = settings.position or "gk"
	p.position_value = p.position=="gk" and 1 or p.position=="df" and 2 or p.position=="mf" and 3 or 4
	return p
end

function players.generate_team(def, mid, att)
	-- Generate a total of 21 players with stats roughly equal (give or take +-2 or so) to the incoming stats of a team
	-- GK = 3		-- DF = 7		-- MF = 7		-- AT = 4
	local p = {}
	local gk = { {0, 3}, {-2, 1}, {-3, -1} }
	for i = 1, 3 do -- 1st = 0, 3 (avg 1.5), 2nd = -2, 1 (avg -.5), 3rd = -3, -1 (avg -2), total averages = +1.5, -.5, -2 = total -1 (GK is special, should be -1)
		local rating = def + love.math.random(gk[i][1], gk[i][2])
		local settings = { rating = rating, position = "gk" }
		table.insert(p, players.generate_player(settings))
	end
	-- 1st = 2, 5 (avg 3.5), 2nd = 1, 3 (avg 2), 3rd = -1, 1 (avg 0), 4th = -3, 1 (avg -1), 5th = -5, -2 (avg -3.5), 6th = -5, -2 (avg -3.5), 7th = -6, -2 (avg -4)
	-- Averages = 3.5, 2.0, 0.0, -1.0, -3.5, -3.5, -4
	local df = { {3, 5}, {0, 2}, {-2, 1}, {-3, 1}, {-5, -2}, {-5, -2}, {-6, -2} }
	for i = 1, #df do
		local rating = def + love.math.random(df[i][1], df[i][2])
		local age = (i==6 or i==7) and love.math.random(17,20) or nil -- Last 2 players will auto be under 21
		local settings = { rating = rating, position = "df", age = age}
		table.insert(p, players.generate_player(settings))
	end
	--
	for i=1, #df do
		local rating = mid + love.math.random(df[i][1], df[i][2])
		local age = (i==5 or i==7) and love.math.random(17,20) or nil
		local settings = { rating = rating, position = "mf", age = age}
		table.insert(p, players.generate_player(settings))
	end
	--
	local at = { {1, 4}, {-1, 1}, {-2, 1}, {-5, -1} }
	local random_under21 = love.math.random(1,#at)
	for i=1, #at do
		local rating = att + love.math.random(at[i][1], at[i][2])
		age = i==random_under21 and love.math.random(17,20) or nil
		local settings = { rating = rating, position = "at", age = age}
		table.insert(p, players.generate_player(settings))
	end
	--
	players.sort_by_rating(p)
	return p
end

function players.get_position_players(pos, plyrs)
	local l = {}
	for i=1, #plyrs do if plyrs[i].position==pos then table.insert(l,plyrs[i]) end end
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

function players.generate_name()
	local firsts = {
		"Oliver", "Jack", "Charlie", "Harry", "Oscar", "Thomas", "Thomas", "Ethan", "Noah", "James", "William", "Joshua", "George", "Leo", "Max", "Henry", "Alfie", "Lucas", "Daniel",
		"Dylan", "Finley", "Alexander", "Freddie", "Isaac", "Aaron", "Samuel", "Cameron", "Joseph", "Tommy", "Hugo", "Archie", "Muhammad", "Brody", "Evan", "Benjamin", "Evan", "Gabriel",
		"Lewis", "Logan", "Dexter", "Austin", "Matthew", "Matty", "Sebastian", "Nicholas", "Seth", "Jake", "Edward", "Harley", "Owen", "Zachary", "Aidan", "Stanley", "Nathaniel", "Luke", "Mason",
		"Rowan", "Rory", "Riley", "Ryan", "Teddy", "Jason", "Elliot", "Toby", "Hayden", "Tristan", "Reuben", "Adam", "Theo", "Josh", "Jasper", "Theo", "Connor", "Bobby", "Frankie", "Tom", "Jayden",
		"Nathan", "Liam", "Paddy", "Patrick", "Brad", "Nate", "Jordan", "Steve", "Paul", "Harrison", "Sam", "Michael", "Ollie", "Zac", "Arthur", "Luca", "Ben", "Finn", "Alex", "Elijah", "Tyler",
		"Jamie", "Blake", "Reece", "Rhys", "David", "Callum", "Caleb", "Jackson", "Felix", "Harvey", "Jude", "Jenson", "Alfred"
	} -- some basic first names
	local lasts = { "Smith", "Wood", "Green", "Davis", "Stevens", "Stephenson", "Jeffries", "Kelsey", "Tomlin", "Woodley", "Woodridge", "Winstanley", "Christiansen", "Fotham", "Kelton", "Morisson", 
					"Vicars", "Bethell", "Cole", "Davids", "Russell", "Harriot", "Harrington", "Bright", "Jones", "James", "Shaynes", "Howell", "Cowell", "Bynes", "Williams", "Williamson", "Kurt",
					"Tomlinson", "Nicholls", "Nicholson", "Wheeler", "Adamson", "Adams", "Addams", "Christian", "Paul", "Lovell"
	} -- lol
	return firsts[love.math.random(1,#firsts)] , lasts[love.math.random(1,#lasts)]
end

return players