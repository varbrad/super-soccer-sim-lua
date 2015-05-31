local notification = {}
notification.name = "Notification"

function notification:init()
	self.__z = 8
	self.flux = g.flux:group()
	self.skin = g.skin.notification
	self.list = {}
	--
	g.console:log("notification:init")
end

function notification:added()

end

function notification:new(text, image)
	--
	for i=1, #self.list do
		local item = self.list[i]
		item.tx = item.tx + self.skin.dx
		item.ty = item.ty + self.skin.dy
		self.flux:to(item, g.skin.tween.time, { x = item.tx, y = item.ty }):ease(g.skin.tween.type)
	end
	--
	local item = { tx = self.skin.x, ty = self.skin.y, w = self.skin.w, h = self.skin.h, color = self.skin.color1, alpha = self.skin.alpha - self.skin.dalpha, rounded = g.skin.rounded }
	item.x, item.y = item.tx - self.skin.dx, item.ty - self.skin.dy
	local label = { text = text or "", w = item.w - g.skin.margin * 3 - self.skin.img_size, align = "center", x = g.skin.margin * 2 + self.skin.img_size, color = {255, 255, 255}, alpha = 255, font = self.skin.font[1] }
	local mult = 1
	for i in string.gfind(label.text, "\n") do mult = mult + 1 end
	label.y = math.floor(item.h/2 - (g.font.height(label.font)*mult)/2 + .5)
	item.labels = {label}
	if image then
		if type(image)=="string" then
			image = g.image.new("icons/"..image..".png", {mipmap=true})
		end
		--image:resize(self.skin.img_size, self.skin.img_size)
		image:constrain_w(self.skin.img_size)
		image.x, image.y = g.skin.img_margin, g.skin.img_margin + math.floor(self.skin.img_size/2 - image.h/2 + .5)
		image.alpha = self.skin.alpha
		item.images = {image}
	end
	-- Begin tween
	local tween = self.flux:to(item, g.skin.tween.time, { x = self.skin.x, y = self.skin.y, alpha = self.skin.alpha }):ease(g.skin.tween.type)
					:after(item, g.skin.tween.time, { x = self.skin.x + self.skin.w, alpha = 0 }):ease(g.skin.tween.type):delay(g.skin.tween.delay)
					:oncomplete(function() table.remove(self.list, 1) end)
	table.insert(self.list, item)
end

function notification:update(dt)
	self.flux:update(dt)
end

function notification:draw()
	for i=1, #self.list do
		local item = self.list[i]
		g.components.bar_draw.draw(item)
	end
end

return notification