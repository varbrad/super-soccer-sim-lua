local ach = {}

local achievements = {
	{ name = "win_a_game", title = "Win A Game", desc = "Win any competitive game." },
	{ name = "reach_week_52", title = "Reach Week 52", desc = "Reach week 52!", func = function() if g.database.vars.week == 52 then return true else return false end end },
}

function ach.list() -- Gets a list of all achievements (you need to check)
	return achievements
end

function ach.check()
	-- This should be run every week after the weeks games are finished!
	-- Will check for standard achievements that arent unlocked at specific times!
	for i = 1, #achievements do
		local a = achievements[i]
		if a.func and a.func()==true then
			ach.unlock(a.name)
		end
	end
end

function ach.is_unlocked(achievement_name)
	if g.database.vars.achievements[achievement_name] then return true else return false end
end

function ach.unlock(achievement_name, data)
	if ach.is_unlocked(achievement_name) then return end
	--
	g.database.vars.achievements[achievement_name] = { data = data }
	--
	-- Show notification
	--
	for i = 1, #achievements do
		if achievement_name == achievements[i].name then
			g.notification:new("Achievement Unlocked!\n"..achievements[i].title, "star")
			break
		end
	end
end

return ach