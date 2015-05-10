local club_history = {}
club_history.name = "Club History"

function club_history:init()
	self.__z = 1
	--
	g.console:log("club_history:init")
end

function club_history:added()
	self.panel = g.ui.panel.new(g.skin.screen.x + g.skin.margin, g.skin.screen.y + g.skin.margin, g.skin.screen.w - g.skin.margin * 2, g.skin.screen.h - g.skin.margin * 2)
	self.panel:set_colors(g.skin.components.color1, g.skin.components.color3)
	self:set_team()
end

function club_history:update(dt)
	for i=1, #self.buttons do self.buttons[i]:update(dt) end
end

function club_history:draw()
	self.panel:draw()
	love.graphics.setScissor(self.panel.x + g.skin.margin, self.panel.y + g.skin.margin, self.panel.w - g.skin.margin * 2, self.panel.h - g.skin.margin * 2)
	--
	for i=1,#self.bars do
		g.components.bar_draw.draw(self.bars[i])
	end
	--
	love.graphics.setScissor()
end

local function color_copy(c)
	return {c[1], c[2], c[3], c[4] or 255}
end

function club_history:set_team()
	self.team = g.db_manager.team_dict[g.vars.view.team_id]
	self.bars, self.buttons = {}, {}
	--
	if not self.team then return end
	local header = { x = self.panel.x + g.skin.margin, y = self.panel.y + g.skin.margin, w = self.panel.w - g.skin.margin *2, h = g.skin.bars.h, color = self.team.color1, alpha = g.skin.bars.alpha }
	local year_w = 300
	header.labels = {
		{ text = "Season", x = g.skin.margin, y = g.skin.bars.ty, w = 300, align = "center", font = g.skin.bars.font[1], color = self.team.color2 };
		{ text = "League", x = g.skin.margin * 3 + 300, y = g.skin.bars.ty, font = g.skin.bars.font[1], color = self.team.color2 };
		{ text = "Pos.", x = g.skin.margin * 5 + 500 + g.skin.bars.img_size, y = g.skin.bars.ty, w = 100, align = "center", font = g.skin.bars.font[1], color = self.team.color2 };
		{ text = "P", x = g.skin.margin * 6 + 600 + g.skin.bars.img_size, y = g.skin.bars.ty, w = g.skin.bars.column_size, align = "center", font = g.skin.bars.font[1], color = self.team.color2 };
		{ text = "W", x = g.skin.margin * 6 + 600 + g.skin.bars.img_size + g.skin.bars.column_size, y = g.skin.bars.ty, w = g.skin.bars.column_size, align = "center", font = g.skin.bars.font[1], color = self.team.color2 };
		{ text = "D", x = g.skin.margin * 6 + 600 + g.skin.bars.img_size + g.skin.bars.column_size * 2, y = g.skin.bars.ty, w = g.skin.bars.column_size, align = "center", font = g.skin.bars.font[1], color = self.team.color2 };
		{ text = "L", x = g.skin.margin * 6 + 600 + g.skin.bars.img_size + g.skin.bars.column_size * 3, y = g.skin.bars.ty, w = g.skin.bars.column_size, align = "center", font = g.skin.bars.font[1], color = self.team.color2 };
		{ text = "GF", x = g.skin.margin * 6 + 600 + g.skin.bars.img_size + g.skin.bars.column_size * 4, y = g.skin.bars.ty, w = g.skin.bars.column_size, align = "center", font = g.skin.bars.font[1], color = self.team.color2 };
		{ text = "GA", x = g.skin.margin * 6 + 600 + g.skin.bars.img_size + g.skin.bars.column_size * 5, y = g.skin.bars.ty, w = g.skin.bars.column_size, align = "center", font = g.skin.bars.font[1], color = self.team.color2 };
		{ text = "GD", x = g.skin.margin * 6 + 600 + g.skin.bars.img_size + g.skin.bars.column_size * 6, y = g.skin.bars.ty, w = g.skin.bars.column_size, align = "center", font = g.skin.bars.font[1], color = self.team.color2 };
		{ text = "Pts", x = g.skin.margin * 6 + 600 + g.skin.bars.img_size + g.skin.bars.column_size * 7, y = g.skin.bars.ty, w = g.skin.bars.column_size, align = "center", font = g.skin.bars.font[1], color = self.team.color2 };
		{ text = "W%", x = g.skin.margin * 9 + 600 + g.skin.bars.img_size + g.skin.bars.column_size * 8, y = g.skin.bars.ty, w = g.skin.bars.column_size, align = "center", font = g.skin.bars.font[1], color = self.team.color2 };
		{ text = "D%", x = g.skin.margin * 9 + 600 + g.skin.bars.img_size + g.skin.bars.column_size * 9, y = g.skin.bars.ty, w = g.skin.bars.column_size, align = "center", font = g.skin.bars.font[1], color = self.team.color2 };
		{ text = "L%", x = g.skin.margin * 9 + 600 + g.skin.bars.img_size + g.skin.bars.column_size * 10, y = g.skin.bars.ty, w = g.skin.bars.column_size, align = "center", font = g.skin.bars.font[1], color = self.team.color2 };
		{ text = "GF/G", x = g.skin.margin * 9 + 600 + g.skin.bars.img_size + g.skin.bars.column_size * 11, y = g.skin.bars.ty, w = g.skin.bars.column_size, align = "center", font = g.skin.bars.font[1], color = self.team.color2 };
		{ text = "GA/G", x = g.skin.margin * 9 + 600 + g.skin.bars.img_size + g.skin.bars.column_size * 12, y = g.skin.bars.ty, w = g.skin.bars.column_size, align = "center", font = g.skin.bars.font[1], color = self.team.color2 };
		{ text = "Pts/G", x = g.skin.margin * 9 + 600 + g.skin.bars.img_size + g.skin.bars.column_size * 13, y = g.skin.bars.ty, w = g.skin.bars.column_size, align = "center", font = g.skin.bars.font[1], color = self.team.color2 };
	}
	header.rects = { { x = 0, y = header.h - g.skin.bars.border, w = header.w, h = g.skin.bars.border, color = self.team.color3, alpha = g.skin.bars.alpha }}
	self.bars[1] = header
	local iter = #self.team.history.seasons
	local k = 1
	for i=iter, 1, -1 do
		local data = self.team.history.seasons[i]
		local bar = { x = self.panel.x + g.skin.margin, y = self.panel.y + g.skin.margin + k * g.skin.bars.h, w = self.panel.w - g.skin.margin * 2, h = g.skin.bars.h, alpha = g.skin.bars.alpha }
		bar.color = k%2==0 and g.skin.bars.color1 or g.skin.bars.color3
		bar.images, bar.labels, bar.rects = {}, {}, {}
		bar.labels[1] = { text = data.season.."/"..(data.season+1), x = 0, y = g.skin.bars.ty, w = year_w, align = "center", font = g.skin.bars.font[3], color = self.team.color2 }
		bar.rects[1] = { x = bar.labels[1].x, y = 0, w = bar.labels[1].w, h = g.skin.bars.h, color = self.team.color1, alpha = g.skin.bars.alpha }
		bar.images[1] = g.image.new("logos/128/"..data.league.flag..data.league.level..".png", {mipmap=true, w = g.skin.bars.img_size, h = g.skin.bars.img_size, x = g.skin.margin * 3 + bar.labels[1].w, y = g.skin.bars.iy})
		bar.labels[2] = { text = data.league.long_name, x = bar.images[1].x + g.skin.margin * 2 + bar.images[1].w, y = g.skin.bars.ty, font = g.skin.bars.font[2], color = g.skin.bars.color2 }
		bar.labels[2].w, bar.labels[2].h = g.font.width(bar.labels[2].text, bar.labels[2].font), g.font.height(bar.labels[2].font)
		--
		local btn = g.ui.button.new("", { w = bar.labels[2].w, h = bar.labels[2].h, x = bar.x + bar.labels[2].x, y = bar.y + bar.labels[2].y } )
		btn.on_enter = function(btn) bar.labels[2].underline = true end
		btn.on_exit = function(btn) bar.labels[2].underline = false end
		btn.on_release = function(btn) g.vars.view.league_id = data.league.id; g.state.switch(g.states.league_overview) end
		table.insert(self.buttons, btn)
		--
		bar.labels[3] = { text = g.db_manager.format_position(data.stats.pos), x = bar.labels[2].x + 200, w = 100, align = "center", y = g.skin.bars.ty, font = g.skin.bars.font[3], color = g.skin.bars.color2 }
		local col = color_copy(bar.color)
		local do_rect = false
		if data.promoted then col[2] = col[2] + 70 elseif data.relegated then col[1] = col[1] + 50 end
		if not data.promoted and data.stats.pos==1 then col[1], col[2] = col[1] + 190, col[2] + 130; do_rect = true end
		if data.promoted or data.relegated or do_rect then	bar.rects[2] = { x = bar.rects[1].x + bar.rects[1].w, y = 0, w = bar.w - bar.rects[1].w, h =g.skin.bars.h, color = col, alpha = g.skin.bars.alpha } end
		bar.rects[#bar.rects+1] = { x = bar.labels[3].x, y = 0, w = bar.labels[3].w, h = g.skin.bars.h, color = bar.color, alpha = g.skin.bars.alpha }
		--
		bar.labels[4] = { text = tostring(data.stats.p), x = g.skin.margin + bar.labels[3].x + bar.labels[3].w, y = g.skin.bars.ty, w = g.skin.bars.column_size, align = "center", font = g.skin.bars.font[3], color = g.skin.bars.color2 }
		bar.labels[5] = { text = tostring(data.stats.w), x = bar.labels[4].x + bar.labels[4].w, y = g.skin.bars.ty, w = g.skin.bars.column_size, align = "center", font = g.skin.bars.font[3], color = g.skin.bars.color2 }
		bar.labels[6] = { text = tostring(data.stats.d), x = bar.labels[5].x + bar.labels[5].w, y = g.skin.bars.ty, w = g.skin.bars.column_size, align = "center", font = g.skin.bars.font[3], color = g.skin.bars.color2 }
		bar.labels[7] = { text = tostring(data.stats.l), x = bar.labels[6].x + bar.labels[6].w, y = g.skin.bars.ty, w = g.skin.bars.column_size, align = "center", font = g.skin.bars.font[3], color = g.skin.bars.color2 }
		bar.labels[8] = { text = tostring(data.stats.gf), x = bar.labels[7].x + bar.labels[7].w, y = g.skin.bars.ty, w = g.skin.bars.column_size, align = "center", font = g.skin.bars.font[3], color = g.skin.bars.color2 }
		bar.labels[9] = { text = tostring(data.stats.ga), x = bar.labels[8].x + bar.labels[8].w, y = g.skin.bars.ty, w = g.skin.bars.column_size, align = "center", font = g.skin.bars.font[3], color = g.skin.bars.color2 }
		local gd = tostring(data.stats.gd)
		if data.stats.gd > 0 then gd = "+"..gd end
		bar.labels[10] = { text = gd, x = bar.labels[9].x + bar.labels[9].w, y = g.skin.bars.ty, w = g.skin.bars.column_size, align = "center", font = g.skin.bars.font[3], color = g.skin.bars.color2 }
		bar.labels[11] = { text = tostring(data.stats.pts), x = bar.labels[10].x + bar.labels[10].w, y = g.skin.bars.ty, w = g.skin.bars.column_size, align = "center", font = g.skin.bars.font[3], color = g.skin.bars.color2 }
		bar.rects[#bar.rects+1] = { x = bar.labels[11].x, y = 0, w = bar.labels[11].w, h = g.skin.bars.h, color = bar.color, alpha = g.skin.bars.alpha }
		--
		local win_p = tostring(math.floor(data.stats.w*100/data.stats.p + .5).."%")
		local draw_p = tostring(math.floor(data.stats.d*100/data.stats.p + .5).."%")
		local lose_p = tostring(math.floor(data.stats.l*100/data.stats.p + .5).."%")
		local gfpg = string.format("%.2f", data.stats.gf/data.stats.p)
		local gapg = string.format("%.2f", data.stats.ga/data.stats.p)
		local ppg = string.format("%.2f", data.stats.pts/data.stats.p)
		bar.labels[12] = { text = win_p, x = bar.labels[11].x + bar.labels[11].w + g.skin.margin * 3, y = g.skin.bars.ty, w = g.skin.bars.column_size, align = "center", font = g.skin.bars.font[3], color = g.skin.bars.color2 }
		bar.labels[13] = { text = draw_p, x = bar.labels[12].x + bar.labels[12].w, y = g.skin.bars.ty, w = g.skin.bars.column_size, align = "center", font = g.skin.bars.font[3], color = g.skin.bars.color2 }
		bar.labels[14] = { text = lose_p, x = bar.labels[13].x + bar.labels[13].w, y = g.skin.bars.ty, w = g.skin.bars.column_size, align = "center", font = g.skin.bars.font[3], color = g.skin.bars.color2 }
		bar.labels[15] = { text = gfpg, x = bar.labels[14].x + bar.labels[14].w, y = g.skin.bars.ty, w = g.skin.bars.column_size, align = "center", font = g.skin.bars.font[3], color = g.skin.bars.color2 }
		bar.labels[16] = { text = gapg, x = bar.labels[15].x + bar.labels[15].w, y = g.skin.bars.ty, w = g.skin.bars.column_size, align = "center", font = g.skin.bars.font[3], color = g.skin.bars.color2 }
		bar.labels[17] = { text = ppg, x = bar.labels[16].x + bar.labels[16].w, y = g.skin.bars.ty, w = g.skin.bars.column_size, align = "center", font = g.skin.bars.font[3], color = g.skin.bars.color2 }
		table.insert(self.bars, bar)
		k = k + 1
	end
	--
	g.ribbon:set_team(self.team)
end

function club_history:mousepressed(x, y, b)
	for i=1, #self.buttons do self.buttons[i]:mousepressed(x, y, b) end
end

function club_history:mousereleased(x, y, b)
	for i=1, #self.buttons do self.buttons[i]:mousereleased(x, y, b) end
end

return club_history