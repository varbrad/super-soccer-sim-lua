local settings = {}
settings.name = "settings"

function settings:init()
	self.__z = 1
	self.flux = g.flux:group()
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
	local graphics_bar = self:get_header_bar(header.x, header.y + header.h, half_w, g.skin.bars.h * 2, g.skin.colors[4], "Graphic Settings")
	table.insert(self.bars, graphics_bar)
	table.insert(self.bars, self:get_screenshot_format_bar(graphics_bar.x, graphics_bar.y + graphics_bar.h, graphics_bar.w, g.skin.bars.h, g.skin.bars.color1))
	table.insert(self.bars, self:get_background_cycle_bar(graphics_bar.x, graphics_bar.y + graphics_bar.h + g.skin.bars.h, graphics_bar.w, g.skin.bars.h, g.skin.bars.color3))
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
	self.flux:update(dt)
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
		return true
	end
end

function settings:mousepressed(x, y, b)
	for i=1, #self.buttons do self.buttons[i]:mousepressed(x, y, b) end
end

function settings:mousereleased(x, y, b)
	for i=1, #self.buttons do self.buttons[i]:mousereleased(x, y, b) end
end

function settings:get_header_bar(x, y, w, h, c, title)
	local bar = { x = x, y = y, w = w, h = h, color = c, label_color = g.skin.bars.color2, alpha = g.skin.bars.alpha }
	local text = { text = title, x = 0, w = bar.w, align = "center", font = {"bold", 24 } }
	text.y = math.floor(bar.h/2 - g.font.height(text.font)/2 + .5)
	bar.labels = { text }
	return bar
end

function settings:get_screenshot_format_bar(x, y, w, h, c)
	local bar = { x = x, y = y, w = w, h = h, color = c, label_color = g.skin.bars.color2, alpha = g.skin.bars.alpha }
	local title = { text = "Saved Screenshot Format", x = g.skin.margin, y = g.skin.bars.ty, font = g.skin.bars.font[1] }
	local jpg_label = { text = ".jpg (faster to save)", x = bar.w - 400, y = g.skin.bars.ty, w = 200, align = "center", font = g.skin.bars.font[2], color = nil }
	local png_label = { text = ".png (better quality)", x = bar.w - 200, y = g.skin.bars.ty, w = 200, align = "center", font = g.skin.bars.font[2], color = nil }
	--
	local jpg_button = g.ui.button.new("", { w = jpg_label.w, h = g.skin.bars.h, x = bar.x + jpg_label.x, y = bar.y })
	local png_button = g.ui.button.new("", { w = png_label.w, h = g.skin.bars.h, x = bar.x + png_label.x, y = bar.y })
	jpg_button.visible, png_button.visible = false, false
	--
	local rect = { y = 0, w = 200, h = g.skin.bars.h, color = g.skin.colors[3], alpha = g.skin.bars.alpha }
	--
	bar.rects = { rect }
	bar.labels = { title, jpg_label, png_label }
	--
	rect.x = g.settings.screenshot_format=="jpg" and jpg_label.x or png_label.x
	png_button.on_release = function(b)
		g.settings.screenshot_format = "png"
		self.flux:to(rect, g.skin.tween.time, { x = png_label.x }):ease(g.skin.tween.type)
	end
	jpg_button.on_release = function(b)
		g.settings.screenshot_format = "jpg"
		self.flux:to(rect, g.skin.tween.time, { x = jpg_label.x }):ease(g.skin.tween.type)
	end
	table.insert(self.buttons, jpg_button)
	table.insert(self.buttons, png_button)

	return bar
end

function settings:get_background_cycle_bar(x, y, w, h, c)
	local bar = { x = x, y = y, w = w, h = h, color = c, label_color = g.skin.bars.color2, alpha = g.skin.bars.alpha }
	local title = { text = "Background Cycling", x = g.skin.margin, y = g.skin.bars.ty, font = g.skin.bars.font[1] }
	local yes_label = { text = "ON", x = bar.w - 400, y = g.skin.bars.ty, w = 200, align = "center", font = g.skin.bars.font[2], color = nil }
	local no_label = { text = "OFF", x = bar.w - 200, y = g.skin.bars.ty, w = 200, align = "center", font = g.skin.bars.font[2], color = nil }
	--
	local yes_button = g.ui.button.new("", { w = yes_label.w, h = g.skin.bars.h, x = bar.x + yes_label.x, y = bar.y })
	local no_button = g.ui.button.new("", { w = no_label.w, h = g.skin.bars.h, x = bar.x + no_label.x, y = bar.y })
	yes_button.visible, no_button.visible = false, false
	--
	local rect = { y = 0, w = 200, h = g.skin.bars.h, color = g.skin.colors[3], alpha = g.skin.bars.alpha }
	--
	bar.rects = { rect }
	bar.labels = { title, yes_label, no_label }
	--
	rect.x = g.settings.background_cycle==true and yes_label.x or no_label.x
	no_button.on_release = function(b)
		g.settings.background_cycle = false
		g.states.background:stop_cycling()
		self.flux:to(rect, g.skin.tween.time, { x = no_label.x }):ease(g.skin.tween.type)
	end
	yes_button.on_release = function(b)
		g.settings.background_cycle = true
		g.states.background:start_cycling()
		self.flux:to(rect, g.skin.tween.time, { x = yes_label.x }):ease(g.skin.tween.type)
	end
	table.insert(self.buttons, yes_button)
	table.insert(self.buttons, no_button)

	return bar
end

function settings:get_currency_bar(x, y, w, h, c)

end

return settings