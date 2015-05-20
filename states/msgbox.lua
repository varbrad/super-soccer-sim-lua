local msgbox = {}
msgbox.name = "MsgBox"
msgbox.active = false

function msgbox:init()
	self.__z = 7
	self.flux = g.flux:group()
	self.skin = g.skin.notification
	--
	g.console:log("notification:init")
end

function msgbox:added()

end

function msgbox:new(title, text, options)
	self.active = true
	local box = { w = g.width / 3, h = g.height / 3, color = g.skin.bars.color2, label_color = g.skin.colors[1], alpha = 255, rounded = g.skin.rounded }
	box.x, box.y = math.floor(g.width/2 - box.w/2 + .5), math.floor(g.height/2 - box.h/2 + .5)
	--
	local header_rect = { x = g.skin.margin, y = g.skin.margin, w = box.w - g.skin.margin * 2, h = g.skin.bars.h, color = g.skin.colors[1], alpha = 255, rounded = g.skin.rounded }
	local header_label = { text = title, x = header_rect.x, y = header_rect.y + g.skin.bars.ty, w = header_rect.w, align = "center", font = g.skin.bars.font[1], color = g.skin.bars.color2 }
	local content = { text = text, x = header_rect.x, y = header_rect.y + header_rect.h + g.skin.margin, w = header_rect.w, align = "justify", font = g.skin.bars.font[3] }
	--
	box.labels = { header_label, content }
	box.rects = { header_rect }
	--
	self.box = box
end

function msgbox:clear()
	self.active = false
	self.box = nil
end

function msgbox:update(dt)

end

function msgbox:draw()
	if not self.active then return end
	love.graphics.setColor(0, 0, 0, 190)
	love.graphics.rectangle("fill", 0, 0, g.width, g.height)
	--
	g.components.bar_draw.draw(self.box)
end

return msgbox