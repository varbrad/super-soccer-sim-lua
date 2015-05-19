local team_league_history_graph = {}
team_league_history_graph.__index = team_league_history_graph
team_league_history_graph.__type = "Component.TeamLeagueHistoryGraph"

function team_league_history_graph.new(x, y, w, h, max_seasons)
	local t = {}
	setmetatable(t, team_league_history_graph)
	t.x, t.y, t.w, t.h, t.max_seasons = x or 0, y or 0, w or 10, h or 10, max_seasons or 10
	t.panel = g.ui.panel.new(t.x, t.y, t.w, t.h)
	t.panel:set_colors(g.skin.components.color1, g.skin.components.color3)
	t:set()
	return t
end

function team_league_history_graph:set(team)
	self.team = team
	local graph_h = self.h - g.skin.margin * 4
	local graph_w = self.w - g.skin.margin * 4
	local top, left, bottom, right = g.skin.margin * 4, g.skin.margin * 4 + g.skin.bars.img_size, self.h - g.skin.margin * 4, self.w - g.skin.margin * 4
	self.lines = {}
	self.points = {}
	self.rects = {}
	self.images = {}
	table.insert(self.lines, {left, top, left, bottom})
	table.insert(self.lines, {left, bottom, right, bottom})
	if self.team==nil then return end
	local seasons_to_show = #self.team.data.history.past_seasons
	if seasons_to_show > self.max_seasons then seasons_to_show = self.max_seasons end
	local seasons = self.team.data.history.past_seasons
	local seasons_c = #seasons; if seasons_c > seasons_to_show then seasons_c = seasons_to_show end
	if seasons_c < 1 then return end
	-- Draw bottom notches
	for i=1, seasons_c do
		local x = g.math.lerp(right, left, (i-1) / (seasons_to_show-1))
		table.insert(self.lines, {x, bottom, x, bottom + g.skin.margin * 2})
	end
	--
	local unique_divisions = {}
	local league_list = {}
	local top_level = 999
	for i = #seasons - seasons_c + 1, #seasons do
		local league = g.database.get_league(seasons[i].league)
		unique_divisions[league] = true
		league_list[league.level] = league
		if league.level < top_level then top_level = league.level end
	end
	local ud = 0; for i, v in pairs(unique_divisions) do ud = ud + 1 end; unique_divisions = ud
	-- unique_divisions now has the number of divisions, and top_level is the highest level reached
	--
	local split_h = (bottom - top) / unique_divisions
	if unique_divisions > 1 then
		local split_w = 1 / unique_divisions
		for i = 1, unique_divisions - 1 do
			if i%2~=0 then
				local y = g.math.lerp(top, bottom, split_w * i)
				table.insert(self.rects, {x = left, y = y, w = right-left, h = split_h, color = g.skin.bars.color3 })
			end
		end
	end
	for i=1, unique_divisions do
		local lge = league_list[top_level + (i-1)]
		local y = g.math.lerp(top, bottom, (i-1) / unique_divisions)
		y = y + split_h/2 - g.skin.bars.img_size/2
		table.insert(self.images, g.image.new("logos/128/"..lge.flag..lge.level..".png",
					{mipmap = true, w = g.skin.bars.img_size, h = g.skin.bars.img_size, x = g.skin.margin * 2, y = y }))
	end
	--
	for i = 1, seasons_c do
		local season = seasons[#seasons-i+1] -- Recent season to oldest
		local league = g.database.get_league(season.league)
		local x = g.math.lerp(right, left, (i-1) / (seasons_to_show-1))
		local league_level = league.level - top_level
		local sy = g.math.lerp(top, bottom, (1/unique_divisions) * league_level)
		local oy = g.math.lerp(0, split_h, (season.stats.pos-1)/season.league_team_count)
		local y = sy + oy
		local c = g.skin.colors[4]
		if not season.promoted and oy==0 then c = {190, 130, 5} elseif season.promoted then c = {5, 195, 5} elseif season.relegated then c = {195, 5, 5} end
		table.insert(self.points, {x = x, y = y, color = c})
	end
	--
end

function team_league_history_graph:draw()
	self.panel:draw()
	love.graphics.setScissor(self.x + g.skin.margin, self.y + g.skin.margin, self.w - g.skin.margin * 2, self.h - g.skin.margin * 2)
	-- Draw lines first
	love.graphics.setLineWidth(2)
	for i=1, #self.rects do
		local rect = self.rects[i]
		love.graphics.rectangle("fill", self.x + rect.x, self.y + rect.y, rect.w, rect.h)
	end
	for i=1, #self.lines do
		local line = self.lines[i]
		if line.color then love.graphics.setColorAlpha(line.color, g.skin.bars.alpha) else love.graphics.setColorAlpha(g.skin.bars.color2, g.skin.bars.alpha) end
		love.graphics.line(self.x + line[1], self.y + line[2], self.x + line[3], self.y + line[4])
	end
	if #self.points > 1 then
		for i=1, #self.points - 1 do
			local p1, p2 = self.points[i], self.points[i+1]
			love.graphics.setColorAlpha(g.skin.bars.color2, g.skin.bars.alpha)
			love.graphics.line(self.x + p1.x, self.y + p1.y, self.x + p2.x, self.y + p2.y)
		end
	end
	for i=1, #self.points do
		local point = self.points[i]
		love.graphics.setColorAlpha(point.color, 255)
		love.graphics.circle("fill", self.x + point.x, self.y + point.y, 6, 4)
	end
	for i=1, #self.images do
		local image = self.images[i]
		love.graphics.setColor(255, 255, 255, 255)
		image:draw(self.x, self.y)
	end
	--
	love.graphics.setScissor()
end

setmetatable(team_league_history_graph, {_call = function(_, ...) return team_league_history_graph.new(...) end})

return team_league_history_graph