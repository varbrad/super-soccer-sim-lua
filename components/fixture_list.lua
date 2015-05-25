local fixture_list = {}
fixture_list.__index = fixture_list
fixture_list.__type = "Component.FixtureList"

function fixture_list.new(x, y, w, h, team)
	local fl = {}
	setmetatable(fl, fixture_list)
	fl.x, fl.y, fl.w, fl.h = x or 0, y or 0, w or 10, h or 10
	fl.panel = g.ui.panel.new(fl.x, fl.y, fl.w, fl.h)
	fl.panel:set_colors(g.skin.components.color1, g.skin.components.color3)
	fl:set(team)
	return fl
end

function fixture_list:set(team)
	self.team = team
	self.bars = {}
	self.buttons = {}
	local col1, col2 = self.team and self.team.color1 or g.skin.small_bars.color1, self.team and self.team.color2 or g.skin.small_bars.color2
	local ty = math.floor(g.skin.small_bars.h/2 - g.font.height(g.skin.small_bars.font[1])/2 + .5)
	local iy = math.floor(g.skin.small_bars.h/2 - g.skin.small_bars.img_size/2 + .5)
	local header = { x = self.x + g.skin.margin; y = self.y + g.skin.margin; w = self.w - g.skin.margin * 2; h = g.skin.small_bars.h; color = col1; alpha = g.skin.small_bars.alpha; }
	header.labels = {}
	header.labels[1] = { text = "Game Week", x = g.skin.margin, y = ty, font = g.skin.small_bars.font[1], color = col2, w = 90, align = "right" }
	header.labels[2] = { text = "Opponent", x = header.labels[1].x + header.labels[1].w + g.skin.margin*3 + 60, y = ty, font = g.skin.small_bars.font[1], color = col2 }
	header.labels[3] = { text = "Pos.", x = self.w - g.skin.margin - 60, y = ty, font = g.skin.small_bars.font[1], color = col2, align = "center", w = 60}
	header.labels[4] = { text = "Result", x = header.labels[3].x - g.skin.margin - 60, y = ty, font = g.skin.small_bars.font[1], color = col2, align = "center", w = 60}
	self.bars[1] = header
	if team==nil then return end
	local fixtures = g.engine.get_team_league_fixtures(self.team.refs.league, self.team)
	for i = 1, #fixtures do
		local fixture = fixtures[i]
		local bar = { x = self.x + g.skin.margin; y = self.y + g.skin.margin + i*g.skin.small_bars.h; w = self.w - g.skin.margin*2; h = g.skin.small_bars.h; alpha = g.skin.small_bars.alpha; }
		bar.color = i%2==0 and g.skin.bars.color1 or g.skin.bars.color3
		bar.labels, bar.images, bar.rects = {}, {}, {}
		bar.labels[1] = { text = "Week "..i, x = g.skin.margin, y = ty, font = g.skin.small_bars.font[2], color = g.skin.small_bars.color2, w = 90, align="right" }
		local opponent = fixture.home==self.team.id and g.database.get_team(fixture.away) or g.database.get_team(fixture.home)
		local at_home = fixture.home==self.team.id and "H" or "A"
		bar.labels[2] = { text = fixture.type, x = bar.labels[1].x + bar.labels[1].w + g.skin.margin, y = ty, font = g.skin.small_bars.font[2], color = g.skin.small_bars.color2, w = 30, align="center" }
		bar.labels[3] = { text = at_home, x = bar.labels[2].x + bar.labels[2].w + g.skin.margin, y = ty, font = g.skin.small_bars.font[3], color = at_home=="H" and self.team.color2 or g.skin.small_bars.color2, w = 30, align = "center" }
		if at_home=="H" then bar.rects[1] = { x = bar.labels[3].x, y = 0, w = bar.labels[3].w, h = bar.h, color = self.team.color1, alpha = g.skin.small_bars.alpha } end
		bar.images[1] = g.image.new("logos/"..opponent.id..".png", {mipmap=true, x = bar.labels[3].x + bar.labels[3].w + g.skin.margin, y = iy, w = g.skin.small_bars.img_size, h = g.skin.small_bars.img_size, team = opponent})
		bar.labels[4] = { text = opponent.short_name, x = bar.images[1].x + bar.images[1].w + g.skin.margin, y = ty, font = g.skin.small_bars.font[2], color = opponent.id==g.database.vars.player.team_id and g.skin.colors[3] or g.skin.small_bars.color2 }
		bar.labels[4].h, bar.labels[4].w = g.font.height(bar.labels[4].font), g.font.width(bar.labels[4].text, bar.labels[4].font)
		local btn = g.ui.button.new("", { w = bar.labels[4].w, h = bar.labels[4].h, x = bar.x + bar.labels[4].x, y = bar.y + bar.labels[4].y } )
		btn.on_enter = function(btn) bar.labels[4].underline = true end
		btn.on_exit = function(btn) bar.labels[4].underline = false end
		btn.on_release = function(btn) g.database.vars.view.team_id = opponent.id; g.state.switch(g.states.club_overview) end
		self.buttons[#self.buttons+1] = btn
		if fixture.finished then
			local team_score = fixture.home==self.team.id and fixture.home_score or fixture.away_score
			local opp_score = fixture.home==self.team.id and fixture.away_score or fixture.home_score
			bar.labels[5] = { text = g.engine.format_position(self.team.data.season.past_pos[i]), x = self.w - g.skin.margin - 60, y = ty, font = g.skin.small_bars.font[2], color = g.skin.small_bars.color2, w = 60, align = "center" }
			bar.labels[6] = { text = team_score.."\t-\t"..opp_score, x = bar.labels[5].x - g.skin.margin - 60, y = ty, font = g.skin.small_bars.font[2], color = g.skin.small_bars.color2, w = 60, align = "center" }
			--
			local image_string, image_color = "misc/draw_icon.png", {255, 165, 5, g.skin.small_bars.alpha}
			if fixture.winner==self.team.id then image_string, image_color = "misc/win_icon.png", {5, 255, 5, g.skin.small_bars.alpha}
			elseif fixture.winner==opponent.id then image_string, image_color = "misc/lose_icon.png", {255, 5, 5, g.skin.small_bars.alpha} end
			bar.images[2] = g.image.new(image_string, {mipmap=true, x = bar.labels[6].x - g.skin.margin - g.skin.small_bars.img_size, y = iy, w = g.skin.small_bars.img_size, h = g.skin.small_bars.img_size, color = image_color })
		end
		self.bars[#self.bars+1] = bar
	end
end

function fixture_list:update(dt)
	for i=1, #self.buttons do self.buttons[i]:update(dt) end
end

function fixture_list:draw(t_alpha)
	t_alpha = t_alpha or 1
	self.panel:draw()
	love.graphics.setScissor(self.x + g.skin.margin, self.y + g.skin.margin, self.w - g.skin.margin * 2, self.h - g.skin.margin * 2)
	for i=1, #self.bars do
		local bar = self.bars[i]
		g.components.bar_draw.draw(bar, 0, 0,  t_alpha)
	end
	love.graphics.setScissor()
end

function fixture_list:mousepressed(x, y, b)
	for i=1, #self.buttons do self.buttons[i]:mousepressed(x, y, b) end
end

function fixture_list:mousereleased(x, y, b)
	for i=1, #self.buttons do self.buttons[i]:mousereleased(x, y, b) end
end

setmetatable(fixture_list, {_call = function(_, ...) return fixture_list.new(...) end})

return fixture_list