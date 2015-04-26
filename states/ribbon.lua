local ribbon = {}
ribbon.name = "Ribbon"

function ribbon:init()
	self.__z = 2
	self.timer = g.timer.new()
	self.colors = { g.skin.black, g.skin.white, g.skin.red } -- First is bg, 2nd is text, 3rd is dark color
	self.header = { text = "ribbon"; x = g.skin.ribbon.x + g.skin.padding; y = g.skin.ribbon.y + ((g.skin.ribbon.h-g.skin.ribbon.border)/2 - g.font.height(g.skin.ribbon.font)/2)}
	self.logo = nil
	self.large_logo = nil
	self.tween = { ox = 0; oy = 0; alpha = 1; }
	--
	g.console:log("ribbon:init")
end

function ribbon:added()

end

function ribbon:update(dt)
	self.timer.update(dt)
end

function ribbon:draw()
	love.graphics.setScissor(g.skin.ribbon.x, g.skin.ribbon.y, g.skin.ribbon.w, g.skin.ribbon.h - g.skin.ribbon.border)
	--
	love.graphics.setColor(self.colors[1])
	love.graphics.rectangle("fill", g.skin.ribbon.x, g.skin.ribbon.y, g.skin.ribbon.w, g.skin.ribbon.h - g.skin.ribbon.border)
	--
	if self.header.text~="" then
		g.font.set(g.skin.ribbon.font)
		love.graphics.setColorAlpha(self.colors[3], 255 * self.tween.alpha)
		love.graphics.print(self.header.text, self.header.x + g.skin.ribbon.shadow_x + self.tween.ox, self.header.y + g.skin.ribbon.shadow_y + self.tween.oy)
		love.graphics.setColorAlpha(self.colors[2], 255 * self.tween.alpha)
		love.graphics.print(self.header.text, self.header.x + self.tween.ox, self.header.y + self.tween.oy)
	end
	--
	if self.logo then
		love.graphics.setColor(255, 255, 255, g.skin.ribbon.large_logo_alpha * self.tween.alpha)
		g.image.draw(self.large_logo, self.tween.ox, self.tween.oy)
		love.graphics.setColor(255, 255, 255, 255 * self.tween.alpha)
		g.image.draw(self.logo, self.tween.ox, self.tween.oy)
	end
	--
	love.graphics.setScissor()
	love.graphics.setColor(self.colors[3])
	love.graphics.rectangle("fill", g.skin.ribbon.x, g.skin.ribbon.y + g.skin.ribbon.h - g.skin.ribbon.border, g.skin.ribbon.w, g.skin.ribbon.border)
end

-- functions

function ribbon:set_image(path)
	if path==nil then self.logo = nil; self.large_logo = nil; return end
	path = "assets/images/" .. path
	self.logo = g.image.new(path)
	self.large_logo = g.image.new(path)
	self:set_positions()
end

function ribbon:set_header(text)
	self.header.text = text or ""
	self:set_positions()
end

function ribbon:set_colors(c1, c2, c3)
	self.colors[1] = c1 or self.colors[1]
	self.colors[2] = c2 or self.colors[2]
	self.colors[3] = c3 or self.colors[3]
end

function ribbon:set_positions()
	if self.logo then
		g.image.set_size(self.logo, 64, 64)
		self.large_logo.x, self.large_logo.y = g.skin.ribbon.x + g.skin.margin, g.skin.ribbon.y + (g.skin.ribbon.h/2 - self.large_logo.w/2)
		self.logo.x, self.logo.y = self.large_logo.x + (self.large_logo.w/2 - self.logo.w/2), self.large_logo.y + (self.large_logo.h/2 - self.logo.h/2)
		--
		self.header.x = self.large_logo.x + self.large_logo.w + g.skin.margin
	else
		self.header.x = g.skin.ribbon.x + g.skin.margin
	end
end

function ribbon:start_tween()
	self.tween = { ox = g.skin.ribbon.tween_ox; oy = g.skin.ribbon.tween_oy; alpha = g.skin.ribbon.tween_alpha; }
	self.timer.tween(g.skin.ribbon.tween_time, self.tween, { ox = 0; oy = 0; alpha = 1; }, g.skin.ribbon.tween_type)
end

-- useful multi-funcs

function ribbon:set_team(team)
	self:set_image("logos/128/"..team.id..".png")
	self:set_header(team.long_name)
	self:set_colors(team.color_1, team.color_2, team.color_3)
	--
	self:set_positions()
	self:start_tween()
	g.console:print("Ribbon set to team " .. team.short_name .. " (ID:" .. team.id .. ")", g.skin.green)
end

function ribbon:reset()
	self:set_image()
	self:set_header()
	self:set_colors(g.skin.black, g.skin.white, g.skin.blue)
	--
	self:set_positions()
end

return ribbon