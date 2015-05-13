local ribbon = {}
ribbon.name = "Ribbon"

function ribbon:init()
	self.__z = 2
	self.flux = g.flux:group() --self.timer = g.timer.new()
	self.colors = { g.skin.black, g.skin.white, g.skin.red } -- First is bg, 2nd is text, 3rd is dark color
	self.gradient = love.graphics.gradient({{220,220,220},{255,255,255}, direction = "h"})
	self.gradient_w, self.gradient_h = g.skin.ribbon.w / self.gradient:getWidth(), (g.skin.ribbon.h - g.skin.ribbon.border) / self.gradient:getHeight()
	self.header = { text = "ribbon"; x = g.skin.ribbon.x + g.skin.padding; y = g.skin.ribbon.y + ((g.skin.ribbon.h-g.skin.ribbon.border)/2 - g.font.height(g.skin.ribbon.font[1])/2)}
	self.logo = nil
	self.large_logo = nil
	self.tween = { ox = 0; oy = 0; alpha = 1; }
	self.infobox = g.ui.button.new()
	self.searchbox = g.ui.textbox.new({ w = 200, h = g.skin.ribbon.h - g.skin.padding * 4, fonts = {g.font.get("italic", 14), g.font.get("regular", 14) }})
	self.searchbox.x = g.skin.ribbon.x + g.skin.ribbon.w - g.skin.margin * 2 - 200 - 200 - 200 -- 200 - the width of the textbox
	self.searchbox.y = g.skin.ribbon.y + math.floor(g.skin.ribbon.h/2 - self.searchbox.h/2 + .5)
	self.continue = g.ui.button.new("Continue", { x = g.skin.ribbon.x + g.skin.ribbon.w - 200, y = g.skin.ribbon.y, w = 200, h = g.skin.ribbon.h - g.skin.ribbon.border })
	self.continue:set_events(nil, nil, nil, g.continue_function)
	--
	self.active_screen_type = nil
	--
	g.console:log("ribbon:init")
end

function ribbon:added()

end

function ribbon:update(dt)
	self.flux:update(dt) --self.timer.update(dt)
	self.infobox:update(dt)
	self.searchbox:update(dt)
	self.continue:update(dt)
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
	self.searchbox:draw(0, 0, self.tween.alpha)
	--
	self.continue:draw(0, 0, self.tween.alpha)
	--
	love.graphics.setColorAlpha(self.colors[2], 255 * self.tween.alpha)
	g.font.set(g.skin.ribbon.font[2])
	love.graphics.printf("Season: " .. g.vars.season .. "/" .. (g.vars.season + 1) .."\nWeek: " .. g.vars.week, g.skin.ribbon.x + g.skin.ribbon.w - g.skin.margin - 400, g.skin.ribbon.y + g.skin.margin + 12, 200, "center")
	--
	love.graphics.setScissor()
	love.graphics.setColor(self.colors[3])
	love.graphics.rectangle("fill", g.skin.ribbon.x, g.skin.ribbon.y + g.skin.ribbon.h - g.skin.ribbon.border, g.skin.ribbon.w, g.skin.ribbon.border)
	--
	if self.searchbox.focus and self.search_list and self.searchbox.text~="" then
		local matches = #self.search_list
		if matches > 10 then matches = 10 end
		love.graphics.setColor(self.colors[3])
		love.graphics.rectangle("fill", self.searchbox.x, g.skin.ribbon.y + g.skin.ribbon.h - g.skin.ribbon.border, self.searchbox.w, matches * g.skin.small_bars.h + g.skin.ribbon.border)
		for i=1, matches do
			local c = { self.colors[1], self.colors[2] }
			if i==self.search_index then c[1], c[2] = c[2], c[1] end
			local x, y = self.searchbox.x + g.skin.ribbon.border, g.skin.ribbon.y + g.skin.ribbon.h - g.skin.ribbon.border + (i-1) * g.skin.small_bars.h
			local match = self.search_list[i]
			love.graphics.setColorAlpha(c[1], i%2==0 and 255 or 225)
			love.graphics.rectangle("fill", x, y, self.searchbox.w - g.skin.ribbon.border * 2, g.skin.small_bars.h)
			love.graphics.setColor(255, 255, 255)
			match.image:draw(x + g.skin.margin, y + g.skin.small_bars.iy)
			love.graphics.setColor(c[2])
			g.font.set(g.skin.small_bars.font[2])
			love.graphics.print(match.item.long_name, x + g.skin.margin * 2 + g.skin.small_bars.img_size, y + g.skin.small_bars.ty)
		end
	end
