local ui = 1
local textbox = {}
local utf8 = require "utf8"
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
	b.flux = g.flux:group()
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
	self.hover, self.focus = false, false
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
	self.tween_color = {self.color3[1], self.color3[2], self.color3[3]}
end

function textbox:update(dt)
	self.flux:update(dt)
	if not self.enabled then return end
	if not self.hover and ui.mx >= self.x and ui.my >= self.y and ui.mx < self.x + self.w and ui.my < self.y + self.h then
		self.hover = true
	elseif self.hover and (ui.mx < self.x or ui.my < self.y or ui.mx >= self.x + self.w or ui.my >= self.y + self.h) then
		self.hover = false
	end
end

function textbox:draw(ox, oy, alpha)
	if not self.visible then return end
	ox, oy, alpha = ox or 0, oy or 0, alpha or 1
	local x, y = self.x + ox, self.y + oy
	love.graphics.setScissor(x, y, self.w, self.h)
	local c = {self.color1, self.color2, self.color3}
	ui.setColorAlpha(c[3], 255 * alpha)
	ui.roundrect("fill", x, y, self.w, self.h, self.rounded)
	ui.setColorAlpha(c[1], 255 * alpha)
	ui.roundrect("fill", x+2, y+2, self.w-4, self.h-4, self.rounded)
	local f, color = self.fonts[1], c[3]
	if self.focus then f, color = self.fonts[2], c[2] end
	ui.setColorAlpha(self.tween_color, 255 * alpha)
	love.graphics.setFont(f)
	self.image:draw(ox, oy)
	love.graphics.print(self.text..(self.focus and "_" or ""), self.image.x + self.image.w + g.skin.margin, y + self.ty)
	love.graphics.setScissor()
end

function textbox:mousepressed(x, y, b)
	if not self.enabled then return end
	if self.hover and not self.focus then
		self.focus = true
		self.text = ""
		self.flux:to(self.tween_color, g.skin.tween.time, { self.color2[1], self.color2[2], self.color2[3] }):ease(g.skin.tween.type)
	elseif not self.hover and self.focus then
		self.focus = false
		self.text = "Search"
		self.flux:to(self.tween_color, g.skin.tween.time, { self.color3[1], self.color3[2], self.color3[3] }):ease(g.skin.tween.type)
	end
end

function textbox:keypressed(k, ir)
	if not self.focus then return end
	if k=="backspace" and self.text~="" then
		local byte_offset = utf8.offset(self.text, -1)
		if byte_offset then
			self.text = string.sub(self.text, 1, byte_offset - 1)
		end
	elseif k=="escape" then
		self.focus = false
		self.text = "Search"
	end
end

function textbox:textinput(t)
	if not self.focus then return end
	self.text = self.text .. t
end

setmetatable(textbox, {_call = function(_, ...) return textbox.new(...) end})

return textbox