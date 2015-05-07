local club_overview = {}
club_overview.name = "Club Overview"

function club_overview:init()
	self.__z = 1
	self.timer = g.timer.new()
	--
	g.console:log("club_overview:init")
end

function club_overview:added()
	local height = g.skin.screen.h - g.skin.margin * 2
	local split_w = math.floor(g.width/3 - g.skin.margin * 1.5 + .5)
	self.fixture_list = g.components.fixture_list.new(g.skin.screen.x + g.skin.margin, g.skin.screen.y + g.skin.margin, split_w, height)
	self.league_table = g.components.league_table.new(self.fixture_list.x + self.fixture_list.w + g.skin.margin, self.fixture_list.y, split_w, height, nil, "small")
	self:set_team()
end

function club_overview:update(dt)
	self.timer.update(dt)
	self.league_table:update(dt)
end

function club_overview:draw()
	self.fixture_list:draw()
	self.league_table:draw()
end

function club_overview:set_team()
	self.team = g.db_manager.team_dict[g.vars.view.team_id]
	-- Clear any previous tweens on our timer
	self.timer.clear()
	self.fixture_list:set(self.team)
	self.league_table:set(self.team.league)
	self.league_table:highlight_team(self.team)
	--
	g.ribbon:set_team(self.team)
end

function club_overview:keypressed(k, ir)
	if g.ribbon.searchbox.focus then return end
	if k=="l" then
		g.vars.player.team_id = g.vars.view.team_id
		g.state.refresh_all()
	end
end

function club_overview:mousepressed(x, y, b)
	self.league_table:mousepressed(x, y, b)
end

function club_overview:mousereleased(x, y, b)
	self.league_table:mousereleased(x, y, b)
end

return club_overview