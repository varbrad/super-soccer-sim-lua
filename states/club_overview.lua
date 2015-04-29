local club_overview = {}
club_overview.name = "Club Overview"

function club_overview:init()
	self.__z = 1
	self.timer = g.timer.new()
	--
	g.console:log("club_overview:init")
end

function club_overview:added(id)
	self.team_id = id or self.team_id or 1
	self.panel = g.ui.panel.new(g.skin.screen.x + g.skin.margin, g.skin.screen.y + g.skin.margin, g.skin.screen.w - g.skin.margin*2, g.skin.screen.h - g.skin.margin*2, {0, 0, 0}, {33, 33, 33}, 160)
	self:set_team()
end

function club_overview:update(dt)
	self.timer.update(dt)
end

function club_overview:draw()
	self.panel:draw()
end

function club_overview:set_team()
	self.team = g.db_manager.team_dict[self.team_id]
	-- Clear any previous tweens on our timer
	self.timer.clear()
	--
	g.ribbon:reset()
	--
	g.ribbon:set_image("logos/128/"..self.team.id..".png")
	g.ribbon:set_header(self.team.long_name)
	g.ribbon:set_colors(self.team.color1, self.team.color2, self.team.color3)
	--
	local btn_settings = {}
	btn_settings.w = "auto"
	btn_settings.color1 = self.team.color1
	btn_settings.color2 = self.team.color2
	btn_settings.color3 = self.team.color3
	btn_settings.image = g.image.new("logos/128/"..self.team.league.flag..self.team.league.level..".png", {mipmap=true, w=26, h=26})
	btn_settings.underline = true
	btn_settings.on_release = function() g.state.swap(self, g.states.league_overview, self.team.league_id) end
	g.ribbon:set_infobox(self.team.league.long_name, btn_settings)
	-- Start positioning and tweens
	g.ribbon:set_positions()
	g.ribbon:start_tween()
end

function club_overview:keypressed(k, ir)
	local old_id = self.team_id
	if k=="left" then self.team_id = self.team_id - 1 end
	if k=="right" then self.team_id = self.team_id + 1 end
	if k=="left" or k=="right" then
		local t = g.db_manager.team_dict[self.team_id]
		if t==nil then
			self.team_id = old_id
			return
		else
			self:set_team()
		end
	end
end

return club_overview