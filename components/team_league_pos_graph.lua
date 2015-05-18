local team_league_pos_graph = {}
team_league_pos_graph.__index = team_league_pos_graph
team_league_pos_graph.__type = "Component.TeamLeaguePosGraph"

local function lerp(a,b,t) return (1-t)*a + t*b end

function team_league_pos_graph.new(x, y, w, h)
	local t = {}
	setmetatable(t, team_league_pos_graph)
	t.x, t.y, t.w, t.h = x or 0, y or 0, w or 10, h or 10
	t.panel = g.ui.panel.new(t.x, t.y, t.w, t.h)
	t.panel:set_colors(g.skin.components.color1, g.skin.components.color3)
	t:set()
	return t
end

function team_league_pos_graph:set(team)
	self.team = team
	local graph_h = self.h - g.skin.margin * 4
	local graph_w = self.w - g.skin.margin * 4
	local top, left, bottom, right = g.skin.margin * 4, g.skin.margin * 4, self.h - g.skin.margin * 4, self.w - g.skin.margin * 4
	self.lines = {}
	self.points = {}
	table.insert(self.lines, {left, top, left, bottom})
	table.insert(self.lines, {left, bottom, right, bottom})
	if self.team==nil then return end
	local team_count = #self.team.refs.league.refs.teams
	for i=1, team_count do
		local y = lerp(top, bottom, (i-1) / (team_count-1))
		if i~=team_count then table.insert(self.lines, {left, y, right, y, color = g.skin.bars.color3 }) end -- Horizontal guide lines
		table.insert(self.lines, {left, y, left - g.skin.margin * 2, y})
	end
	local fix_count = team_count * 2 - 2
	for i=1, fix_count do
		local x = lerp(left, right, (i-1) / (fix_count-1))
		table.insert(self.lines, {x, bottom, x, bottom + g.skin.margin * 2})
	end
	-- place points
	for i=1, #self.team.data.season.past_pos do
		local pos = self.team.data.season.past_pos[i]
		local x, y = lerp(left, right, (i-1) / (fix_count-1)), lerp(top, bottom, (pos-1) / (team_count-1))
		local fix = self.team.season.fixtures[i]
		local color = {195, 5, 5}
		if fix.winner==self.team then color = {5, 195, 5} elseif fix.draw then color = {195, 115, 5} end
		table.insert(self.points, {x = x, y = y, color = color})
	end
end

function team_league_pos_graph:draw()
	self.panel:draw()
	love.graphics.setScissor(self.x + g.skin.margin, self.y + g.skin.margin, self.w - g.skin.margin * 2, self.h - g.skin.margin * 2)
	-- Draw lines first
	love.graphics.setLineWidth(2)
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
	--
	love.graphics.setScissor()
end

setmetatable(team_league_pos_graph, {_call = function(_, ...) return team_league_pos_graph.new(...) end})

return team_league_pos_graph