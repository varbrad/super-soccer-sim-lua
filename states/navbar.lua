local navbar = {}
navbar.name = "Navbar"

function navbar:init()
	self.__z = 3
	self.flux = g.flux:group()
	--
	g.console:log("navbar:init")
end

function navbar:added()
	self:set()
end

function navbar:set()
	local team = g.database.get_player_team()
	local league = g.database.get_player_league()
	self.buttons, self.labels, self.rects = {}, {}, {}
	if team==nil then return end
	self.color1, self.color2 = team.color3, team.color1
	local btn_w = g.skin.navbar.w - g.skin.navbar.border - g.skin.margin * 2
	local btn_x = math.floor((g.skin.navbar.w-g.skin.navbar.border)/2 - btn_w/2 + .5)
	local names = {
		"Inbox",
		"Squad",
		"Youth Academy",
		"Financial",
		--
		g.database.get_player_team().short_name,
		g.database.get_player_league().short_name,
		--
		"Quit",
		"Save",
		"Achievements"
	}
	local funcs = {
		-- Game btns
		function() g.state.switch(g.states.game_inbox) end,
		function() g.state.switch(g.states.game_squad) end,
		function() g.state.switch(g.states.game_youth) end,
		function() g.state.switch(g.states.game_financial) end,
		-- Top
		function() g.database.vars.view.team_id = team.id; g.state.switch(g.states.club_overview) end,
		function() g.database.vars.view.league_id = league.id; g.state.switch(g.states.league_overview) end,
		-- Bottom
		function() g.state.pop(); g.state.remove(g.states.ribbon); g.state.remove(g.states.navbar); g.state.add(g.states.overview) end,
		function() if not g.busy then g.database.save_game() end end,
		function() g.state.switch(g.states.game_achievements) end,
	}
	local imgs = {
		g.image.new("icons/inbox.png", {mipmap=true, w=32, h=32, color = team.color1, alpha = g.skin.bars.alpha }),
		g.image.new("icons/squad.png", {mipmap=true, w=32, h=32, color = team.color1, alpha = g.skin.bars.alpha }),
		g.image.new("icons/youth.png", {mipmap=true, w=32, h=32, color = team.color1, alpha = g.skin.bars.alpha }),
		g.image.new("icons/money.png", {mipmap=true, w=32, h=32, color = team.color1, alpha = g.skin.bars.alpha }),
		--
		g.image.new("logos/"..team.id..".png", {mipmap=true, w = 32, h = 32, color = team.color1, alpha = g.skin.bars.alpha, team = team}),
		g.image.new("logos/"..league.flag..league.level..".png", {mipmap=true, w=32, h=32, color = team.color1, alpha = g.skin.bars.alpha, league = league }),
		--
		g.image.new("icons/error.png", {mipmap=true, w=32, h=32, color = team.color1, alpha = g.skin.bars.alpha }),
		g.image.new("icons/save.png", {mipmap=true, w=32, h=32, color = team.color1, alpha = g.skin.bars.alpha }),
		g.image.new("icons/star.png", {mipmap=true, w=32, h=32, color = team.color1, alpha = g.skin.bars.alpha })
	}
	local pos = { "top", "top", "top", "top", "gap_top", "top", "top", "bottom", "bottom", "bottom" }
	local whiten = {false, false, false, false, true, true, false, false, false}
	local top_y = btn_x
	local bottom_y = g.skin.navbar.h - btn_w - btn_x
	local index = 0
	for i = 1, #pos do
		local y = pos[i]
		local pos_type = y
		if y=="top" then
			y = top_y
			top_y = top_y + btn_w + g.skin.margin
		elseif y=="bottom" then
			y = bottom_y
			bottom_y = bottom_y - btn_w - g.skin.margin
		elseif y=="gap_top" then
			y = top_y
			top_y = top_y + g.skin.margin * 2
		elseif y=="gap_bottom" then
			y = bottom_y
			top_y = top_y - g.skin.margin * 3
		end
		--
		if pos_type=="bottom" or pos_type=="top" then
			index = index + 1
			local label = { text = names[index], font = g.skin.bars.font[3], color = team.color2, bg_color = team.color3 }
			local to_color = whiten[index] and {255, 255, 255} or team.color2
			label.w, label.h = g.font.width(label.text, label.font), g.font.height(label.font)
			label.x = g.skin.navbar.x + g.skin.navbar.w - g.skin.margin - label.w; label.x1 = label.x
			label.y = y + math.floor(btn_w/2 - label.h/2 + .5)
			table.insert(self.labels, label)
			--
			local btn = g.ui.button.new("", { x = btn_x, y = y, w = btn_w, h = btn_w, image = imgs[index], on_release = funcs[index] })
			btn.image.color = to_color
			btn.image.alpha = 90
			btn.on_enter = function(b)
				self.flux:to(label, g.skin.tween.time, { x = g.skin.navbar.x + g.skin.navbar.w + g.skin.margin }):ease(g.skin.tween.type)
				self.flux:to(btn.image, g.skin.tween.time, { alpha = 255 }):ease(g.skin.tween.type)
			end
			btn.on_exit = function(b)
				self.flux:to(label, g.skin.tween.time, { x = label.x1 }):ease(g.skin.tween.type)
				self.flux:to(btn.image, g.skin.tween.time, { alpha = 90 }):ease(g.skin.tween.type)
			end
			btn:set_colors(team.color3, team.color2, team.color1)
			table.insert(self.buttons, btn)
		elseif pos_type=="gap_top" or pos_type=="gap_bottom" then
			local rect = { x = g.skin.navbar.x, y = y, w = g.skin.navbar.w - g.skin.navbar.border, h = g.skin.margin }
			table.insert(self.rects, rect)
		end
	end
end

function navbar:update(dt)
	self.flux:update(dt)
	for i = 1, #self.buttons do
		self.buttons[i]:update(dt)
	end
end

function navbar:draw()
	for i=1, #self.labels do
		local label = self.labels[i]
		g.font.set(label.font)
		love.graphics.setColor(label.bg_color)
		love.graphics.roundrect("fill", label.x - g.skin.margin * 3, label.y - g.skin.margin, label.w + g.skin.margin * 4, label.h + g.skin.margin * 2, g.skin.rounded)
		love.graphics.setColor(label.color)
		love.graphics.print(label.text, label.x, label.y)
	end
	love.graphics.setColorAlpha(self.color1, g.skin.navbar.alpha)
	love.graphics.rectangle("fill", g.skin.navbar.x, g.skin.navbar.y, g.skin.navbar.w, g.skin.navbar.h)
	for i = 1, #self.buttons do
		self.buttons[i]:draw()
	end
	love.graphics.setColorAlpha(self.color2, g.skin.navbar.alpha)
	for i = 1, #self.rects do
		local rect = self.rects[i]
		love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h)
	end
	love.graphics.rectangle("fill", g.skin.navbar.x + g.skin.navbar.w - g.skin.navbar.border, g.skin.navbar.y, g.skin.navbar.border, g.skin.navbar.h)
end

function navbar:mousepressed(x, y, b)
	for i = 1, #self.buttons do
		self.buttons[i]:mousepressed(x, y, b)
	end
end

function navbar:mousereleased(x, y, b)
	for i = 1, #self.buttons do
		self.buttons[i]:mousereleased(x, y, b)
	end
end

return navbar