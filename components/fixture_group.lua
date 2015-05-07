local fixture_group = {}
fixture_group.__index = fixture_group
fixture_group.__type = "Component.FixtureGroup"

function fixture_group.new(x, y, w, h, league, round)
	local fg = {}
	setmetatable(fg, fixture_group)
	fg.x, fg.y, fg.w, fg.h = x or 0, y or 0, w or 10, h or 10
	fg.panel = g.ui.panel.new(fg.x, fg.y, fg.w, fg.h)
	fg.panel:set_colors(g.skin.components.color1, g.skin.components.color3)
	fg:set(league, round)
	return fg
end

function fixture_group:set(league, round, is_results)
	self.league, self.round = league, round
	self.bars, self.buttons = {}, {}
	if self.league==nil or self.league.season.fixtures[round]==nil then
		local no_fix = {x = self.x + g.skin.margin, y = self.y + g.skin.margin, w = self.w - g.skin.margin * 2, h = g.skin.bars.h, color = g.skin.bars.color1, alpha = g.skin.bars.alpha }
		no_fix.labels = { { text = is_results and "No Results To Show" or "No Fixtures Scheduled", x = 0, y = g.skin.bars.ty, w = no_fix.w, font = g.skin.bars.font[1], align = "center", color = g.skin.bars.color2 }}
		table.insert(self.bars, no_fix)
		return
	end
	local header = {x = self.x + g.skin.margin, y = self.y + g.skin.margin, w = self.w - g.skin.margin * 2, h = g.skin.bars.h, color = self.league.color2, alpha = g.skin.bars.alpha }
	header.labels = { { text = self.league.short_name .. (is_results and " Results - Week " or " Fixtures - Week ") .. round, x = 0, y = g.skin.bars.ty, w = header.w, font = g.skin.bars.font[1], align = "center", color = self.league.color1 } }
	table.insert(self.bars, header)
	--
	for i=1, #self.league.season.fixtures[round] do
		local fixture = self.league.season.fixtures[round][i]
		local bar = {x = self.x + g.skin.margin, y = self.y + g.skin.margin + i * g.skin.bars.h, w = self.w - g.skin.margin * 2, h = g.skin.bars.h, alpha = g.skin.bars.alpha }
		bar.color = i%2==0 and g.skin.bars.color1 or g.skin.bars.color3
		local c1, c2 = fixture.home.id==g.vars.player.team_id and g.skin.colors[3] or g.skin.bars.color2, fixture.away.id==g.vars.player.team_id and g.skin.colors[3] or g.skin.bars.color2
		bar.labels = {
			{ text = fixture.home.short_name, w = g.font.width(fixture.home.short_name, g.skin.bars.font[2]), h = g.font.height(g.skin.bars.font[2]), x = math.floor(bar.w / 2 - 30 - g.skin.margin * 2 - g.skin.bars.img_size - g.font.width(fixture.home.short_name, g.skin.bars.font[2]) + .5), y = g.skin.bars.ty, font = g.skin.bars.font[2], color = c1 };
			{ text = fixture.away.short_name, w = g.font.width(fixture.away.short_name, g.skin.bars.font[2]), h = g.font.height(g.skin.bars.font[2]), x = math.floor(bar.w / 2 + 30 + g.skin.margin * 2 + g.skin.bars.img_size + .5), y = g.skin.bars.ty, font = g.skin.bars.font[2], color = c2 };
			{ text = g.db_manager.format_position(fixture.home.season.stats.pos), x = g.skin.margin, y = g.skin.bars.ty, w = 50, align = "center", font = g.skin.bars.font[2], color = g.skin.bars.color2 };
			{ text = g.db_manager.format_position(fixture.away.season.stats.pos), x = bar.w - g.skin.margin - 50, y = g.skin.bars.ty, w = 50, align = "center", font = g.skin.bars.font[2], color = g.skin.bars.color2 };
			{ text = fixture.finished and fixture.home_score.." - "..fixture.away_score or "v", x = math.floor(bar.w / 2 - 30), y = g.skin.bars.ty, w = 60, align = "center", font = g.skin.bars.font[3], color = g.skin.bars.color2 };
		}
		bar.images = {
			g.image.new("logos/128/"..fixture.home.id..".png", {mipmap = true, w = g.skin.bars.img_size, h = g.skin.bars.img_size, x = math.floor(bar.w / 2 - 30 - g.skin.margin - g.skin.bars.img_size + .5), y = g.skin.bars.iy });
			g.image.new("logos/128/"..fixture.away.id..".png", {mipmap = true, w = g.skin.bars.img_size, h = g.skin.bars.img_size, x = math.floor(bar.w / 2 + 30 + g.skin.margin + .5), y = g.skin.bars.iy });
		}
		bar.rects = {
			{ x = math.floor(bar.w / 2 - 30), y = g.skin.margin, w = 60, h = bar.h - g.skin.margin * 2, color = g.skin.bars.color4, alpha = g.skin.bars.alpha, rounded = 5 }
		}
		local btn1 = g.ui.button.new("", { w = bar.labels[1].w, h = bar.labels[1].h, x = bar.x + bar.labels[1].x, y = bar.y + bar.labels[1].y } )
		local btn2 = g.ui.button.new("", { w = bar.labels[2].w, h = bar.labels[2].h, x = bar.x + bar.labels[2].x, y = bar.y + bar.labels[2].y } )
		btn1.on_enter = function(btn) bar.labels[1].underline = true end
		btn1.on_exit = function(btn) bar.labels[1].underline = false end
		btn1.on_release = function(btn) g.vars.view.team_id = fixture.home.id; g.state.switch(g.states.club_overview) end
		btn2.on_enter = function(btn) bar.labels[2].underline = true end
		btn2.on_exit = function(btn) bar.labels[2].underline = false end
		btn2.on_release = function(btn) g.vars.view.team_id = fixture.away.id; g.state.switch(g.states.club_overview) end
		table.insert(self.buttons, btn1); table.insert(self.buttons, btn2)
		table.insert(self.bars, bar)
	end
end

function fixture_group:update(dt)
	for i=1, #self.buttons do self.buttons[i]:update(dt) end
end

function fixture_group:draw()
	self.panel:draw()
	love.graphics.setScissor(self.panel.x+g.skin.margin, self.panel.y+g.skin.margin, self.panel.w-g.skin.margin*2, self.panel.h-g.skin.margin*2)
	for i=1, #self.bars do
		local bar = self.bars[i]
		g.components.bar_draw.draw(bar)
	end
	love.graphics.setScissor()
end

function fixture_group:mousepressed(x, y, b)
	for i=1, #self.buttons do self.buttons[i]:mousepressed(dt) end
end

function fixture_group:mousereleased(x, y, b)
	for i=1, #self.buttons do self.buttons[i]:mousereleased(dt) end
end

setmetatable(fixture_group, {_call = function(_, ...) return fixture_group.new(...) end})

return fixture_group