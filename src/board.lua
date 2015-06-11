local board = {}

function board.league_position_target()
	local team = g.database.get_player_team()
	local league = g.database.get_player_league()
	-- Sort the league.refs.teams by their overall rating (sum)
	table.sort(league.refs.teams, function(a, b) return a.def + a.mid + a.att > b.def + b.mid + b.att end)
	local expected_pos = 0
	for i = 1, #league.refs.teams do if league.refs.teams[i]==team then expected_pos = i; break end end
	expected_pos = expected_pos + love.math.random(-1, 1) - 1
	if expected_pos < 1 then expected_pos = 1 end
	return expected_pos
end

return board