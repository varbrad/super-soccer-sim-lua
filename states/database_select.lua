local database_select = {}
database_select.name = "Database Select"

function database_select:init()
	self.__z = 1
	--
	g.console:log("database_select:init")
end

function database_select:added()
	local x, y, w, h = g.skin.tab, g.skin.tab, g.width - g.skin.tab * 2, g.height - g.skin.tab * 2
	self.panel = g.ui.panel.new(x, y, w, h)
	self.panel:set_colors(g.skin.components.color1, g.skin.components.color3)
	--
	self:set()
end

function database_select:set()
	self.bars, self.buttons = {}, {}
	local files = g.database.find_database_files()
	for i=1, #files do
		local file = files[i]
		local btn = g.ui.button.new(file.name, { x = self.panel.x + g.skin.margin, y = self.panel.y + g.skin.margin })
		btn:set_colors(g.skin.components.color1, g.skin.components.color2, g.skin.components.color3)
		btn.y = btn.y + (i-1) * (btn.h + g.skin.margin)
		--
		btn.on_release = function(b)
			self:set_preview(b, file)
		end
		--
		table.insert(self.buttons, btn)
	end
end

function database_select:set_preview(button, file)
	-- sets the database.team, database.league and database.nation
	local success = g.database.get_preview(file)
	assert(success, "Something went wrong pre-loading the database!")
	--
	-- Should do some league validation here and such, before we process the database and move onto the next state
	--
	g.database.setup() -- Gives all objects their 'data' tables (Not needed if loading)
	g.database.process() -- Link up refs ( do for save game loading too!)
	g.state.switch(g.states.new_game)
end

function database_select:update(dt)
	for i=1, #self.buttons do self.buttons[i]:update(dt) end
end

function database_select:draw()
	self.panel:draw()
	for i=1, #self.bars do g.components.bar_draw.draw(self.bars[i]) end
	for i=1, #self.buttons do self.buttons[i]:draw() end
end

function database_select:keypressed(k, ir)
	if k=="escape" or k=="backspace" then g.state.switch(g.states.overview) end
end

function database_select:mousepressed(x, y, b)
	for i=1, #self.buttons do self.buttons[i]:mousepressed(x, y, b) end
end

function database_select:mousereleased(x, y, b)
	for i=1, #self.buttons do self.buttons[i]:mousereleased(x, y, b) end
end

return database_select