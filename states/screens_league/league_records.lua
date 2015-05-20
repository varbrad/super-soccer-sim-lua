local league_records = {}
league_records.name = "League Records"

function league_records:init()
	self.__z = 1
	--
	g.console:log("league_records:init")
end

function league_records:added()
	self.panel = g.ui.panel.new(g.skin.screen.x + g.skin.margin, g.skin.screen.y + g.skin.margin, g.skin.screen.w - g.skin.margin * 2, g.skin.screen.h - g.skin.margin * 2)
	self.panel:set_colors(g.skin.components.color1, g.skin.components.color3)
	self:set()
end

function league_records:set()
	self.league = g.database.get_view_league()
	-- Stuff here

	--
	g.ribbon:set_league(self.league)
end

function league_records:update(dt)
	
end

function league_records:draw()
	self.panel:draw()
end

return league_records