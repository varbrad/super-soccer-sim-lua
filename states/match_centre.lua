local mc = {}
mc.name = "Match Centre"

function mc:arr_to_rgb(array)
	return { r = array[1], g = array[2], b = array[3] }
end
function mc:tween_color(object, time, from, to, type)
	-- Ignores alpha!
	object.color = { r = from.r, g = from.g, b = from.b }
	self.flux:to(object.color, time, { r = to.r, g = to.g, b = to.b }):ease(type)
end

function mc:init()
	self.flux = g.flux:group()
end

local delta = nil
local last_score = nil

function mc:added(fixture)
	if fixture==nil then return end -- Just return if fixture is nil (if refresh_all is called for example)
	--
	delta, last_score, exit = 0, { 0, 0 }, false
	--
	g.busy = true
	self.fixture = fixture
	g.engine.begin_fixture(fixture)
	--
	self.home, self.away = g.database.get_team(fixture.home), g.database.get_team(fixture.away)
	self.player = g.database.get_player_team()
	-- Need to set player team stats to current starting 11
	--
	self.event = fixture.type
	if self.event == "L" then
		self.event = { text = self.home.refs.league.long_name, color1 = self.home.refs.league.color1, color2 = self.home.refs.league.color2 }
	end
	--
	local title_font = { "bold", 48 }
	local score_font = { "bebas", 96 }
	-- Panel 1 is for match bar, Panel 2 is for stats bar on left
	self.panel1 = g.ui.panel.new(g.skin.margin, g.skin.margin, g.width - g.skin.margin * 2, 128 + g.skin.bars.h + g.skin.margin * 5) -- self.panel1 height needs to be set later
	self.panel2 = g.ui.panel.new(g.skin.margin, self.panel1.y + self.panel1.h + g.skin.margin, 256 + g.skin.margin * 2, g.height - g.skin.margin * 3 - self.panel1.h)
	self.panel1:set_colors(g.skin.components.color1, g.skin.components.color3)
	self.panel2:set_colors(g.skin.components.color1, g.skin.components.color3)
	--
	self.match_bar = { x = self.panel1.x + g.skin.margin, y = self.panel1.y + g.skin.margin, w = self.panel1.w - g.skin.margin * 2, h = self.panel1.h - g.skin.margin * 2, color = g.skin.black, alpha = 0 }
	--
	local home_rect = { x = 0, y = 0, w = math.floor(self.match_bar.w / 2 - g.skin.margin / 2 + .5), h = self.match_bar.h, color = self.home.color1, alpha = 255, rounded = g.skin.rounded }
	local away_rect = { x = home_rect.w + g.skin.margin, y = 0, w = home_rect.w, h = self.match_bar.h, color = self.away.color1, alpha = 255, rounded = g.skin.rounded }
	--
	local score_rect_1 = { x = home_rect.x + home_rect.w - g.skin.margin - 128, y = home_rect.y + home_rect.h - g.skin.margin - 128, w = 128, h = 128, alpha = 255, rounded = g.skin.rounded }
	local score_rect_2 = { x = away_rect.x + g.skin.margin, y = away_rect.y + away_rect.h - g.skin.margin - 128, w = 128, h = 128, alpha = 255, rounded = g.skin.rounded }
	score_rect_1.color_from, score_rect_1.color_to = self:arr_to_rgb(self.home.color2), self:arr_to_rgb(self.home.color3)
	score_rect_2.color_from, score_rect_2.color_to = self:arr_to_rgb(self.away.color2), self:arr_to_rgb(self.away.color3)
	score_rect_1.color, score_rect_2.color = score_rect_1.color_to, score_rect_2.color_to
	--
	local event_rect = { x = score_rect_1.x, y = g.skin.margin, w = 256 + g.skin.margin * 3, h = self.match_bar.h - 128 - g.skin.margin * 3, color = self.event.color2, alpha = 255, rounded = g.skin.rounded }
	local time_circ = { x = math.floor(self.match_bar.w/2+.5), y = score_rect_1.y + math.floor(score_rect_1.h/2+.5), radius = 20, color = self.event.color2, alpha = 255, smooth = true }
	--
	local img_y = math.floor(self.match_bar.h/2 - 64 + .5)
	local txt_y = math.floor(self.match_bar.h/2 - g.font.height(title_font)/2 + .5)
	--
	local home_logo = g.image.new("logos/"..self.home.id..".png", {mipmap=true, w=128, h=128, x = score_rect_1.x - g.skin.margin - 128, y = img_y })
	local away_logo = g.image.new("logos/"..self.away.id..".png", {mipmap=true, w=128, h=128, x = score_rect_2.x + score_rect_2.w + g.skin.margin, y = img_y })
	--
	local home_name = { text = self.home.long_name, y = txt_y, font = title_font, color = self.home.color2 }
	home_name.x = home_logo.x - g.skin.margin - g.font.width(home_name.text, home_name.font)
	local away_name = { text = self.away.long_name, x = away_logo.x + away_logo.w + g.skin.margin, y = txt_y, font = title_font, color = self.away.color2 }
	local event_name = { text = self.event.text .. " - Week " .. g.database.vars.week - 1, x = event_rect.x, y = event_rect.y + g.skin.bars.ty, w = event_rect.w, align = "center", font = g.skin.bars.font[1], color = self.event.color1 }
	local score_txt_y = math.floor(score_rect_1.h/2 - g.font.height(score_font)/2 + .5)
	local home_score = { text = "", x = score_rect_1.x, y = score_rect_1.y + score_txt_y, w = 128, align = "center", font = score_font, color = self.home.color2 }
	local away_score = { text = "", x = score_rect_2.x, y = score_rect_2.y + score_txt_y, w = 128, align = "center", font = score_font, color = self.away.color2 }
	local time_label = { text = "v", x = time_circ.x - time_circ.radius, w = time_circ.radius * 2, align = "center", font = g.skin.bars.font[3], color = self.event.color1 }
	time_label.y = time_circ.y - math.floor(g.font.height(time_label.font) / 2 + .5)
	self.match_bar.score_rect_1 = score_rect_1
	self.match_bar.score_rect_2 = score_rect_2
	self.match_bar.home_score = home_score
	self.match_bar.away_score = away_score
	self.match_bar.time_label = time_label
	--
	self.match_bar.rects = { home_rect, away_rect, score_rect_1, score_rect_2, event_rect, time_circ }
	self.match_bar.labels = { home_name, away_name, event_name, home_score, away_score, time_label }
	self.match_bar.images = { home_logo, away_logo }
	----
	--
	self.stat_bar = { x = self.panel2.x + g.skin.margin, y = self.panel2.y + g.skin.margin, w = self.panel2.w - g.skin.margin * 2, h = self.panel2.h - g.skin.margin * 2, color = g.skin.black, alpha = 0 }
	self.stat_bar.label_color = g.skin.bars.color2
	local sbw = self.stat_bar.w / 2
	local home_rect = { x = 0, y = 0, w = sbw - g.skin.margin / 2, h = 64 + g.skin.margin * 2, color = self.home.color1, alpha = g.skin.bars.alpha, rounded = g.skin.rounded }
	local away_rect = { x = sbw + g.skin.margin / 2, y = 0, w = home_rect.w, h = 64 + g.skin.margin * 2, color = self.away.color1, alpha = g.skin.bars.alpha, rounded = g.skin.rounded }
	local dx = math.floor(home_rect.w / 2 - 32 + .5)
	local home_logo = g.image.new("logos/"..self.home.id..".png", {mipmap=true, w=64, h=64, x = dx, y = g.skin.margin })
	local away_logo = g.image.new("logos/"..self.away.id..".png", {mipmap=true, w=64, h=64, x = away_rect.x + dx, y = g.skin.margin })
	--
	self.stat_bar.labels = {}
	local labels = {"Possession", "Shots", "On Target", "Off Target", "Free Kicks", "Corner Kicks", "Offsides", "Fouls", "Yellow Cards", "Red Cards" }
	local height_left = (self.stat_bar.h - home_rect.h) / #labels
	local label_y = math.floor(height_left / 2 - g.font.height(g.skin.bars.font[1])/2 + .5)
	local label2_y = math.floor(height_left / 2 - g.font.height(g.skin.h3)/2 + .5)
	for i = 1, #labels do
		local y = home_rect.y + home_rect.h + label_y + (i-1) * height_left
		table.insert(self.stat_bar.labels, { text = labels[i], x = 0, y = y, w = self.stat_bar.w, align = "center", font = g.skin.bars.font[1] })
		--
		y = home_rect.y + home_rect.h + label2_y + (i-1) * height_left
		table.insert(self.stat_bar.labels, { text = "-", x = home_rect.x - g.skin.tab, y = y, w = home_rect.w, align = "center", font = g.skin.h3 })
		table.insert(self.stat_bar.labels, { text = "-", x = away_rect.x + g.skin.tab, y = y, w = away_rect.w, align = "center", font = g.skin.h3 })
	end
	--
	self.stat_bar.rects = { home_rect, away_rect }
	self.stat_bar.images = { home_logo, away_logo }
	--
	----
	self.bars = { self.match_bar, self.stat_bar }
	self.game_time = 0
	--
	g.tween_alpha()
