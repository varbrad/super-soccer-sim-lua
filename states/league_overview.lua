local league_overview = {}
league_overview.name = "League Overview"

function league_overview:init()
	self.__z = 1
	--
	g.console:log("league_overview:init")
end

function league_overview:added()
	local split_h = g.skin.screen.h/2 - g.skin.margin *1.5
	local split_w = g.skin.screen.w/2 - g.skin.margin *1.5
	local height = g.skin.screen.h - g.skin.margin * 2
	self.league_table = g.components.league_table.new(g.skin.screen.x + g.skin.margin, g.skin.screen.y + g.skin.margin, split_w, height, nil, "default")
	self.upcoming = g.components.fixture_group.new(g.skin.screen.x + g.skin.margin * 2 + self.league_table.w, g.skin.screen.y + g.skin.margin, split_w, split_h) 
	self.results = g.components.fixture_group.new(self.upcoming.x, self.upcoming.y + self.upcoming.h + g.skin.margin, self.upcoming.w, self.upcoming.h)
	self:set_league()
end

function league_overview:update(dt)
	
end

function league_overview:draw()
	self.league_table:draw()
	self.upcoming:draw()
	self.results:draw()
end

function league_overview:set_league()
	self.league = g.db_manager.league_dict[g.vars.view.league_id]
	self.league_table:set_league(self.league)
	self.upcoming:set(self.league, g.vars.week, false)
	self.results:set(self.league, g.vars.week-1, true)
	--
	g.ribbon:reset()
	--
	g.ribbon:set_image("logos/128/"..self.league.flag..self.league.level..".png")
	g.ribbon:set_header(self.league.long_name)
	g.ribbon:set_colors(self.league.color1, self.league.color2, self.league.color3)
	--
	local infobox = {}
	infobox.w = "auto"
	infobox.enabled = false
	infobox.image = g.image.new("flags/"..self.league.flag..".png")
	infobox.color1, infobox.color2, infobox.color3 = self.league.color1, self.league.color2, self.league.color3
	if infobox.image==nil then infobox.visible = false end
	g.ribbon:set_infobox("", infobox)
	--
	g.ribbon:set_positions()
	g.ribbon:start_tween()
end

function league_overview:keypressed(k, ir)
	local old_id = g.vars.view.league_id
	local id = old_id
	if k=="left" then id = id - 1 end
	if k=="right" then id = id + 1 end
	if k=="left" or k=="right" then
		local l = g.db_manager.league_dict[id]
		if l then
			g.vars.view.league_id = id
			self:set_league()
		end
	end
end

return league_overview