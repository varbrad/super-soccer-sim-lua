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
	self:set_team()
end

function club_overview:update(dt)
	self.timer.update(dt)
end

function club_overview:draw()
	self.fixture_list:draw()
end

function club_overview:set_team()
	self.team = g.db_manager.team_dict[g.vars.view.team_id]
	-- Clear any previous tweens on our timer
	self.timer.clear()
	self.fixture_list:set(self.team)
	--
	g.ribbon:reset()
	--
	g.ribbon:set_image("logos/128/"..self.team.id..".png")
	g.ribbon:set_header(self.team.long_name)
	g.ribbon:set_colors(self.team.color1, self.team.color2, self.team.color3)
	--
	local btn_settings = {}
	btn_settings.w = "auto"
	btn_settings.color1 = self.team.color1
	btn_settings.color2 = self.team.color2
	btn_settings.color3 = self.team.color3
	btn_settings.image = g.image.new("logos/128/"..self.team.league.flag..self.team.league.level..".png", {mipmap=true, w=26, h=26})
	btn_settings.underline = true
	btn_settings.on_release = function() g.state.swap(self, g.states.league_overview, self.team.league_id) end
	g.ribbon:set_infobox(g.db_manager.format_position(self.team.season.stats.pos) .. " in " .. self.team.league.long_name, btn_settings)

	-- Start positioning and tweens
	g.ribbon:set_positions()
	g.ribbon:start_tween()
end

function club_overview:keypressed(k, ir)
	local id = g.vars.view.team_id
	if k=="left" then id = id - 1 end
	if k=="right" then id = id + 1 end
	if k=="up" or k=="down" then
		local diff = k=="up" and -1 or 1
		local t_pos = self.team.season.stats.pos
		for i=1, #self.team.league.teams do
			local t = self.team.league.teams[i]
			if t.season.stats.pos == t_pos + diff then
				g.vars.view.team_id = t.id
				self:set_team()
				return
			end
		end
	end
	if k=="left" or k=="right" then
		local t = g.db_manager.team_dict[id]
		if t then
			g.vars.view.team_id = id
			self:set_team()
		end
	end
end

return club_overview