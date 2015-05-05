local league_full_table = {}
league_full_table.name = "League Full Table"

function league_full_table:init()
	self.__z = 1
	--
	g.console:log("league_full_table:init")
end

function league_full_table:added()
	self.league_table = g.components.league_table.new(g.skin.screen.x + g.skin.margin, g.skin.screen.y + g.skin.margin, g.skin.screen.w - g.skin.margin * 2, g.skin.screen.h - g.skin.margin * 2, nil, "full")
	self:set_league()
end

function league_full_table:update(dt)
	
end

function league_full_table:draw()
	self.league_table:draw()
end

function league_full_table:set_league()
	self.league = g.db_manager.league_dict[g.vars.view.league_id]
	self.league_table:set(self.league)
	--
	g.ribbon:reset()
	--
	g.ribbon:set_image("logos/128/"..self.league.flag..self.league.level..".png")
	g.ribbon:set_header(self.league.long_name)
	g.ribbon:set_colors(self.league.color1, self.league.color2, self.league.color3)
	--
	local infobox = {}
	infobox.w = "auto"
	infobox.enabled = false
	infobox.image = g.image.new("flags/"..self.league.flag..".png")
	infobox.color1, infobox.color2, infobox.color3 = self.league.color1, self.league.color2, self.league.color3
	if infobox.image==nil then infobox.visible = false end
	g.ribbon:set_infobox("", infobox)
	--
	g.ribbon:set_positions()
	g.ribbon:start_tween()
end

function league_full_table:keypressed(k, ir)
	if k=="1" then self.league_table:set(self.league, "small")
	elseif k=="2" then self.league_table:set(self.league, "default")
	elseif k=="3" then self.league_table:set(self.league, "full")
	end
end

return league_full_table