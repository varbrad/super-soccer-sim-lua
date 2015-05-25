local fixture_group = {}
fixture_group.__index = fixture_group
fixture_group.__type = "Component.FixtureGroup"

function fixture_group.new(x, y, w, h)
	local fg = {}
	setmetatable(fg, fixture_group)
	fg.x, fg.y, fg.w, fg.h = x or 0, y or 0, w or 10, h or 10
	fg.panel = g.ui.panel.new(fg.x, fg.y, fg.w, fg.h)
	fg.panel:set_colors(g.skin.components.color1, g.skin.components.color3)
	fg:set()
	return fg
end

function fixture_group:set(league, week)
	self.bars, self.buttons = {}, {}
	--
	if league==nil or week==nil then return end
	local fixtures = g.database.get_league_fixtures_for_week(league, week)
	local x, y, w, h = self.x + g.skin.margin, self.y + g.skin.margin, self.w - g.skin.margin * 2, g.skin.bars.h
	if fixtures==nil or #fixtures==0 then
		local h = self.h - g.skin.margin * 2
		local label = { text = "No Games To Show", font = g.skin.bars.font[1], color = league.color1 }
		label.w, label.h = g.font.width(label.text, label.font), g.font.height(label.font)
		label.x = math.floor(w/2 - label.w/2 + .5)
		label.y = math.floor(h/2 - label.h/2 + .5)
		local no_fixtures = { x = x, y = y, w = w, h = h, alpha = 0 }
		no_fixtures.labels = { label }
		table.insert(self.bars, no_fixtures)
		return
	end
	local middle = math.floor(w/2 + .5)
	local is_results = false
	for i = 1, #fixtures do
		local f = fixtures[i]
		if not is_results and f.finished then is_results = true end
		local bar = { x = x, y = y + i * g.skin.bars.h, w = w, h = h, alpha = g.skin.bars.alpha }
		bar.color = i%2==0 and g.skin.bars.color1 or g.skin.bars.color3
		bar.label_color = g.skin.bars.color2
		--
		local home = g.database.get_team(f.home)
		local away = g.database.get_team(f.away)
		--
		local score_text = f.finished and (f.home_score.." - "..f.away_score) or "v"
		local score = { text = score_text, x = middle - g.skin.bars.column_size/2 - g.skin.margin, y = g.skin.bars.ty, w = g.skin.bars.column_size + g.skin.margin*2, align = "center", color = g.skin.bars.color2, font = g.skin.bars.font[3] }
		local score_rect = { x = score.x, y = g.skin.margin, w = score.w, h = g.skin.bars.h - g.skin.margin * 2, color = bar.color, alpha = g.skin.bars.alpha, rounded = g.skin.rounded }
		--
		local home_logo = g.image.new("logos/"..home.id..".png", { w = g.skin.bars.img_size, h = g.skin.bars.img_size, x = score.x - g.skin.bars.img_size - g.skin.img_margin, y = g.skin.bars.iy, team = home })
		local away_logo = g.image.new("logos/"..away.id..".png", { w = g.skin.bars.img_size, h = g.skin.bars.img_size, x = score.x + score.w + g.skin.img_margin, y = g.skin.bars.iy, team = away })
		--
		local home_team = { text = home.short_name, y = g.skin.bars.ty, font = g.skin.bars.font[2], alpha = f.result_code~="2" and 255 or g.skin.bars.alpha, color = home.id==g.database.vars.player.team_id and g.skin.colors[3] or nil }
		home_team.w, home_team.h = g.font.width(home_team.text, home_team.font), g.font.height(home_team.font)
		home_team.x = home_logo.x - g.skin.img_margin - g.font.width(home_team.text, home_team.font)
		local away_team = { text = away.short_name, y = g.skin.bars.ty, font = g.skin.bars.font[2], alpha = f.result_code~="1" and 255 or g.skin.bars.alpha, color = away.id==g.database.vars.player.team_id and g.skin.colors[3] or nil }
		away_team.w, away_team.h = g.font.width(away_team.text, away_team.font), g.font.height(away_team.font)
		away_team.x = away_logo.x + away_logo.w + g.skin.img_margin
		--
		local btn1 = g.ui.button.new("", { x = bar.x + home_team.x, y = bar.y + home_team.y, w = home_team.w, h = home_team.h })
		local btn2 = g.ui.button.new("", { x = bar.x + away_team.x, y = bar.y + away_team.y, w = away_team.w, h = away_team.h })
		btn1.on_enter, btn1.on_exit = function(b) home_team.underline = true end, function(b) home_team.underline = false end
		btn2.on_enter, btn2.on_exit = function(b) away_team.underline = true end, function(b) away_team.underline = false end
		btn1.on_release = function(b) g.database.set_view_team(home.id); g.state.switch(g.states.club_overview) end
		btn2.on_release = function(b) g.database.set_view_team(away.id); g.state.switch(g.states.club_overview) end
		btn1.visible, btn2.visible = false, false
		table.insert(self.buttons, btn1)
		table.insert(self.buttons, btn2)
		--
		local home_pos = { text = g.engine.format_position(home.data.season.stats.pos), x = g.skin.margin, y = g.skin.bars.ty, w = g.skin.bars.column_size, align = "center", font = g.skin.bars.font[2] }
		local away_pos = { text = g.engine.format_position(away.data.season.stats.pos), x = bar.w - g.skin.margin - g.skin.bars.column_size, y = g.skin.bars.ty, w = g.skin.bars.column_size, align = "center", font = g.skin.bars.font[2] }
		--
		bar.labels = { score, home_team, away_team, home_pos, away_pos }
		bar.rects = { score_rect }
		bar.images = { home_logo, away_logo }
		--
		table.insert(self.bars, bar)
	end
	local header = { x = x, y = y, w = w, h = h, color = league.color2, alpha = g.skin.bars.alpha }
	local txt = league.short_name .. " - Week " .. week .. (is_results and " Results" or " Fixtures")
	header.labels = { { text = txt, x = 0, y = g.skin.bars.ty, w = header.w, align = "center", font = g.skin.bars.font[1], color = league.color1 } }
	table.insert(self.bars, header)
end

function fixture_group:update(dt)
	for i=1, #self.buttons do self.buttons[i]:update(dt) end
end

function fixture_group:draw(t_alpha)
	t_alpha = t_alpha or 1
	self.panel:draw()
	love.graphics.setScissor(self.panel.x+g.skin.margin, self.panel.y+g.skin.margin, self.panel.w-g.skin.margin*2, self.panel.h-g.skin.margin*2)
	for i=1, #self.bars do
		local bar = self.bars[i]
		g.components.bar_draw.draw(bar, 0, 0,  t_alpha)
	end
	love.graphics.setScissor()
end

function fixture_group:mousepressed(x, y, b)
	for i=1, #self.buttons do self.buttons[i]:mousepressed(x, y, b) end
end

function fixture_group:mousereleased(x, y, b)
	for i=1, #self.buttons do self.buttons[i]:mousereleased(x, y, b) end
end

setmetatable(fixture_group, {_call = function(_, ...) return fixture_group.new(...) end})

return fixture_group