local new_game = {}
new_game.name = "New Game"

function new_game:init()
	self.__z = 1
	--
	g.console:log("new_game:init")
end

function new_game:added()
	local x, y, w, h = g.skin.tab, g.skin.tab, g.width - g.skin.tab * 2, g.height - g.skin.tab * 2
	self.panel = g.ui.panel.new(x, y, w, h)
	self.panel:set_colors(g.skin.components.color1, g.skin.components.color3)
	--
	self:set()
end

function new_game:removed()
	self.bars, self.buttons = {}, {}
end

function new_game:set()
	self.bars, self.buttons = {}, {}
	local w = self.panel.w - g.skin.margin * 2
	local splits = 4
	local split_w = (w - (splits-1) * g.skin.margin) / splits
	self.split_w = split_w
	-- Headers
	local header_text = { "1. Select Nation", "2. Select League", "3. Select Team", "4. Team Information" }
	for i=1, splits do
		local bar = { x = self.panel.x + g.skin.margin * i + split_w * (i-1), y = self.panel.y + g.skin.margin, w = split_w, h = g.skin.bars.h, color = g.skin.colors[1], alpha = g.skin.bars.alpha }
		bar.labels = { { text = header_text[i], x = g.skin.margin, y = g.skin.bars.ty, font = g.skin.bars.font[1], color = g.skin.bars.color2 } }
		table.insert(self.bars, bar)
	end
	--
	for i=1, #g.db_manager.nations do
		local nation = g.db_manager.nations[i]
		local bar = { x = self.panel.x + g.skin.margin, y = self.panel.y + g.skin.margin + i * g.skin.bars.h, w = split_w, h = g.skin.bars.h, alpha = g.skin.bars.alpha }
		bar.nation = nation
		bar.color = i%2==0 and g.skin.bars.color1 or g.skin.bars.color3
		bar.color1, bar.color2 = bar.color, g.skin.colors[3]
		local flag_img = g.image.new("flags/"..nation.flag..".png")
		flag_img.y = math.floor(bar.h/2 - flag_img.h/2 + .5); flag_img.x = flag_img.y
		local name = { text = nation.name, x = flag_img.x * 2 + flag_img.w, y = g.skin.bars.ty, font = g.skin.bars.font[2], color = g.skin.bars.color2 }
		name.w, name.h = g.font.width(name.text, name.font), g.font.height(name.font)
		bar.images = { flag_img }
		bar.labels = { name }
		--
		local btn = g.ui.button.new("", { x = math.floor(bar.x + .5), y = math.floor(bar.y + .5), w = math.floor(bar.w + .5), h = math.floor(bar.h + .5)})
		btn.visible = false
		btn.nation = nation
		btn.on_click = function(b)
			self:set_nation(b.nation)
		end
		--
		table.insert(self.buttons, btn)
		table.insert(self.bars, bar)
	end

	-- Add back button at bottom left
	local btn = g.ui.button.new("Back")
	btn.x, btn.y = self.panel.x + g.skin.margin, self.panel.y + self.panel.h - btn.h - g.skin.margin
	btn:set_colors(g.skin.red, g.skin.black, love.graphics.darken(g.skin.red))
	btn.on_release = function(b)
		g.state.switch(g.states.overview)
	end
	table.insert(self.buttons, btn)
end

function new_game:set_nation(nation)
	for i=1, #self.bars do
		local b = self.bars[i]
		if b.nation then
			if b.nation == nation then
				b.color = b.color2
				b.labels[1].font = g.skin.bars.font[1]
			else
				b.color = b.color1
				b.labels[1].font = g.skin.bars.font[2]
			end
		end
	end
	-- Get list of leagues in that nation sorted into level order (BPL first, Champ 2nd, etc.)
	table.sort(nation.leagues, function(a,b) return a.level < b.level end)
	--
	self:remove_team_bars()
	self:remove_league_bars()
	self:remove_team_overview()
	--
	for i=1, #nation.leagues do
		local lge = nation.leagues[i]
		local bar = { x = self.panel.x + g.skin.margin * 2 + self.split_w, y = self.panel.y + g.skin.margin + i * g.skin.bars.h, w = self.split_w, h = g.skin.bars.h, alpha = g.skin.bars.alpha }
		bar.league = lge
		bar.color = i%2==0 and g.skin.bars.color1 or g.skin.bars.color3
		bar.color1, bar.color2 = bar.color, g.skin.colors[3]
		local lge_img = g.image.new("logos/128/"..lge.flag..lge.level..".png", { mipmap=true, w = g.skin.bars.img_size, h = g.skin.bars.img_size, x = g.skin.margin * 3, y = g.skin.bars.iy })
		local name = { text = lge.long_name, x = g.skin.margin * 6 + g.skin.bars.img_size, y = g.skin.bars.ty, font = g.skin.bars.font[2], color = g.skin.bars.color2 }
		bar.images = { lge_img }
		bar.labels = { name }
		--
		local btn = g.ui.button.new("", { x = math.floor(bar.x + .5), y = math.floor(bar.y + .5), w = math.floor(bar.w + .5), h = math.floor(bar.h + .5)})
		btn.visible = false
		btn.league = lge
		btn.on_click = function(b)
			self:set_league(b.league)
		end
		--
		table.insert(self.buttons, btn)
		table.insert(self.bars, bar)
	end
