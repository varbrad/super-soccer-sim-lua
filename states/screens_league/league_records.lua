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
	g.tween_alpha()
	self:set()
end

function league_records:set()
	self.league = g.database.get_view_league()
	self.bars, self.buttons = {}, {}
	-- Stuff here
	local i = 1
	local key_order = {
		{ "w", "Wins", "Most", "Fewest" },
		{ "d", "Draws", "Most", "Fewest" },
		{ "l", "Defeats", "Most", "Fewest" },
		{ "gf", "Goals Scored", "Most", "Fewest" },
		{ "ga", "Goals Conceded", "Most", "Fewest" },
		{ "gd", "Goal Difference", "Best", "Worst" },
		{ "pts", "Points", "Most", "Fewest" },
		{ "cs", "Clean Sheets", "Most", "Fewest"},
		{ 1 },
		{ "hw", "Home Wins", "Most", "Fewest" },
		{ "hd", "Home Draws", "Most", "Fewest" },
		{ "hl", "Home Defeats", "Most", "Fewest" },
		{ "hgf", "Home Goals Scored", "Most", "Fewest" },
		{ "hga", "Home Goals Conceded", "Most", "Fewest" },
		{ "hgd", "Home Goal Difference", "Best", "Worst" },
		{ "hpts", "Home Points", "Most", "Fewest" },
		{ "hcs", "Home Clean Sheets", "Most", "Fewest" },
		{ 1 },
		{ "aw", "Away Wins", "Most", "Fewest" },
		{ "ad", "Away Draws", "Most", "Fewest" },
		{ "al", "Away Defeats", "Most", "Fewest" },
		{ "agf", "Away Goals Scored", "Most", "Fewest" },
		{ "aga", "Away Goals Conceded", "Most", "Fewest" },
		{ "agd", "Away Goal Difference", "Best", "Worst" },
		{ "apts", "Away Points", "Most", "Fewest" },
		{ "acs", "Away Clean Sheets", "Most", "Fewest" }
	}
	local half_w = math.floor((self.panel.w - g.skin.margin * 2)/2 + .5)
	local data_list = { self.league.data.history.records.max, self.league.data.history.records.min }
	for a = 1, #data_list do
		local x = self.panel.x + g.skin.margin
		if a==2 then x = x + half_w end
		for i = 1, #key_order do
			local k = key_order[i][1]
			if type(k)=="number" then
				i = i + k
			else
				local v = data_list[a][k]
				if v~=nil then
					local bar = { x = x, y = self.panel.y + g.skin.margin + i * g.skin.bars.h, w = half_w, h = g.skin.bars.h, alpha = g.skin.bars.alpha }
					bar.color, bar.label_color = i%2==0 and g.skin.bars.color1 or g.skin.bars.color3, g.skin.bars.color2
					local team, value, year = g.database.get_team(v.team), v.value, v.year or g.database.vars.year
					local info_text_val = key_order[i][2+a] .. " " .. key_order[i][2]
					local info_text = { text = info_text_val, x = 0, y = g.skin.bars.ty, w = 300, align = "center", font = g.skin.bars.font[1] }
					local info_rect = { x = info_text.x, y = 0, w = info_text.w, h = g.skin.bars.h, color = self.league.color2, alpha = g.skin.bars.alpha }
					if (k=="gd" or k=="hgd" or k=="agd") and value > 0 then value = "+" .. value end
					local value_text = { text = value, x = info_text.x + info_text.w + g.skin.margin, y = g.skin.bars.ty, w = 100, align = "center", font = g.skin.bars.font[3] }
					local team_logo = g.image.new("logos/"..team.id..".png", { mipmap = true, w = g.skin.bars.img_size, h = g.skin.bars.img_size, x = value_text.x + value_text.w + g.skin.img_margin, y = g.skin.bars.iy })
					local team_name = { text = team.long_name, x = team_logo.x + team_logo.w + g.skin.img_margin, y = g.skin.bars.ty, font = g.skin.bars.font[2] }
					team_name.color = g.database.get_player_team() == team and g.skin.colors[3] or nil
					team_name.w, team_name.h = g.font.width(team_name.text, team_name.font), g.font.height(team_name.font)
					--
					local btn = g.ui.button.new("", { x = bar.x + team_name.x, y = bar.y + team_name.y, w = team_name.w, h = team_name.h })
					btn.visible = false
					btn.on_enter = function(b) team_name.underline = true end
					btn.on_exit = function(b) team_name.underline = false end
					btn.on_release = function(b) g.database.vars.view.team_id = team.id; g.state.switch(g.states.club_overview) end
					table.insert(self.buttons, btn)
					--
					local year_text = { text = year .. "/" .. (year+1), x = team_name.x + team_name.w + g.skin.margin, y = g.skin.bars.ty, font = g.skin.bars.font[2], alpha = g.skin.bars.alpha }
					--
					bar.images = { team_logo }
					bar.labels = { info_text, value_text, team_name, year_text }
					bar.rects = { info_rect }
					table.insert(self.bars, bar)
					i = i + 1
				end
			end
		end
	end
	--
	g.ribbon:set_league(self.league)
end

function league_records:update(dt)
	for i=1, #self.buttons do self.buttons[i]:update(dt) end
end

function league_records:draw()
	self.panel:draw()
	for i=1, #self.bars do g.components.bar_draw.draw(self.bars[i], 0, 0, g.tween.t_alpha) end
end

function league_records:mousepressed(x, y, b)
	for i=1, #self.buttons do self.buttons[i]:mousepressed(x, y, b) end
end

function league_records:mousereleased(x, y, b)
	for i=1, #self.buttons do self.buttons[i]:mousereleased(x, y, b) end
end

return league_records