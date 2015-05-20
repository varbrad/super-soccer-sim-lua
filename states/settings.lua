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
	local half_w = math.floor((header.w-g.skin.margin)/2 + .5)
	--
	local screenshot_format = { x = header.x, y = header.x + header.h + g.skin.margin, w = half_w, h = g.skin.bars.h, color = g.skin.bars.color1, label_color = g.skin.bars.color2, alpha = g.skin.bars.alpha }
	screenshot_format.labels = {
		{ text = "Saved Screenshot Format", x = g.skin.margin, y = g.skin.bars.ty, font = g.skin.bars.font[2]}
	}
	local jpg_button = g.ui.button.new(".jpg (faster to save)", { w = "auto", h = g.skin.bars.h - g.skin.margin * 2, y = screenshot_format.y + g.skin.margin})
	local png_button = g.ui.button.new(".png (higher quality)", { w = "auto", h = g.skin.bars.h - g.skin.margin * 2, y = screenshot_format.y + g.skin.margin})
	jpg_button.x = screenshot_format.x + screenshot_format.w - g.skin.margin * 2 - png_button.w - jpg_button.w
	png_button.x = jpg_button.x + jpg_button.w + g.skin.margin
	if g.settings.screenshot_format=="jpg" then jpg_button:set_colors(g.skin.red, g.skin.blue, g.skin.green) end
	if g.settings.screenshot_format=="png" then png_button:set_colors(g.skin.red, g.skin.blue, g.skin.green) end
	png_button.on_release = function(b) g.settings.screenshot_format = "png"; g.state.refresh_all() end
	jpg_button.on_release = function(b) g.settings.screenshot_format = "jpg"; g.state.refresh_all() end
	table.insert(self.buttons, jpg_button)
	table.insert(self.buttons, png_button)
	--
	table.insert(self.bars, screenshot_format)
	--
	-- Add back button at bottom left
	local btn = g.ui.button.new("Back")
	btn.x, btn.y = self.panel.x + g.skin.margin, self.panel.y + self.panel.h - btn.h - g.skin.margin
	btn:set_colors(g.skin.red, g.skin.black, love.graphics.darken(g.skin.red))
	btn.on_release = function(b)
		g.settings.save()
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

function settings:keypressed(k, ir)
	if k=="escape" then
		g.state.switch(g.states.overview)
	end
end

function settings:mousepressed(x, y, b)
	for i=1, #self.buttons do self.buttons[i]:mousepressed(x, y, b) end
end

function settings:mousereleased(x, y, b)
	for i=1, #self.buttons do self.buttons[i]:mousereleased(x, y, b) end
end

return settings