local overview = {}
overview.name = "Overview"

function overview:init()
	self.__z = 1
	--
	g.console:log("overview:init")
end

function overview:added()
	local w, h = g.width/2 - g.skin.tab * 2, g.height/2 - g.skin.tab * 2
	local x, y = math.floor(g.width/2 - w/2 + .5), math.floor(g.height/2 - h/2 + .5)
	self.panel = g.ui.panel.new(x, y, w, h)
	self.panel:set_colors(g.skin.components.color1, g.skin.components.color3)
	--
	g.in_game = false
	--
	self.buttons = {}
	local new_game =	g.ui.button.new("New Game", { x = self.panel.x + g.skin.margin, y = self.panel.y + g.skin.margin, w = self.panel.w - g.skin.margin * 2, h = (self.panel.h - g.skin.margin * 2)/4 })
	local load_game =	g.ui.button.new("Load Game", { x = new_game.x, y = new_game.y + new_game.h, w = new_game.w, h = new_game.h })
	local settings =	g.ui.button.new("Settings", { x = new_game.x, y = load_game.y + new_game.h, w = new_game.w, h = new_game.h })
	local exit =		g.ui.button.new("Exit Game", { x = new_game.x, y = settings.y + new_game.h, w = new_game.w, h = new_game.h })
	--
	new_game:set_colors(g.skin.bars.color1, g.skin.bars.color2, g.skin.bars.color3)
	load_game:set_colors(g.skin.bars.color1, g.skin.bars.color2, g.skin.bars.color3)
	settings:set_colors(g.skin.bars.color1, g.skin.bars.color2, g.skin.bars.color3)
	exit:set_colors(g.skin.black, g.skin.red, g.skin.black)
	--
	table.insert(self.buttons, new_game)
	table.insert(self.buttons, load_game)
	table.insert(self.buttons, settings)
	table.insert(self.buttons, exit)
	--
	new_game.on_release = function(btn)
		g.state.switch(g.states.database_select)
	end
	load_game.on_release = function(btn) 
		local loaded, err = g.database.load_game()
		if not loaded then g.notification:new(err, "alert") return end
		--
		g.state.pop()
		g.state.add(g.states.navbar)
		g.state.add(g.states.ribbon)
		g.state.add(g.states.club_overview)
		g.in_game = true
	end
	settings.on_release = function(btn)
		g.state.switch(g.states.settings)
	end
	exit.on_release = function(btn) love.event.quit() end
	--
	self.custom_buttons = {} -- What will be drawn (not used in update, mousepressed/released)
	for i=1, #self.buttons do
		local new, btn = {}, self.buttons[i]
		new.x, new.y, new.w, new.h = btn.x, btn.y, btn.w, btn.h
		new.color1, new.color2 = btn.color1, btn.color2
		new.alpha = g.skin.bars.alpha
		new.text, new.ty = btn.text, math.floor(btn.h/2 - g.font.height("bold", 48)/2 + .5)
		btn.on_enter = function(btn) new.color1 = btn.color2; new.color2 = btn.color3 end
		btn.on_exit = function(btn) new.color1 = btn.color1; new.color2 = btn.color2 end
		table.insert(self.custom_buttons, new)
	end
end

function overview:update(dt)
	for i=1, #self.buttons do self.buttons[i]:update(dt) end
end

function overview:draw()
	self.panel:draw()
	--for i=1, #self.buttons do self.buttons[i]:draw() end
	for i=1, #self.custom_buttons do
		local b = self.custom_buttons[i]
		love.graphics.setColorAlpha(b.color1, b.alpha)
		love.graphics.rectangle("fill", b.x, b.y, b.w, b.h)
		love.graphics.setColorAlpha(b.color2, 255)
		g.font.set("bold", 48)
		love.graphics.printf(b.text, b.x, b.y + b.ty, b.w, "center")
	end
end

function overview:keypressed(k, ir)
	if k=="escape" then love.event.quit(); return true end
end

function overview:mousepressed(x, y, b)
	for i=1, #self.buttons do self.buttons[i]:mousepressed(x, y, b) end
end

function overview:mousereleased(x, y, b)
	for i=1, #self.buttons do self.buttons[i]:mousereleased(x, y, b) end
end

return overview