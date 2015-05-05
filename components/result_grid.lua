local result_grid = {}
result_grid.__index = result_grid
result_grid.__type = "Component.FixtureGroup"

function result_grid.new(x, y, w, h, league)
	local rg = {}
	setmetatable(rg, result_grid)
	rg.x, rg.y, rg.w, rg.h = x or 0, y or 0, w or 10, h or 10
	rg.panel = g.ui.panel.new(rg.x, rg.y, rg.w, rg.h)
	rg.panel:set_colors(g.skin.components.color1, g.skin.components.color3)
	rg:set(league)
	return rg
end

function result_grid:set(league)
	self.league = league
	self.bars = {}
	if league==nil then return end
	local teams = league.teams
	table.sort(teams, function(a,b) return a.short_name < b.short_name end)
	local ty = math.floor(g.skin.bars.h/2 - g.font.height(g.skin.bars.font[1])/2 + .5)
	local iy = math.floor(g.skin.bars.h/2 - g.skin.bars.img_size/2 + .5)
	local column_width = math.floor(math.floor((self.w - g.skin.margin * 2) * .85 + .5) / #teams + .5)
	local rest_width = math.floor(self.w - g.skin.margin * 2 - column_width * #teams + .5)
	local header = { x = self.x + g.skin.margin, y = self.y + g.skin.margin, w = self.w - g.skin.margin * 2, h = g.skin.bars.h, color = self.league.color3, alpha = g.skin.bars.alpha }
	header.images = {}
	local k = 1
	for i=#teams, 1, -1 do
		local team = teams[i]
		local x = math.floor(header.w - g.skin.margin - column_width/2 - g.skin.bars.img_size/2 + .5) - (k-1) * column_width
		header.images[k] = g.image.new("logos/128/"..team.id..".png", {mipmap = true, x = x, y = iy, w = g.skin.bars.img_size, h = g.skin.bars.img_size })
		k = k+1
	end
	self.bars[1] = header
	--
	local team_x = {}
	for i=1, #teams do
		local team = teams[i]
		team_x[team.id] = rest_width + (i-1) * column_width
	end
	for i=1, #teams do
		local team = teams[i]
		local bar = { x = self.x + g.skin.margin, y = self.y + g.skin.margin + i * g.skin.bars.h, w = self.w - g.skin.margin * 2, h = g.skin.bars.h, alpha = g.skin.bars.alpha }
		bar.color = i%2==0 and g.skin.bars.color1 or g.skin.bars.color3
		bar.rects = { { x = 0, y = 0, w = rest_width, h = bar.h, color = self.league.color3, alpha = g.skin.bars.alpha } }
		bar.rects[2] = { x = rest_width + (i-1) * column_width + g.skin.margin, y = g.skin.margin, w = column_width - g.skin.margin * 2, h = bar.h - g.skin.margin * 2, color = g.skin.black, alpha = g.skin.bars.alpha}
		bar.images = { g.image.new("logos/128/"..team.id..".png", {mipmap = true, x = rest_width - g.skin.margin - g.skin.bars.img_size, y = iy, w = g.skin.bars.img_size, h = g.skin.bars.img_size })}
		bar.labels = { { text = team.short_name, x = 0, y = ty, w = rest_width - g.skin.margin * 2 - g.skin.bars.img_size, align="right", font = g.skin.bars.font[2], color = g.skin.bars.color2 }}
		for i=1, #team.season.fixtures do
			local fix = team.season.fixtures[i]
			if fix.home==team and fix.finished then
				local color = fix.winner==team and {0, 123, 0, 255} or (fix.draw and {123, 63, 0, 255} or {123, 0, 0, 255})
				local score = fix.home_score .. "\t-\t" .. fix.away_score
				bar.rects[#bar.rects+1] = { x = team_x[fix.away.id] + g.skin.margin, y = g.skin.margin, w = column_width - g.skin.margin * 2, h = bar.h - g.skin.margin * 2, color = color, alpha = g.skin.bars.alpha}
				bar.labels[#bar.labels+1] = { text = score, x = team_x[fix.away.id], y = ty, w = column_width, align = "center", font = g.skin.bars.font[3], color = g.skin.bars.color2 }
			end
		end
		self.bars[#self.bars+1] = bar
	end
end

function result_grid:draw()
	self.panel:draw()
	love.graphics.setScissor(self.x + g.skin.margin, self.y + g.skin.margin, self.w - g.skin.margin * 2, self.h - g.skin.margin * 2)
	for i=1, #self.bars do
		local bar = self.bars[i]
		g.components.bar_draw.draw(bar)
	end
	love.graphics.setScissor()
end

setmetatable(result_grid, {_call = function(_, ...) return result_grid.new(...) end})

return result_grid