end

function new_game:set_league(league)
	for i=1, #self.bars do
		local b = self.bars[i]
		if b.league then
			if b.league == league then
				b.color = b.color2
				b.labels[1].font = g.skin.bars.font[1]
			else
				b.color = b.color1
				b.labels[1].font = g.skin.bars.font[2]
			end
		end
	end
	-- Remove previous team bars & buttons
	self:remove_team_bars()
	self:remove_team_overview()
	--
	table.sort(league.teams, g.db_manager.sort_long_name)
	--
	for i=1, #league.teams do
		local team = league.teams[i]
		local bar = { x = self.panel.x + g.skin.margin * 3 + self.split_w * 2, y = self.panel.y + g.skin.margin + i * g.skin.bars.h, w = self.split_w, h = g.skin.bars.h, alpha = g.skin.bars.alpha }
		bar.team = team
		bar.color = i%2==0 and g.skin.bars.color1 or g.skin.bars.color3
		bar.color1, bar.color2 = bar.color, g.skin.colors[3]
		local team_img = g.image.new("logos/128/"..team.id..".png", { mipmap=true, w = g.skin.bars.img_size, h = g.skin.bars.img_size, x = g.skin.margin * 3, y = g.skin.bars.iy })
		local name = { text = team.long_name, x = g.skin.margin * 6 + g.skin.bars.img_size, y = g.skin.bars.ty, font = g.skin.bars.font[2], color = g.skin.bars.color2 }
		bar.images = { team_img }
		bar.labels = { name }
		--
		local btn = g.ui.button.new("", { x = math.floor(bar.x + .5), y = math.floor(bar.y + .5), w = math.floor(bar.w + .5), h = math.floor(bar.h + .5)})
		btn.visible = false
		btn.team = team
		btn.on_click = function(b)
			self:set_team(b.team)
		end
		--
		table.insert(self.buttons, btn)
		table.insert(self.bars, bar)
	end
end

