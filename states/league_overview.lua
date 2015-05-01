local league_overview = {}
league_overview.name = "League Overview"

function league_overview:init()
	self.__z = 1
	--
	g.console:log("league_overview:init")
end

function league_overview:added(id)
	self.league_id = id or self.league_id or 1
	self.league_table = g.components.league_table.new(g.skin.screen.x + g.skin.margin, g.skin.screen.y + g.skin.margin, 500, g.skin.screen.h - g.skin.margin * 2)
	self:set_league()
end

function league_overview:update(dt)
	
end

function league_overview:draw()
	self.league_table:draw()
end

function league_overview:set_league()
	self.league = g.db_manager.league_dict[self.league_id]
	self.league_table:set_league(self.league)
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

function league_overview:keypressed(k, ir)
	local old_id = self.league_id
	if k=="left" then self.league_id = self.league_id - 1 end
	if k=="right" then self.league_id = self.league_id + 1 end
	if k=="left" or k=="right" then
		local l = g.db_manager.league_dict[self.league_id]
		if l==nil then
			self.league_id = old_id
			return
		else
			self:set_league()
		end
	end
end

return league_overview