end

function mc:update(dt)
	if exit then
		g.state.pop() -- Remove the current singlet state
		g.state.add(g.states.navbar) -- Add navbar
		g.state.add(g.states.ribbon) -- add ribbon
		g.database.post_advance_week()
		g.database.vars.view.league_id = g.database.get_player_league().id
		g.state.add(g.states.league_overview) -- default to the club_overview page
		g.busy = false
	end
	--
	self.flux:update(dt)
	self.match_bar.time_label.text = self.fixture.minute=="FT" and "FT" or self.fixture.minute .. "'"
	self.match_bar.home_score.text = self.fixture.home_score
	self.match_bar.away_score.text = self.fixture.away_score
	if not self.fixture.finished then
		delta = delta + dt
		if delta > .1 then
			delta = delta - .1
			g.engine.step_fixture(self.fixture)
			-- Do a check if anyone scored
			if self.fixture.home_score > last_score[1] then
				-- Home scored
				local score_rect = self.match_bar.score_rect_1
				self:tween_color(score_rect, g.skin.tween.time * 5, score_rect.color_from, score_rect.color_to, g.skin.tween.type)
				--
				last_score[1] = self.fixture.home_score
			end
			if self.fixture.away_score > last_score[2] then
				-- Away scored
				local score_rect = self.match_bar.score_rect_2
				self:tween_color(score_rect, g.skin.tween.time * 5, score_rect.color_from, score_rect.color_to, g.skin.tween.type)
				--
				last_score[2] = self.fixture.away_score
			end
		end
	end
end

function mc:draw()
	self.panel1:draw()
	self.panel2:draw()
	for i = 1, #self.bars do
		g.components.bar_draw.draw(self.bars[i], 0, 0, g.tween.t_alpha)
	end
end

function mc:keypressed(k, ir)
	if k==" " then 
		if self.fixture.finished then 
			exit = true
		else
			while not self.fixture.finished do g.engine.step_fixture(self.fixture) end
		end
	end
end

return mc