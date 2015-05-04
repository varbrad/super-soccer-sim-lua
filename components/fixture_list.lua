local fixture_list = {}
fixture_list.__index = fixture_list
fixture_list.__type = "Component.FixtureGroup"

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
	self.team = team or nil
	self.bars = {}
	local col1, col2 = self.team and self.team.color3 or g.skin.small_bars.color1, self.team and self.team.color2 or g.skin.small_bars.color2
	local ty = math.floor(g.skin.small_bars.h/2 - g.font.height(g.skin.small_bars.font[1])/2 + .5)
	local iy = math.floor(g.skin.small_bars.h/2 - g.skin.small_bars.img_size/2 + .5)
	local header = { x = self.x + g.skin.margin; y = self.y + g.skin.margin; w = self.w - g.skin.margin * 2; h = g.skin.small_bars.h; color = col1; alpha = g.skin.small_bars.alpha; }
	header.labels = {}
	header.labels[1] = { text = "Game Week", x = g.skin.margin, y = ty, font = g.skin.small_bars.font[1], color = col2, w = 90, align = "right" }
	header.labels[2] = { text = "Opponent", x = header.labels[1].x + header.labels[1].w + g.skin.margin*2 + 30, y = ty, font = g.skin.small_bars.font[1], color = col2 }
	header.labels[3] = { text = "Pos.", x = self.w - g.skin.margin - 80, y = ty, font = g.skin.small_bars.font[1], color = col2, align = "center", w = 80}
	header.labels[4] = { text = "Result", x = header.labels[3].x - g.skin.margin - 80, y = ty, font = g.skin.small_bars.font[1], color = col2, align = "center", w = 80}
	self.bars[1] = header
	if team==nil then return end
	local fixtures = self.team.season.fixtures
	for i = 1, #fixtures do
		local fixture = fixtures[i]
		local bar = { x = self.x + g.skin.margin; y = self.y + g.skin.margin + i*g.skin.small_bars.h; w = self.w - g.skin.margin*2; h = g.skin.small_bars.h; alpha = g.skin.small_bars.alpha; }
		bar.color = i%2==0 and g.skin.bars.color1 or g.skin.bars.color3
		bar.labels, bar.images, bar.rects = {}, {}, {}
		bar.labels[1] = { text = "Week "..i, x = g.skin.margin, y = ty, font = g.skin.small_bars.font[2], color = g.skin.small_bars.color2, w = 90, align="right" }
		local opponent = fixture.home==self.team and fixture.away or fixture.home
		local at_home = fixture.home==self.team and "H" or "A"
		bar.labels[2] = { text = at_home, x = bar.labels[1].x + bar.labels[1].w + g.skin.margin, y = ty, font = g.skin.small_bars.font[2], color = at_home=="H" and self.team.color2 or g.skin.small_bars.color2, w = 30, align = "center" }
		if at_home=="H" then bar.rects[1] = { x = bar.labels[2].x, y = 0, w = bar.labels[2].w, h = bar.h, color = self.team.color1, alpha = g.skin.small_bars.alpha } end
		bar.images[1] = g.image.new("logos/128/"..opponent.id..".png", {mipmap=true, x = bar.labels[2].x + bar.labels[2].w + g.skin.margin, y = iy, w = g.skin.small_bars.img_size, h = g.skin.small_bars.img_size})
		bar.labels[3] = { text = opponent.short_name, x = bar.images[1].x + bar.images[1].w + g.skin.margin, y = ty, font = g.skin.small_bars.font[2], color = g.skin.small_bars.color2 }
		if fixture.finished then
			local team_score = fixture.home==self.team and fixture.home_score or fixture.away_score
			local opp_score = fixture.home==self.team and fixture.away_score or fixture.home_score
			bar.labels[4] = { text = g.db_manager.format_position(self.team.season.past_pos[i]), x = self.w - g.skin.margin - 80, y = ty, font = g.skin.small_bars.font[2], color = g.skin.small_bars.color2, w = 80, align = "center" }
			bar.labels[5] = { text = team_score.."\t-\t"..opp_score, x = bar.labels[4].x - g.skin.margin - 80, y = ty, font = g.skin.small_bars.font[2], color = g.skin.small_bars.color2, w = 80, align = "center" }
			--
			local image_string, image_color = "misc/draw_icon.png", {255, 165, 5, g.skin.small_bars.alpha}
			if fixture.winner==self.team then image_string, image_color = "misc/win_icon.png", {5, 255, 5, g.skin.small_bars.alpha}
			elseif fixture.winner==opponent then image_string, image_color = "misc/lose_icon.png", {255, 5, 5, g.skin.small_bars.alpha} end
			bar.images[2] = g.image.new(image_string, {mipmap=true, x = bar.labels[5].x - g.skin.margin - g.skin.small_bars.img_size, y = iy, w = g.skin.small_bars.img_size, h = g.skin.small_bars.img_size, color = image_color })
		end
		self.bars[#self.bars+1] = bar
	end
end

function fixture_list:draw()
	self.panel:draw()
	love.graphics.setScissor(self.x + g.skin.margin, self.y + g.skin.margin, self.w - g.skin.margin * 2, self.h - g.skin.margin * 2)
	for i=1, #self.bars do
		local bar = self.bars[i]
		g.components.bar_draw.draw(bar)
	end
	love.graphics.setScissor()
end

setmetatable(fixture_list, {_call = function(_, ...) return fixture_list.new(...) end})

return fixture_list