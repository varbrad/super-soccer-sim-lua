local ui = {}
ui.mx, ui.my = -1, -1

ui.button = {}
ui.button.__index = ui.button
ui.button.__type = "UI-Button"

--

function ui.set_mouse_position(mx, my)
	ui.mx, ui.my = mx, my
end

-- Default values
ui.button.__defaultMargin = 8
ui.button.__defaultWidth = 140
ui.button.__defaultHeight = 30
ui.button.__defaultColor1 = {66, 66, 66, 255}
ui.button.__defaultColor2 = {255, 255, 255, 255}
ui.button.__defaultColor3 = {56, 56, 56, 255}
ui.button.__defaultFont = love.graphics.newFont(12)

local function roundrect(mode,x,y,w,h,tl,tr,bl,br)
	tr = tr or tl
	bl = bl or tl
	br = br or tl
	local r = tl
	local g = love.graphics
	x = math.floor(x+.5)
	y = math.floor(y+.5)
	w = math.floor(w+.5)
	h = math.floor(h+.5)
	r = math.floor(r+.5)
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

-- Static constructors
function ui.button.new(text, x, y, settings)
	local b = {}
	setmetatable(b, ui.button)
	b.text = text or ""
	b.x, b.y = x or 0, y or 0
	if settings then
		b.w = settings.w or ui.button.__defaultWidth
		b.h = settings.h or ui.button.__defaultHeight
		b.on_enter = settings.on_enter or nil
		b.on_exit = settings.on_exit or nil
		b.on_click = settings.on_click or nil
		b.on_release = settings.on_release or nil
		b.clickable = settings.clickable or true
		b.image = settings.image or nil
	end
	--
	b.visible, b.enabled = true, true
	b.is_mousepressed = false
	b.color1, b.color2, b.color3 = ui.button.__defaultColor1, ui.button.__defaultColor2, ui.button.__defaultColor3
	b.font = ui.button.__defaultFont
	b.tw = b.font:getWidth(b.text)
	b.tx, b.ty = 0, b.h/2 - b.font:getHeight()/2 - 1
	b.ix, b.iy = ui.button.__defaultMargin, 0
	if b.image then
		b.iy = b.h/2 - b.image.h/2 - 1
	end
	if b.w == "auto" then
		b.__auto = true
		b.w = b.tw + ui.button.__defaultMargin * 2
		if b.image then
			b.w = b.w + b.image.w + ui.button.__defaultMargin
		end
	end
	b.hover = false
	return b
end

function ui.button:reset()
	self:set_image()
	self:set_text()
	self:set_events() -- Nil all events
	self:set_colors(ui.button.__defaultColor1, ui.button.__defaultColor2, ui.button.__defaultColor3)
	self.hover, self.is_mousepressed = false, false
	self.visible, self.enabled, self.clickable = true, true, true
end

function ui.button:set_image(image)
	-- Image must be a Image class object, not the native Love2D image!
	self.image = image
	if self.image then
		self.iy = self.h/2 - self.image.h/2 - 1
	end
	if self.__auto then
		self.w = self.tw + ui.button.__defaultMargin * 2
		if self.image then
			self.w = self.w + self.image.w + ui.button.__defaultMargin
		end
	end
end

function ui.button:set_colors(c1, c2, c3)
	self.color1, self.color2, self.color3 = c1 or self.color1, c2 or self.color2, c3 or self.color3
end

function ui.button:set_text(text)
	self.text = text or ""
	self.tw = self.font:getWidth(self.text)
	if self.__auto then
		self.w = self.tw + ui.button.__defaultMargin * 2
		if self.image then
			self.w = self.w + self.image.w + ui.button.__defaultMargin
			self.tx = ui.button.__defaultMargin * 2 + self.image.w
		end
	end
end

function ui.button:set_events(on_enter, on_exit, on_click, on_release)
	self.on_enter, self.on_exit, self.on_click, self.on_release = on_enter, on_exit, on_click, on_release
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
	local x, y = self.x + ox, self.y + oy
	local dy = 0
	if self.is_mousepressed and self.hover then
		dy = 2
	elseif self.hover then
		dy = 1
	end
	setColorAlpha(self.color3, 255 * alpha)
	roundrect("fill", x, y + dy, self.w, self.h - dy, 5, 5, 5, 5)
	setColorAlpha(self.color1, 255 * alpha)
	roundrect("fill", x+1, y+1+dy, self.w-2, self.h-4-dy, 5, 5, 0, 0)
	setColorAlpha(self.color2, 255 * alpha)
	love.graphics.setFont(self.font)
	love.graphics.printf(self.text, x + self.tx, y + self.ty + dy, self.tw, "center")
	setColorAlpha(g.skin.white, 255 * alpha)
	g.image.draw(self.image, x + self.ix, y + self.iy + dy)
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

setmetatable(ui.button, {_call = function(_,...) return ui.button.new(...) end})

return ui