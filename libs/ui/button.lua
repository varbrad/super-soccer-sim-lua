local ui = 1
local button = {}
button.__index = button
button.__type = "button"
button.active_hover = nil

button.__defaultWidth = 120
button.__defaultHeight = 34

function button.init(ui_ref)
	ui = ui_ref
end

function button.new(text, settings)
	local b = {}
	setmetatable(b, button)
	b.__settings = settings
	b:reset(text, settings)
	return b
end

function button:reset(text, settings)
	self:set_text(text)
	settings = settings or self.__settings or {}
	if settings.visible==nil then settings.visible=true end
	if settings.enabled==nil then settings.enabled=true end
	self.x, self.y = settings.x or 0, settings.y or 0
	self.x, self.y = math.floor(self.x + .5), math.floor(self.y + .5)
	self.w = settings.w or button.__defaultWidth
	self.h = settings.h or button.__defaultHeight
	self:set_image(settings.image)
	self:set_events(settings.on_enter, settings.on_exit, settings.on_click, settings.on_release)
	self.visible, self.enabled = settings.visible, settings.enabled
	self.hover, self.is_mousepressed = false, false
	self:set_colors(settings.color1 or ui.__defaultColor1,
					settings.color2 or ui.__defaultColor2,
					settings.color3 or ui.__defaultColor3)
	self.font = settings.font or ui.__defaultFont
	self.underline = settings.underline or false
	--
	self:position()
end

function button:set_image(image)
	self.image = image
end

function button:set_colors(c1, c2, c3)
	self.color1 = c1 or ui.__defaultColor1
	self.color2 = c2 or ui.__defaultColor2
	self.color3 = c3 or ui.__defaultColor3
end

function button:set_text(text)
	self.text = text or ""
end

function button:set_events(enter, exit, click, release)
	self.on_enter, self.on_exit, self.on_click, self.on_release = enter, exit, click, release
end

function button:position()
	self.tw, self.th = self.font:getWidth(self.text), self.font:getHeight()
	self.tx, self.ty = ui.__defaultMargin or 0, math.floor(self.h/2 - self.th/2 +.5) - 1
	self.ix, self.iy = ui.__defaultMargin, 0
	if self.w == "auto" then
		if self.image then
			self.w = ui.__defaultMargin * 3 + self.image.w + self.tw
			if self.text=="" then self.w = self.w - ui.__defaultMargin end
			self.iy = math.floor(self.h/2 - self.image.h/2 + .5) - 1
			self.tx = self.tx + self.image.w + ui.__defaultMargin
		else
			self.w = ui.__defaultMargin * 2 + self.tw
		end
	else
		local _w = self.tw
		if self.image then
			self.iy = math.floor(self.h/2 - self.image.h/2 + .5) - 1
			self.tx = self.tx + self.image.w + ui.__defaultMargin
			_w = _w + self.image.w + ui.__defaultMargin
		end
		local _ox = math.floor(self.w/2 - _w/2 +.5)
		self.ix, self.tx = self.ix + _ox - ui.__defaultMargin/2, self.tx + _ox - ui.__defaultMargin
	end
end

function button:update(dt)
	if not self.enabled then return end
	if self.hover and (ui.mx < self.x or ui.my < self.y or ui.mx >= self.x + self.w or ui.my >= self.y + self.h) then
		self.hover = false
		if self.on_exit then self.on_exit(self) end
	elseif ui.mx >= self.x and ui.my >= self.y and ui.mx < self.x + self.w and ui.my < self.y + self.h then
		if not self.hover then
			self.hover = true
			if self.on_enter then self.on_enter(self) end
		end
		button.active_hover = self
	end
end

function button:draw(ox, oy, alpha)
	if not self.visible then return end
	ox, oy, alpha = ox or 0, oy or 0, alpha or 1
	local x, y, dy = self.x + ox, self.y + oy, 0
	love.graphics.setScissor(x, y + dy, self.w, self.h - dy)
	if self.is_mousepressed and self.hover or not self.enabled then	dy = 2 elseif self.hover then dy = 1 end
	local c = {self.color3, self.color1, self.color2}
	if self.hover then
		c[1], c[2], c[3] = c[3], c[2], c[3]
	end
	ui.setColorAlpha(c[1], 255 * alpha)
	ui.roundrect("fill", x, y + dy, self.w, self.h - dy, ui.__defaultRounded)
	ui.setColorAlpha(c[2], 255 * alpha)
	ui.roundrect("fill", x+1, y+1+dy, self.w-2, self.h-4, ui.__defaultRounded)
	ui.setColorAlpha(c[3], 255 * alpha)
	love.graphics.setFont(self.font)
	love.graphics.print(self.text, x + self.tx, y + self.ty + dy)
	if self.hover and self.underline then
		love.graphics.rectangle("fill", x + self.tx, y + self.ty + self.th + dy, self.tw, 1)
	end
	love.graphics.setColor(255, 255, 255, 255 * alpha)
	if self.image then g.image.draw(self.image, x + self.ix, y + self.iy + dy) end
	love.graphics.setScissor()
end

function button:mousepressed(x, y, b)
	if not self.enabled or b~="l" then return end
	if self.hover then
		self.is_mousepressed = true
		if self.on_click then self.on_click(self) end
	else
		self.is_mousepressed = false
	end
end

function button:mousereleased(x, y, b)
	if not self.enabled or b~="l" then return end
	if self.hover and self.is_mousepressed then
		if self.on_release then self.on_release(self) end
	end
	self.is_mousepressed = false
end

setmetatable(button, {_call = function(_, ...) return button.new(...) end})

return button