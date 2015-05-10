local league_past_winners = {}
league_past_winners.name = "League Past Winners"

function league_past_winners:init()
	self.__z = 1
	--
	g.console:log("league_past_winners:init")
end

function league_past_winners:added()
	self.panel = g.ui.panel.new(g.skin.screen.x + g.skin.margin, g.skin.screen.y + g.skin.margin, g.skin.screen.w - g.skin.margin * 2, g.skin.screen.h - g.skin.margin * 2)
	self.panel:set_colors(g.skin.components.color1, g.skin.components.color3)
	self:set_league()
end

function league_past_winners:update(dt)
	
end

function league_past_winners:draw()
	self.panel:draw()
	love.graphics.setScissor(self.panel.x + g.skin.margin, self.panel.y + g.skin.margin, self.panel.w - g.skin.margin * 2, self.panel.h - g.skin.margin * 2)
	for i=1, #self.bars do
		g.components.bar_draw.draw(self.bars[i])
	end
	love.graphics.setScissor()
end

function league_past_winners:set_league()
	self.league = g.db_manager.league_dict[g.vars.view.league_id]
	self.bars = {}
	--
	if not self.league.active then return end
	local header = { x = self.panel.x + g.skin.margin, y = self.panel.y + g.skin.margin, w = self.panel.w - g.skin.margin *2, h = g.skin.bars.h, color = self.league.color2, alpha = g.skin.bars.alpha }
	local year_w = 300
	local col_width = math.floor((header.w - year_w) / 3 + .5)
	header.labels = {
		{ text = "Season", x = g.skin.margin, y = g.skin.bars.ty, w = 300, align = "center", font = g.skin.bars.font[1], color = self.league.color1 };
		{ text = "Champions", x = g.skin.margin * 3 + year_w, y = g.skin.bars.ty, font = g.skin.bars.font[1], color = self.league.color1 };
		{ text = "Runners Up", x = g.skin.margin * 3 + year_w + col_width, y = g.skin.bars.ty, font = g.skin.bars.font[1], color = self.league.color1 };
		{ text = "Third Placed", x = g.skin.margin * 3 + year_w + col_width * 2, y = g.skin.bars.ty, font = g.skin.bars.font[1], color = self.league.color1 };
	}
	header.rects = { { x = 0, y = header.h - g.skin.bars.border, w = header.w, h = g.skin.bars.border, color = self.league.color3, alpha = g.skin.bars.alpha }}
	self.bars[1] = header
	local iter = #self.league.history.past_winners
	local k = 1
	for i=iter, 1, -1 do
		local data = self.league.history.past_winners[i]
		local bar = { x = self.panel.x + g.skin.margin, y = self.panel.y + g.skin.margin + k * g.skin.bars.h, w = self.panel.w - g.skin.margin * 2, h = g.skin.bars.h, alpha = g.skin.bars.alpha }
		bar.color = k%2==0 and g.skin.bars.color1 or g.skin.bars.color3
		bar.images, bar.labels, bar.rects = {}, {}, {}
		bar.labels[1] = { text = data.season.."/"..(data.season+1), x = 0, y = g.skin.bars.ty, w = year_w, align = "center", font = g.skin.bars.font[3], color = g.skin.bars.color2 }
		bar.rects[1] = { x = bar.labels[1].x, y = 0, w = bar.labels[1].w, h = g.skin.bars.h, color = self.league.color2, alpha = g.skin.bars.alpha }
		bar.images[1] = g.image.new("logos/128/"..data[1].team.id..".png", {mipmap = true, w = g.skin.bars.img_size, h = g.skin.bars.img_size, x = g.skin.margin * 3 + bar.labels[1].w, y = g.skin.bars.iy})
		bar.images[2] = g.image.new("logos/128/"..data[2].team.id..".png", {mipmap = true, w = g.skin.bars.img_size, h = g.skin.bars.img_size, x = g.skin.margin * 3 + bar.labels[1].w + col_width, y = g.skin.bars.iy})
		bar.images[3] = g.image.new("logos/128/"..data[3].team.id..".png", {mipmap = true, w = g.skin.bars.img_size, h = g.skin.bars.img_size, x = g.skin.margin * 3 + bar.labels[1].w + col_width * 2, y = g.skin.bars.iy})
		local c1, c2, c3 = g.vars.player.team_id==data[1].team.id, g.vars.player.team_id==data[2].team.id, g.vars.player.team_id==data[3].team.id
		c1, c2, c3 = c1 and g.skin.colors[3] or g.skin.bars.color2, c2 and g.skin.colors[3] or g.skin.bars.color2, c3 and g.skin.colors[3] or g.skin.bars.color2
		bar.labels[2] = { text = data[1].team.long_name, x = bar.images[1].x + g.skin.margin * 2 + bar.images[1].w, y = g.skin.bars.ty, font = g.skin.bars.font[2], color = c1 }
		bar.labels[3] = { text = data[2].team.long_name, x = bar.images[2].x + g.skin.margin * 2 + bar.images[2].w, y = g.skin.bars.ty, font = g.skin.bars.font[2], color = c2 }
		bar.labels[4] = { text = data[3].team.long_name, x = bar.images[3].x + g.skin.margin * 2 + bar.images[3].w, y = g.skin.bars.ty, font = g.skin.bars.font[2], color = c3 }
		table.insert(self.bars, bar)
		k = k + 1
	end
	--
	g.ribbon:set_league(self.league)
end

return league_past_winners