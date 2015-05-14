local settings = {}
settings.name = "settings"

function settings:init()
	self.__z = 1
	--
	g.console:log("settings:init")
end

function settings:added()
	self.panel = g.ui.panel.new(g.skin.tab, g.skin.tab, g.width - g.skin.tab * 2, g.height - g.skin.tab * 2)
	self.panel:set_colors(g.skin.components.color1, g.skin.components.color3)
	self.bars, self.buttons = {}, {}
	--
	local header = { x = self.panel.x + g.skin.margin, y = self.panel.y + g.skin.margin, w = self.panel.w - g.skin.margin * 2, h = g.skin.bars.h * 3, color = g.skin.colors[1], alpha = g.skin.bars.alpha }
	local label = { text = "Settings", x = 0, w = header.w, align = "center", font = g.skin.header, color = g.skin.bars.color2 }
	label.h = g.font.height(label.font)
	label.y = math.floor(header.h/2 - label.h/2 + .5)
	header.labels = { label }
	table.insert(self.bars, header)

	--
	-- Add back button at bottom left
	local btn = g.ui.button.new("Back")
	btn.x, btn.y = self.panel.x + g.skin.margin, self.panel.y + self.panel.h - btn.h - g.skin.margin
	btn:set_colors(g.skin.red, g.skin.black, love.graphics.darken(g.skin.red))
	btn.on_release = function(b)
		g.state.switch(g.states.overview)
	end
	table.insert(self.buttons, btn)
end

function settings:update(dt)
	for i=1, #self.buttons do self.buttons[i]:update(dt) end
end

function settings:draw()
	self.panel:draw()
	for i=1, #self.bars do
		g.components.bar_draw.draw(self.bars[i])
	end
	for i=1, #self.buttons do self.buttons[i]:draw() end
end

function settings:mousepressed(x, y, b)
	for i=1, #self.buttons do self.buttons[i]:mousepressed(x, y, b) end
end

function settings:mousereleased(x, y, b)
	for i=1, #self.buttons do self.buttons[i]:mousereleased(x, y, b) end
end

return settings