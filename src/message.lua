local message = {}

message.urgent = false

function message.new(title, from, urgent, content)
	local msg = {}
	msg.title = title
	msg.from = from
	msg.urgent = urgent
	msg.content = content
	msg.read = false
	--
	table.insert(g.database.vars.inbox, 1, msg)
	if urgent then message.urgent = true end
end

function message.delete(msg)
	if msg.urgent then return end
	for i = 1, #g.database.vars.inbox do
		if msg == g.database.vars.inbox[i] then
			return table.remove(g.database.vars.inbox, i)
		end
	end
end

function message.get_index(msg)
	for i = 1, #g.database.vars.inbox do if g.database.vars.inbox[i] == msg then return i end end
end

function message.unread() local c = 0; for i = 1, #g.database.vars.inbox do if g.database.vars.inbox[i].read==false then c = c + 1 end end; return c end

function message.welcome()
	local team = g.database.get_player_team()
	local title = "Welcome to " .. team.long_name .. "!"
	local from = "The Board"
	local content = [[The Board would like to welcome you to ]] .. team.long_name .. [[, and wish you the best of luck and hope that we can enjoy success in the coming years!

	We will be competing in the ]]..team.refs.league.long_name..[[ for the ]]..g.database.vars.year.."/"..(g.database.vars.year+1)..[[ season.

	The Board will message you frequently throughout the season concerning various topics, such as team performance, financial information and any concerns we may have.

	We will message you shortly to outline our targets for the coming season, as well as other information you should be aware of.

	Regards,
	]] .. team.long_name .. [[ Board]]
	message.new(title, from, false, content)
end

function message.season_targets()
	local team = g.database.get_player_team()
	local league = g.database.get_player_league()
	-- Sort the league.refs.teams by their overall rating (sum)
	table.sort(league.refs.teams, function(a, b) return a.def + a.mid + a.att > b.def + b.mid + b.att end)
	local expected_pos = 0
	for i = 1, #league.refs.teams do if league.refs.teams[i]==team then expected_pos = i; break end end
	--
	local title = g.database.vars.year .. "/" .. (g.database.vars.year+1) .. " Season Targets"
	local from = "The Board"
	local content = [[For the forthcoming season, The Board have set the following initial targets;

	• The Board expects the club to finish ]] .. g.engine.format_position(expected_pos) .. [[ in the ]] .. league.long_name .. [[ this season.

	Exceeding the targets will be considered a bonus and may be rewarded at the end of the season.
	You now have the chance to amend these targets, if you wish.
	If you wish to reduce the targets outlined above, this will not only disappoint the board and fans, but also reduce your available budget amongst other possible penalties.
	If you wish to increase the targets outlined above, the board will be happy as will the fans, and may lead to a slight budget increase, but note that failing to reach these higher goals will be considered unacceptable and may lead to further penalties at the end of the season performance review.

	Once these targets have been set, The Board will not allow you to change them again during the season.

	Regards,
	]] .. team.long_name .. [[ Board]]
	message.new(title, from, true, content)
end

return message