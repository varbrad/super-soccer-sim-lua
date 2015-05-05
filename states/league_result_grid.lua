local league_results_grid = {}
league_results_grid.name = "League Results Grid"

function league_results_grid:init()
	self.__z = 1
	--
	g.console:log("league_results_grid:init")
end

function league_results_grid:added()
	local w, h = g.skin.screen.w - g.skin.margin * 2, g.skin.screen.h - g.skin.margin * 2
	local w80 = w * .8
	self.result_grid = g.components.result_grid.new(g.skin.screen.x + g.skin.margin, g.skin.screen.y + g.skin.margin, w80, h)
	self.league_table = g.components.league_table.new(self.result_grid.x + self.result_grid.w + g.skin.margin, self.result_grid.y, w - w80 - g.skin.margin, h, nil, "small")
	self:set_league()
end

function league_results_grid:update(dt)
	
end

function league_results_grid:draw()
	self.result_grid:draw()
	self.league_table:draw()
end

function league_results_grid:set_league()
	self.league = g.db_manager.league_dict[g.vars.view.league_id]
	self.result_grid:set(self.league)
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

return league_results_grid