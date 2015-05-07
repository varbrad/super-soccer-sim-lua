local ui = 1
local textbox = {}
textbox.__index = textbox
textbox.__type = "textbox"

textbox.__defaultWidth = 120
textbox.__defaultHeight = 34

function textbox.init(ui_ref)
	ui = ui_ref
end

function textbox.new(settings)
	local b = {}
	setmetatable(b, textbox)
	b.__settings = settings
	b:reset(settings)
	return b
end

function textbox:reset(settings)
	settings = settings or self.__settings or {}
	if settings.visible==nil then settings.visible=true end
	if settings.enabled==nil then settings.enabled=true end
	self.x, self.y = settings.x or self.x or 0, settings.y or self.y or 0
	self.x, self.y = math.floor(self.x + .5), math.floor(self.y + .5)
	self.w = settings.w or self.w or textbox.__defaultWidth
	self.h = settings.h or self.h or textbox.__defaultHeight
	self.visible, self.enabled = settings.visible, settings.enabled
	self.hover, self.is_mousepressed = false, false
	self:set_colors(settings.color1 or ui.__defaultColor1,
					settings.color2 or ui.__defaultColor2,
					settings.color3 or ui.__defaultColor3)
	self.fonts = settings.fonts or self.fonts or ui.__defaultFont
	self.ty = math.floor(self.h/2 - self.fonts[1]:getHeight()/2 + .5)
	self.rounded = math.floor(self.h/2 - 1.5)
	local iy = math.floor(self.h/2 - 8 + .5)
	self.image = g.image.new("misc/search.png", {mipmap=true, w = 16, h = 16, x = self.x + iy, y = self.y + iy })
	self.underline = settings.underline or false
	self.text = "Search"
end

function textbox:set_colors(c1, c2, c3)
	self.color1 = c1 or ui.__defaultColor1
	self.color2 = c2 or ui.__defaultColor2
	self.color3 = c3 or ui.__defaultColor3
end

function textbox:set_text(text)
	self.text = text or ""
end

function textbox:set_events(enter, exit, click, release)
	self.on_enter, self.on_exit, self.on_click, self.on_release = enter, exit, click, release
end

function textbox:update(dt)
	if not self.enabled then return end
	if not self.hover and ui.mx >= self.x and ui.my >= self.y and ui.mx < self.x + self.w and ui.my < self.y + self.h then
		self.hover = true
		if self.on_enter then self.on_enter(self) end
	elseif self.hover and (ui.mx < self.x or ui.my < self.y or ui.mx >= self.x + self.w or ui.my >= self.y + self.h) then
		self.hover = false
		if self.on_exit then self.on_exit(self) end
	end
end

function textbox:draw(ox, oy, alpha)
	if not self.visible then return end
	ox, oy, alpha = ox or 0, oy or 0, alpha or 1
	local x, y = self.x + ox, self.y + oy
	--love.graphics.setScissor(x, y, self.w, self.h)
	local c = {self.color3, self.color1, self.color3}
	if self.hover then
		c[1], c[2], c[3] = self.color2, self.color3, self.color2
	end
	ui.setColorAlpha(c[1], 255 * alpha)
	ui.roundrect("fill", x, y, self.w, self.h, self.rounded)
	ui.setColorAlpha(c[2], 255 * alpha)
	ui.roundrect("fill", x+2, y+2, self.w-4, self.h-4, self.rounded)
	ui.setColorAlpha(c[3], 255 * alpha)
	local a = 1
	if self.hover then a = 2 end
	love.graphics.setFont(self.fonts[a])
	self.image:draw(ox, oy)
	love.graphics.print(self.text, self.image.x + self.image.w + g.skin.margin, y + self.ty)
	--love.graphics.setScissor()
end

function textbox:mousepressed(x, y, b)
	if not self.enabled then return end
	if self.hover then
		self.is_mousepressed = true
		if self.on_click then self.on_click(self) end
	else
		self.is_mousepressed = false
	end
end

function textbox:mousereleased(x, y, b)
	if not self.enabled then return end
	if self.hover and self.is_mousepressed then
		if self.on_release then self.on_release(self) end
	end
	self.is_mousepressed = false
end

setmetatable(textbox, {_call = function(_, ...) return textbox.new(...) end})

return textbox