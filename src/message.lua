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
	local content = [[The Board would like to welcome you to ]] .. team.long_name .. [[. We wish you the best of luck and hope that we can enjoy success in the coming years!

	We will be competing in the ]]..team.refs.league.long_name..[[ for the ]]..g.database.vars.year.."/"..(g.database.vars.year+1)..[[ season.

	The first task you should begin thinking about is the matter of hiring a new manager!

	The Board will message you frequently throughout the season concerning various topics, such as team performance, financial information, fan feedback, and any thoughts or concerns we may have.

	We will message you shortly to outline our targets for the coming season.

	Regards,
	]] .. team.long_name .. [[ Board]]
	message.new(title, from, false, content)
end

function message.initial_budget()
	local team = g.database.get_player_team()
	local title = "Initial Club Budget"
	local from = "The Board"
	local content = [[Throughout the season, we will message you regarding the financial status of the club. This message is to outline our expectations with regard to finance, and hopefully answer any questions you had.

	The Board have provided an operational budget of ]] .. g.format_currency(g.database.vars.finance.cash) .. [[ for the upcoming season.

	Every week, this balance will be updated to reflect various incoming revenue and outgoing expenses.
	Revenue includes things such as sponsorship income, ticket sales, merchandise sales, and competition prize money.
	Expenses includes things such as player wages, staff wages, facilities upkeep, and general operational costs.

	The Board are flexible with regards to the way you wish to manage the budget provided, as long as the club meets its seasonal targets and does not fall into debt.

	In the event the club does fall into debt (The budget becomes negative), the board will provide a cash injection to keep the club operating. We will be entirely disappointed if this does occur, and will likely review your position at the club. We would like to stress that the cash injection should be seen as a last-resort measure, and you should attempt any course of action necessary to prevent this from occuring.

	We will contact you twice throughout the season regarding our financial report of the club. The first of these reports will occur halfway through the season, with the second coming just before the end-of-season performance review. These will summarise our thoughts on the financial state of the club.

	Regards,
	]] .. team.long_name .. [[ Board]]
	message.new(title, from, false, content)
end

function message.season_targets()
	local team = g.database.get_player_team()
	local league = g.database.get_player_league()
	local team_count = #league.data.teams
	local expected_pos = g.database.vars.league_position_target
	--
	local title = g.database.vars.year .. "/" .. (g.database.vars.year+1) .. " Season Targets"
	local from = "The Board"
	--
	local str = "to finish " .. g.engine.format_position(expected_pos) .. " in"
	if expected_pos + league.relegated > team_count then
		-- Expected relegation
		str = "to fight relegation from"
	elseif expected_pos==1 then -- Win league
		str = "to win"
	end
	--
	local content = [[For the forthcoming season, The Board have set the following initial targets;

	• The Board expects the club ]] .. str .. [[ the ]] .. league.long_name .. [[ this season.

	Exceeding the targets will be considered a bonus and may be rewarded at the end of the season.
	You now have the chance to amend these targets, if you wish.
	If you wish to reduce the targets outlined above, this will not only disappoint the board and fans, but also reduce your available budget amongst other possible penalties.
	If you wish to increase the targets outlined above, the board will be happy as will the fans, and may lead to a slight budget increase, but note that failing to reach these higher goals will be considered unacceptable and may lead to further penalties at the end-of-season performance review.

	Once these targets have been set, The Board will not allow you to change them again during the season.

	Regards,
	]] .. team.long_name .. [[ Board]]
	message.new(title, from, true, content)
end

return message