local league_summary = {}
league_summary.name = "League Summary"

function league_summary:init()
	self.__z = 1
	--
	g.console:log("league_summary:init")
end

function league_summary:added()
	self:set_league()
end

function league_summary:update(dt)
	
end

function league_summary:draw()

end

function league_summary:set_league()
	self.league = g.db_manager.league_dict[g.vars.view.league_id]
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

return league_summary