function new_game:set_team(team)
	for i=1, #self.bars do
		local b = self.bars[i]
		if b.team then
			if b.team == team then
				b.color = b.color2
				b.labels[1].font = g.skin.bars.font[1]
			else
				b.color = b.color1
				b.labels[1].font = g.skin.bars.font[2]
			end
		end
	end
	--
	self:remove_team_overview()
	--
	local bar = { x = self.panel.x + g.skin.margin * 4 + self.split_w * 3, y = self.panel.y + g.skin.margin + g.skin.bars.h, w = self.split_w, h = self.panel.h - g.skin.margin * 2 - g.skin.bars.h }
	bar.color, bar.alpha = team.color3, g.skin.bars.alpha
	bar.overview = true
	local name = { text = team.short_name, y = g.skin.margin * 2, font = {"bold", 48}, color = team.color2 }
	name.w, name.h = g.font.width(name.text, name.font), g.font.height(name.font)
	name.x = math.floor(bar.w/2 - name.w/2 + .5)
	local name_rect = { x = name.x - g.skin.margin * 2, y = name.y - g.skin.margin, w = name.w + g.skin.margin * 4, h = name.h + g.skin.margin * 2, color = team.color1, alpha = g.skin.bars.alpha, rounded = g.skin.rounded }
	--
	local logo = g.image.new("logos/128/"..team.id..".png", {mipmap=true} )
	logo.x, logo.y = math.floor(bar.w/2 - logo.w/2 + .5), name_rect.y + name_rect.h + g.skin.margin
	--
	local r1 = { x = g.skin.margin, y = logo.y + logo.h + g.skin.margin, w = (bar.w - g.skin.margin * 2), h = g.skin.bars.h, color = team.color3, alpha = g.skin.bars.alpha }
	local r2 = { x = g.skin.margin, y = r1.y + r1.h + g.skin.margin, w = (bar.w - g.skin.margin * 2), h = g.skin.bars.h, color = team.color3, alpha = g.skin.bars.alpha }
	local r3 = { x = g.skin.margin, y = r2.y + r2.h + g.skin.margin, w = (bar.w - g.skin.margin * 2), h = g.skin.bars.h, color = team.color3, alpha = g.skin.bars.alpha }
	local r4 = { x = g.skin.margin, y = r3.y + r3.h + g.skin.margin, w = (bar.w - g.skin.margin * 2), h = g.skin.bars.h, color = team.color2, alpha = g.skin.bars.alpha }
	local def_rect = { x = g.skin.margin, y = r1.y, w = (bar.w - g.skin.margin * 2) * (team.def/100), h = g.skin.bars.h, color = team.color1, alpha = g.skin.bars.alpha }
	local mid_rect = { x = g.skin.margin, y = r2.y, w = (bar.w - g.skin.margin * 2) * (team.mid/100), h = g.skin.bars.h, color = team.color1, alpha = g.skin.bars.alpha }
	local att_rect = { x = g.skin.margin, y = r3.y, w = (bar.w - g.skin.margin * 2) * (team.att/100), h = g.skin.bars.h, color = team.color1, alpha = g.skin.bars.alpha }
	local ovr_rect = { x = g.skin.margin, y = r4.y, w = (bar.w - g.skin.margin * 2) * ((team.def+team.mid+team.att)/300), h = g.skin.bars.h, color = team.color2, alpha = g.skin.bars.alpha }
	local def_text = { text = "Defence", x = g.skin.margin + g.skin.bars.ty, y = def_rect.y + g.skin.bars.ty, font = g.skin.bars.font[3], color = team.color2 }
	local mid_text = { text = "Midfield", x = g.skin.margin + g.skin.bars.ty, y = mid_rect.y + g.skin.bars.ty, font = g.skin.bars.font[3], color = team.color2 }
	local att_text = { text = "Attack", x = g.skin.margin + g.skin.bars.ty, y = att_rect.y + g.skin.bars.ty, font = g.skin.bars.font[3], color = team.color2 }
	local ovr_text = { text = "Overall", x = g.skin.margin + g.skin.bars.ty, y = ovr_rect.y + g.skin.bars.ty, font = g.skin.bars.font[1], color = team.color3 }
	local def_stat = { text = team.def, x = r1.x + r1.w - g.skin.margin - g.skin.bars.column_size, y = r1.y + g.skin.bars.ty, font = g.skin.bars.font[3], color = team.color2, w = g.skin.bars.column_size, align = "center" }
	local mid_stat = { text = team.mid, x = r2.x + r2.w - g.skin.margin - g.skin.bars.column_size, y = r2.y + g.skin.bars.ty, font = g.skin.bars.font[3], color = team.color2, w = g.skin.bars.column_size, align = "center" }
	local att_stat = { text = team.att, x = r3.x + r3.w - g.skin.margin - g.skin.bars.column_size, y = r3.y + g.skin.bars.ty, font = g.skin.bars.font[3], color = team.color2, w = g.skin.bars.column_size, align = "center" }
	local ovr_stat = { text = math.floor((team.def+team.mid+team.att)/3+.5), x = r4.x + r4.w - g.skin.margin - g.skin.bars.column_size, y = r4.y + g.skin.bars.ty, font = g.skin.bars.font[3], color = team.color3, w = g.skin.bars.column_size, align = "center" }
	--
	bar.labels = { name, def_text, mid_text, att_text, ovr_text, def_stat, mid_stat, att_stat, ovr_stat }
	bar.rects = { name_rect, r1, r2, r3, r4, def_rect, mid_rect, att_rect, ovr_rect }
	bar.images = { logo }
	--
	local btn = g.ui.button.new("Start Game as " .. name.text, { x = bar.x + g.skin.margin, w = bar.w - g.skin.margin * 2, h = g.skin.bars.h * 2, font = g.font.get(g.skin.bold) })
	btn.overview = true
	btn.y = bar.y + bar.h - g.skin.margin - btn.h
	btn:set_colors(team.color2, team.color1, team.color3)
	btn.on_release = function(b)
		g.db_manager.begin(team.id)
		g.state.pop()
		g.state.add(g.states.navbar)
		g.state.add(g.states.ribbon)
		g.state.add(g.states.club_overview)
		print(g.state.active().name)
		g.in_game = true
	end
	table.insert(self.buttons, btn)
	--
	table.insert(self.bars, bar)
end

function new_game:remove_league_bars()
	for i=#self.bars, 1, -1 do
		if self.bars[i].league then table.remove(self.bars, i) end
	end
	for i=#self.buttons, 1, -1 do
		if self.buttons[i].league then table.remove(self.buttons, i) end
	end
end

function new_game:remove_team_bars()
	for i=#self.bars, 1, -1 do
		if self.bars[i].team then table.remove(self.bars, i) end
	end
	for i=#self.buttons, 1, -1 do
		if self.buttons[i].team then table.remove(self.buttons, i) end
	end
end

function new_game:remove_team_overview()
	for i=#self.bars, 1, -1 do
		if self.bars[i].overview then table.remove(self.bars, i) end
	end
	for i=#self.buttons, 1, -1 do
		if self.buttons[i].overview then table.remove(self.buttons, i) end
	end
end

function new_game:update(dt)
	for i=1, #self.buttons do self.buttons[i]:update(dt) end
end

function new_game:draw()
	self.panel:draw()
	for i=1, #self.bars do g.components.bar_draw.draw(self.bars[i]) end
	for i=1, #self.buttons do self.buttons[i]:draw() end
end

function new_game:keypressed(k, ir)
	if k=="escape" or k=="backspace" then g.state.switch(g.states.overview) end
end

function new_game:mousepressed(x, y, b)
	for i=1, #self.buttons do 
		if self.buttons[i] then self.buttons[i]:mousepressed(x, y, b) end
	end
end

function new_game:mousereleased(x, y, b)
	for i=1, #self.buttons do
		if self.buttons[i] then self.buttons[i]:mousereleased(x, y, b) end
	end
end

return new_game