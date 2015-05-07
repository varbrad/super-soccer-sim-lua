local ribbon = {}
ribbon.name = "Ribbon"

function ribbon:init()
	self.__z = 2
	self.timer = g.timer.new()
	self.colors = { g.skin.black, g.skin.white, g.skin.red } -- First is bg, 2nd is text, 3rd is dark color
	self.gradient = love.graphics.gradient({{220,220,220},{255,255,255}, direction = "h"})
	self.gradient_w, self.gradient_h = g.skin.ribbon.w / self.gradient:getWidth(), (g.skin.ribbon.h - g.skin.ribbon.border) / self.gradient:getHeight()
	self.header = { text = "ribbon"; x = g.skin.ribbon.x + g.skin.padding; y = g.skin.ribbon.y + ((g.skin.ribbon.h-g.skin.ribbon.border)/2 - g.font.height(g.skin.ribbon.font[1])/2)}
	self.logo = nil
	self.large_logo = nil
	self.tween = { ox = 0; oy = 0; alpha = 1; }
	self.infobox = g.ui.button.new()
	self.searchbox = g.ui.textbox.new({ w = 400, h = g.skin.ribbon.h - g.skin.padding * 4, fonts = {g.font.get("italic", 14), g.font.get("regular", 14) }})
	self.searchbox.x = g.skin.ribbon.x + g.skin.ribbon.w - g.skin.margin * 2 - 200 - 400 -- 200 - the width of the textbox
	self.searchbox.y = g.skin.ribbon.y + math.floor(g.skin.ribbon.h/2 - self.searchbox.h/2 + .5)
	--
	self.active_screen_type = nil
	--
	g.console:log("ribbon:init")
end

function ribbon:added()

end

function ribbon:update(dt)
	self.timer.update(dt)
	self.infobox:update(dt)
	self.searchbox:update(dt)
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
		g.font.set(g.skin.ribbon.font[1])
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
	self.infobox:draw(self.tween.ox, self.tween.oy, self.tween.alpha)
	self.searchbox:draw(self.tween.ox, self.tween.oy, self.tween.alpha)
	--
	love.graphics.setColorAlpha(self.colors[2], 255 * self.tween.alpha)
	g.font.set(g.skin.ribbon.font[2])
	love.graphics.printf("Season: " .. g.vars.season .. "/" .. (g.vars.season + 1) .."\nWeek: " .. g.vars.week, g.skin.ribbon.x + g.skin.ribbon.w - g.skin.margin - 200, g.skin.ribbon.y + g.skin.margin, 200, "right")
	--
	love.graphics.setScissor()
	love.graphics.setColor(self.colors[3])
	love.graphics.rectangle("fill", g.skin.ribbon.x, g.skin.ribbon.y + g.skin.ribbon.h - g.skin.ribbon.border, g.skin.ribbon.w, g.skin.ribbon.border)
end

function ribbon:mousepressed(x, y, b)
	self.infobox:mousepressed(x, y, b)
end

function ribbon:mousereleased(x, y, b)
	self.infobox:mousereleased(x, y, b)
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
	self.infobox:set_colors(c1, c2, c3)
end

function ribbon:set_infobox(text, settings)
	self.infobox:reset(text, settings)
end

function ribbon:set_searchbox(settings)
	self.searchbox:reset(settings)
end

function ribbon:set_positions()
	if self.logo then
		self.logo:resize(64, 64)
		self.large_logo.x, self.large_logo.y = g.skin.ribbon.x + g.skin.margin, g.skin.ribbon.y + (g.skin.ribbon.h/2 - self.large_logo.w/2)
		self.logo.x, self.logo.y = self.large_logo.x + (self.large_logo.w/2 - self.logo.w/2), self.large_logo.y + (self.large_logo.h/2 - self.logo.h/2)
		--
		self.header.x = self.large_logo.x + self.large_logo.w + g.skin.margin
	else
		self.header.x = g.skin.ribbon.x + g.skin.margin
	end
	self.infobox.x = self.header.x + g.font.width(self.header.text, g.skin.ribbon.font[1]) + g.skin.tab
	self.infobox.y = (g.skin.ribbon.h-g.skin.ribbon.border)/2 - self.infobox.h/2
end

function ribbon:start_tween()
	self.tween = { ox = g.skin.ribbon.tween_ox; oy = g.skin.ribbon.tween_oy; alpha = g.skin.ribbon.tween_alpha; }
	self.timer.tween(g.skin.ribbon.tween_time, self.tween, { ox = 0; oy = 0; alpha = 1; }, g.skin.ribbon.tween_type)
end

-- Sets active screentypes

function ribbon:set_league(league)
	self.active_screen_type = "league"
	--
	self:reset()
	self:set_image("logos/128/"..league.flag..league.level..".png")
	self:set_header(league.long_name)
	self:set_colors(league.color1, league.color2, league.color3)
	local ib = {}
	ib.w = "auto"
	ib.enabled = false
	ib.image = g.image.new("flags/"..league.flag..".png")
	ib.color1, ib.color2, ib.color3 = league.color1, league.color2, league.color3
	self:set_infobox("", ib)
	local sb = {}
	sb.color1, sb.color2, sb.color3 = league.color1, league.color2, league.color3
	self:set_searchbox(sb)
	self:set_positions()
	self:start_tween()
end

function ribbon:set_team(team)
	self.active_screen_type = "team"
	--
	self:reset()
	self:set_image("logos/128/"..team.id..".png")
	self:set_header(team.long_name)
	self:set_colors(team.color1, team.color2, team.color3)
	local btn_settings = {}
	btn_settings.w = "auto"
	btn_settings.color1 = team.color1
	btn_settings.color2 = team.color2
	btn_settings.color3 = team.color3
	btn_settings.image = g.image.new("logos/128/"..team.league.flag..team.league.level..".png", {mipmap=true, w=26, h=26})
	btn_settings.underline = true
	btn_settings.on_release = function() g.vars.view.league_id = team.league_id; g.state.switch(g.states.league_overview) end
	self:set_infobox(g.db_manager.format_position(team.season.stats.pos) .. " in " .. team.league.long_name, btn_settings)
	local sb = {}
	sb.color1, sb.color2, sb.color3 = team.color1, team.color2, team.color3
	self:set_searchbox(sb)
	self:set_positions()
	self:start_tween()
end

function ribbon:reset()
	self:set_image()
	self:set_header()
	self:set_colors(g.skin.black, g.skin.white, g.skin.black)
	self.infobox:reset()
	self:set_positions()
end

return ribbon