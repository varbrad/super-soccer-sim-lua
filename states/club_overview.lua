local club_overview = {}
club_overview.name = "Club Overview"

function club_overview:init()
	self.__z = 1
	--
	g.console:log("club_overview:init")
end

function club_overview:added(id)
	self.team_id = id or 1
	self:set_team()
end

function club_overview:update(dt)
	
end

function club_overview:draw()

end

function club_overview:set_team()
	self.team = g.db_manager.team_dict[self.team_id]
	--
	g.ribbon:reset()
	--
	g.ribbon:set_image("logos/128/"..self.team.id..".png")
	g.ribbon:set_header(self.team.long_name)
	g.ribbon:set_colors(self.team.color1, self.team.color2, self.team.color3)
	local btn_img = g.image.new("logos/128/"..self.team.league.flag..self.team.league.level..".png", {mipmap = true, w = 26, h = 26 })
	g.ribbon.button:reset()
	g.ribbon.button:set_colors(self.team.color1, self.team.color2, self.team.color3)
	g.ribbon.button:set_image(btn_img)
	g.ribbon.button:set_text(self.team.league.long_name)
	g.ribbon.button:set_events(nil, nil, nil, function() g.state.swap(self, g.states.league_overview, self.team.league_id) end)
	g.ribbon.button.visible, g.ribbon.button.enabled = true, true
	--
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