end

function ribbon:mousepressed(x, y, b)
	self.infobox:mousepressed(x, y, b)
	self.searchbox:mousepressed(x, y, b)
	self.continue:mousepressed(x, y, b)
end

function ribbon:mousereleased(x, y, b)
	self.infobox:mousereleased(x, y, b)
	self.continue:mousereleased(x, y, b)
end

function ribbon:keypressed(k, ir)
	self.searchbox:keypressed(k, ir)
	if k=="return" and self.searchbox.focus and self.search_list and #self.search_list>0 then
		local m = self.search_list[self.search_index].item
		if m.__type=="team" then g.vars.view.team_id = m.id; g.state.switch(g.states.club_overview) end
		if m.__type=="league" then g.vars.view.league_id = m.id; g.state.switch(g.states.league_overview) end
	elseif (k=="up" or k=="down") and self.searchbox.focus and self.search_list and #self.search_list > 1 then
		self.search_index = self.search_index + (k=="up" and -1 or 1)
		local max = #self.search_list > 10 and 10 or #self.search_list
		if self.search_index < 1 then self.search_index = 1 elseif self.search_index > max then self.search_index = max end
	elseif k=="backspace" and self.searchbox.focus then
		self:do_search()
	elseif not self.searchbox.focus then
		if k=="up" or k=="down" or k=="left" or k=="right" then
			if self.active_screen_type=="team" then
				local old = g.vars.view.team_id
				if k=="up" or k=="down" then
					local lge = g.db_manager.team_dict[g.vars.view.team_id].league
					local dy = k=="up" and -1 or 1
					for i=1, #lge.teams do
						if lge.teams[i].season.stats.pos == g.db_manager.team_dict[g.vars.view.team_id].season.stats.pos + dy then
							g.vars.view.team_id = lge.teams[i].id
							break
						end
					end
				end
				if k=="left" then g.vars.view.team_id = g.vars.view.team_id - 1 end
				if k=="right" then g.vars.view.team_id = g.vars.view.team_id + 1 end
				if not g.db_manager.team_dict[g.vars.view.team_id] then g.vars.view.team_id = old end
			elseif self.active_screen_type=="league" then
				local old = g.vars.view.league_id
				if k=="up" then g.vars.view.league_id = g.db_manager.league_dict[g.vars.view.league_id].level_up end
				if k=="down" then g.vars.view.league_id = g.db_manager.league_dict[g.vars.view.league_id].level_down end
				if k=="left" then g.vars.view.league_id = g.vars.view.league_id - 1 end
				if k=="right" then g.vars.view.league_id = g.vars.view.league_id + 1 end
				if not g.db_manager.league_dict[g.vars.view.league_id] then g.vars.view.league_id = old end
			end
			g.state.refresh_all()
		end
	end
end

function ribbon:textinput(t)
	self.searchbox:textinput(t)
	self:do_search()
end

function ribbon:do_search()
	self.search_index = 1
	if self.searchbox.focus then
		local text = self.searchbox.text
		self.search_list = {}
		if g.utf8.len(text) < 3 then return end
		for i=1, #g.db_manager.teams do
			local t = g.db_manager.teams[i]
			if string.find(string.lower(t.short_name), string.lower(text)) or string.find(string.lower(t.long_name), string.lower(text)) then
				self.search_list[#self.search_list+1] = { item = t, image = g.image.new("logos/128/"..t.id..".png", {mipmap=true, w=g.skin.small_bars.img_size, h = g.skin.small_bars.img_size })}
			end
		end
		for i=1, #g.db_manager.leagues do
			local t = g.db_manager.leagues[i]
			if string.find(string.lower(t.short_name), string.lower(text)) or string.find(string.lower(t.long_name), string.lower(text)) then
				self.search_list[#self.search_list+1] = { item = t, image = g.image.new("logos/128/"..t.flag..t.level..".png", {mipmap=true, w=g.skin.small_bars.img_size, h = g.skin.small_bars.img_size })}
			end
		end
		table.sort(self.search_list, function(a,b) return a.item.long_name < b.item.long_name end)
	end
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
	self.flux:to(self.tween, g.skin.ribbon.tween_time, { ox = 0, oy = 0, alpha = 1 }):ease(g.skin.ribbon.tween_type)
	--self.timer.tween(g.skin.ribbon.tween_time, self.tween, { ox = 0; oy = 0; alpha = 1; }, g.skin.ribbon.tween_type)
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
	self.continue:set_colors(league.color2, league.color3, league.color3)
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
	self.continue:set_colors(team.color3, team.color2, team.color3)
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
