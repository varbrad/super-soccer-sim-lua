local result_grid = {}
result_grid.__index = result_grid
result_grid.__type = "Component.ResultGrid"

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
	self.bars, self.buttons = {}, {}
	if league==nil then return end
	local teams = league.refs.teams
	table.sort(teams, g.engine.sort_short_name)
	local ty = math.floor(g.skin.bars.h/2 - g.font.height(g.skin.bars.font[1])/2 + .5)
	local iy = math.floor(g.skin.bars.h/2 - g.skin.bars.img_size/2 + .5)
	local column_width = math.floor(math.floor((self.w - g.skin.margin * 2) * .85 + .5) / #teams + .5)
	local rest_width = math.floor(self.w - g.skin.margin * 2 - column_width * #teams + .5)
	local header = { x = self.x + g.skin.margin, y = self.y + g.skin.margin, w = self.w - g.skin.margin * 2, h = g.skin.bars.h, color = self.league.color2, alpha = g.skin.bars.alpha }
	header.images = {}
	local k = 1
	for i=#teams, 1, -1 do
		local team = teams[i]
		local x = math.floor(header.w - g.skin.margin - column_width/2 - g.skin.bars.img_size/2 + .5) - (k-1) * column_width
		header.images[k] = g.image.new("logos/"..team.id..".png", {mipmap = true, x = x, y = iy, w = g.skin.bars.img_size, h = g.skin.bars.img_size, team = team })
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
		bar.rects = { { x = 0, y = 0, w = rest_width, h = bar.h, color = self.league.color2, alpha = g.skin.bars.alpha } }
		bar.rects[2] = { x = rest_width + (i-1) * column_width + g.skin.margin, y = g.skin.margin, w = column_width - g.skin.margin * 2, h = bar.h - g.skin.margin * 2, color = g.skin.black, alpha = g.skin.bars.alpha}
		bar.images = { g.image.new("logos/"..team.id..".png", {mipmap = true, x = rest_width - g.skin.margin - g.skin.bars.img_size, y = iy, w = g.skin.bars.img_size, h = g.skin.bars.img_size, team = team })}
		local c = g.database.vars.player.team_id==team.id and g.skin.colors[3] or g.skin.bars.color2
		bar.labels = { { text = team.short_name, x = bar.images[1].x - g.skin.margin, y = ty, font = g.skin.bars.font[2], color = c }}
		bar.labels[1].h, bar.labels[1].w = g.font.height(bar.labels[1].font), g.font.width(bar.labels[1].text, bar.labels[1].font)
		bar.labels[1].x = bar.labels[1].x - bar.labels[1].w
		local btn = g.ui.button.new("", { w = bar.labels[1].w, h = bar.labels[1].h, x = bar.x + bar.labels[1].x, y = bar.y + bar.labels[1].y } )
		btn.on_enter = function(btn) bar.labels[1].underline = true end
		btn.on_exit = function(btn) bar.labels[1].underline = false end
		btn.on_release = function(btn) g.database.vars.view.team_id = team.id; g.state.switch(g.states.club_overview) end
		table.insert(self.buttons, btn)
		local fixtures = g.engine.get_team_league_fixtures(self.league, team)
		for i=1, #fixtures do
			local fix = fixtures[i]
			if fix.home==team.id and fix.finished then
				local color = fix.winner==team.id and {0, 123, 0, 255} or (fix.draw and {123, 63, 0, 255} or {123, 0, 0, 255})
				local score = fix.home_score .. "\t-\t" .. fix.away_score
				bar.rects[#bar.rects+1] = { x = team_x[fix.away] + g.skin.margin, y = g.skin.margin, w = column_width - g.skin.margin * 2, h = bar.h - g.skin.margin * 2, color = color, alpha = g.skin.bars.alpha}
				bar.labels[#bar.labels+1] = { text = score, x = team_x[fix.away], y = ty, w = column_width, align = "center", font = g.skin.bars.font[3], color = g.skin.bars.color2 }
			end
		end
		self.bars[#self.bars+1] = bar
	end
end

function result_grid:update(dt)
	for i=1, #self.buttons do self.buttons[i]:update(dt) end
end

function result_grid:draw(t_alpha)
	self.panel:draw()
	love.graphics.setScissor(self.x + g.skin.margin, self.y + g.skin.margin, self.w - g.skin.margin * 2, self.h - g.skin.margin * 2)
	for i=1, #self.bars do
		local bar = self.bars[i]
		g.components.bar_draw.draw(bar, 0, 0, t_alpha)
	end
	love.graphics.setScissor()
end

function result_grid:mousepressed(x, y, b)
	for i=1, #self.buttons do self.buttons[i]:mousepressed(x, y, b) end
end

function result_grid:mousereleased(x, y, b)
	for i=1, #self.buttons do self.buttons[i]:mousereleased(x, y, b) end
end

setmetatable(result_grid, {_call = function(_, ...) return result_grid.new(...) end})

return result_grid