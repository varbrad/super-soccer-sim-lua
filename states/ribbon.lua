local ribbon = {}
ribbon.name = "Ribbon"

function ribbon:init()
	self.__z = 2
	self.timer = g.timer.new()
	self.colors = { g.skin.black, g.skin.white, g.skin.red } -- First is bg, 2nd is text, 3rd is dark color
	self.gradient = love.graphics.gradient({{220,220,220},{255,255,255}, direction = "h"})
	self.gradient_w, self.gradient_h = g.skin.ribbon.w / self.gradient:getWidth(), (g.skin.ribbon.h - g.skin.ribbon.border) / self.gradient:getHeight()
	self.header = { text = "ribbon"; x = g.skin.ribbon.x + g.skin.padding; y = g.skin.ribbon.y + ((g.skin.ribbon.h-g.skin.ribbon.border)/2 - g.font.height(g.skin.ribbon.font)/2)}
	self.logo = nil
	self.large_logo = nil
	self.tween = { ox = 0; oy = 0; alpha = 1; }
	self.button = g.ui.button.new("League Position", g.skin.ribbon.x, g.skin.ribbon.y, {w="auto"})
	--
	g.console:log("ribbon:init")
	g.console:log(self.gradient)
end

function ribbon:added()

end

function ribbon:update(dt)
	self.timer.update(dt)
	self.button:update(dt)
end

function ribbon:draw()
	love.graphics.setScissor(g.skin.ribbon.x, g.skin.ribbon.y, g.skin.ribbon.w, g.skin.ribbon.h - g.skin.ribbon.border)
	--
	love.graphics.setColor(self.colors[1])
	love.graphics.rectangle("fill", g.skin.ribbon.x, g.skin.ribbon.y, g.skin.ribbon.w, g.skin.ribbon.h - g.skin.ribbon.border)
	--
	love.graphics.setBlendMode("multiplicative")
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.draw(self.gradient, g.skin.ribbon.x, g.skin.ribbon.y, 0, self.gradient_w, self.gradient_h)
	love.graphics.setBlendMode("alpha")
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
	self.button:draw(self.tween.ox, self.tween.oy, self.tween.alpha)
	--
	love.graphics.setScissor()
	love.graphics.setColor(self.colors[3])
	love.graphics.rectangle("fill", g.skin.ribbon.x, g.skin.ribbon.y + g.skin.ribbon.h - g.skin.ribbon.border, g.skin.ribbon.w, g.skin.ribbon.border)
end

-- functions

function ribbon:set_image(path)
	if path==nil then self.logo = nil; self.large_logo = nil; return end
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
	self.button:set_colors(c1, c2, c3)
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
	self.button.x = self.header.x + g.font.width(self.header.text, g.skin.ribbon.font) + g.skin.tab
	self.button.y = (g.skin.ribbon.h-g.skin.ribbon.border)/2 - self.button.h/2
end

function ribbon:start_tween()
	self.tween = { ox = g.skin.ribbon.tween_ox; oy = g.skin.ribbon.tween_oy; alpha = g.skin.ribbon.tween_alpha; }
	self.timer.tween(g.skin.ribbon.tween_time, self.tween, { ox = 0; oy = 0; alpha = 1; }, g.skin.ribbon.tween_type)
end

-- useful multi-funcs

function ribbon:set_team(team)
	self:set_image("logos/128/"..team.id..".png")
	self:set_header(team.long_name)
	self:set_colors(team.color1, team.color2, team.color3)
	self.button:set_text(team.league.long_name)
	--
	self:set_positions()
	self:start_tween()
	g.console:print("Ribbon set to team " .. team.short_name .. " (ID:" .. team.id .. ")", g.skin.green)
end

function ribbon:reset()
	self:set_image()
	self:set_header()
	self:set_colors(g.skin.black, g.skin.white, g.skin.black)
	--
	self:set_positions()
end

return ribbon