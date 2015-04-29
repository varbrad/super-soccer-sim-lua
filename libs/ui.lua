local ui = {}
ui.mx, ui.my = -1, -1

ui.button = {}
ui.button.__index = ui.button
ui.button.__type = "UI.Button"

-- Some local functions
local function roundrect(mode, x, y, w, h, tl, tr, bl, br)
	tr, bl, br = tr or tl, bl or tl, br or tl
	local r = tl
	local g = love.graphics
	x, y, h, r = math.floor(x+.5), math.floor(y+.5), math.floor(h+.5), math.floor(r+.5)
	-- Draw inner rect
	g.rectangle(mode,x+r,y+r,w-r*2,h-r*2)
	-- Draw left, right, top, bottom rects
	g.rectangle(mode,x,y+r,r,h-r*2)
	g.rectangle(mode,x+w-r,y+r,r,h-r*2)
	g.rectangle(mode,x+r,y,w-r*2,r)
	g.rectangle(mode,x+r,y+h-r,w-r*2,r)
	-- Draw arcs (top left, top right, bottom right, bottom left
	g.arc(mode,x+r,y+r,r,math.pi,math.pi*1.5)
	g.arc(mode,x+w-r,y+r,r,0,-math.pi*.5)
	g.arc(mode,x+w-r,y+h-r,r,0,math.pi*.5)
	g.arc(mode,x+r,y+h-r,r,math.pi*.5,math.pi)
end

local function setColorAlpha(c, a)
	love.graphics.setColor(c[1], c[2], c[3], a)
end

--

function ui.set_mouse_position(mx, my)
	ui.mx, ui.my = mx or -1, my or -1
end

--

ui.button.__defaultMargin = 8
ui.button.__defaultWidth = 120
ui.button.__defaultHeight = 34
ui.button.__defaultColor1 = {66, 66, 66}
ui.button.__defaultColor2 = {255, 255, 255}
ui.button.__defaultColor3 = {56, 56, 56}
ui.button.__defaultFont = love.graphics.newFont(12)

function ui.button.new(text, settings)
	local b = {}
	setmetatable(b, ui.button)
	b.__settings = settings
	b:reset(text, settings)
	return b
end

function ui.button:reset(text, settings)
	self:set_text(text)
	settings = settings or self.__settings or {}
	self.x, self.y = settings.x or 0, settings.y or 0
	self.w = settings.w or ui.button.__defaultWidth
	self.h = settings.h or ui.button.__defaultHeight
	self:set_image(settings.image)
	self:set_events(settings.on_enter, settings.on_exit, settings.on_click, settings.on_release)
	self.clickable = settings.clickable or true
	self.visible, self.enabled = true, true
	self.hover, self.is_mousepressed = false, false
	self:set_colors(settings.color1 or ui.button.__defaultColor1,
					settings.color2 or ui.button.__defaultColor2,
					settings.color3 or ui.button.__defaultColor3)
	self.font = settings.font or ui.button.__defaultFont
	self.underline = settings.underline or false
	--
	self:position()
end

function ui.button:set_image(image)
	self.image = image
end

function ui.button:set_colors(c1, c2, c3)
	self.color1 = c1 or ui.button.__defaultColor1
	self.color2 = c2 or ui.button.__defaultColor2
	self.color3 = c3 or ui.button.__defaultColor3
end

function ui.button:set_text(text)
	self.text = text or ""
end

function ui.button:set_events(enter, exit, click, release)

end

function ui.button:position()
	self.tw, self.th = self.font:getWidth(self.text), self.font:getHeight()
	self.tx, self.ty = ui.button.__defaultMargin, math.floor(self.h/2 - self.th/2 +.5) - 1
	self.ix, self.iy = ui.button.__defaultMargin, 0
	if self.w == "auto" then
		if self.image then
			self.w = self.__defaultMargin * 3 + self.image.w + self.tw
			self.iy = math.floor(self.h/2 - self.image.h/2 + .5) - 1
			self.tx = self.tx + self.image.w + ui.button.__defaultMargin
		else
			self.w = self.__defaultMargin * 2 + self.tw
		end
	else
		local _w = self.tw
		if self.image then
			self.iy = math.floor(self.h/2 - self.image.h/2 + .5) - 1
			self.tx = self.tx + self.image.w + ui.button.__defaultMargin
			_w = _w + self.image.w + ui.button.__defaultMargin
		end
		local _ox = math.floor(self.w/2 - _w/2 +.5) - ui.button.__defaultMargin/2
		self.ix, self.tx = self.ix + _ox, self.tx + _ox
	end
end

function ui.button:update(dt)
	if not self.enabled or not self.clickable then return end
	if not self.hover and ui.mx >= self.x and ui.my >= self.y and ui.mx < self.x + self.w and ui.my < self.y + self.h then
		self.hover = true
		if self.on_enter then self.on_enter(self) end
	elseif self.hover and (ui.mx < self.x or ui.my < self.y or ui.mx >= self.x + self.w or ui.my >= self.y + self.h) then
		self.hover = false
		if self.on_exit then self.on_exit(self) end
	end
end

function ui.button:draw(ox, oy, alpha)
	if not self.visible then return end
	local x, y, dy = self.x + ox, self.y + oy, 0
	love.graphics.setScissor(x, y + dy, self.w, self.h - dy)
	if self.is_mousepressed and self.hover then	dy = 2 elseif self.hover then dy = 1 end
	local c = {self.color3, self.color1, self.color2}
	if self.hover then
		c[1], c[2], c[3] = c[3], c[2], c[3]
	end
	setColorAlpha(c[1], 255 * alpha)
	roundrect("fill", x, y + dy, self.w, self.h - dy, 5, 5, 5, 5)
	setColorAlpha(c[2], 255 * alpha)
	roundrect("fill", x+1, y+1+dy, self.w-2, self.h-4-dy, 5, 5, 0, 0)
	setColorAlpha(c[3], 255 * alpha)
	love.graphics.setFont(self.font)
	love.graphics.print(self.text, x + self.tx, y + self.ty + dy)
	if self.hover and self.underline then
		love.graphics.rectangle("fill", x + self.tx, y + self.ty + self.th + dy, self.tw, 1)
	end
	setColorAlpha(g.skin.white, 255 * alpha)
	if self.image then g.image.draw(self.image, x + self.ix, y + self.iy + dy) end
	love.graphics.setScissor()
end

function ui.button:mousepressed(x, y, b)
	if self.hover then
		self.is_mousepressed = true
		if self.on_click then self.on_click(self) end
	else
		self.is_mousepressed = false
	end
end

function ui.button:mousereleased(x, y, b)
	if self.hover and self.is_mousepressed then
		if self.on_release then self.on_release(self) end
	end
	self.is_mousepressed = false
end

setmetatable(ui.button, {_call = function(_, ...) return ui.button.new(...) end})

return ui