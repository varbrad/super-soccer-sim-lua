local league_table = {}
league_table.__index = league_table
league_table.__type = "Component.LeagueTable"

local function color_copy(c)
	return {c[1], c[2], c[3], c[4] or 255}
end

function league_table.new(x, y, w, h, league, style)
	local lt = {}
	setmetatable(lt, league_table)
	lt.x, lt.y, lt.w, lt.h, lt.style = x or 0, y or 0, w or 10, h or 10, style or "default"
	lt.panel = g.ui.panel.new(lt.x, lt.y, lt.w, lt.h)
	lt.panel:set_colors(g.skin.components.color1, g.skin.components.color3)
	lt:set_league(league)
	return lt
end

function league_table:set_league(league)
	self.league = league
	self.bars = {}
	--
	if self.league==nil then return end
	--
	self.bars[1] = {x = self.x + g.skin.margin; y = self.y + g.skin.margin; w = self.w - g.skin.margin * 2; h = g.skin.bars.h; color = self.league.color3; alpha = g.skin.bars.alpha}
	self.bars[1].ty = math.floor(self.bars[1].h / 2 - g.font.height(g.skin.bars.font[1])/2 +.5)
	self.bars[1].logo = g.image.new("logos/128/"..self.league.flag..self.league.level..".png", {mipmap = true, w = g.skin.bars.img_size, h = g.skin.bars.img_size, y = self.bars[1].y + math.floor(self.bars[1].h/2 - g.skin.bars.img_size/2 + .5) })
	self.bars[1].pos = "Pos"
	self.bars[1].name = "Team"
	self.bars[1].stats = {p = "P", w = "W", d = "D", l = "L", gf = "GF", ga = "GA", gd = "GD", pts = "Pts" }
	for i=1, #self.league.teams do
		local t = self.league.teams[i]
		local bar = {}
		bar.x = self.x + g.skin.margin
		bar.y = self.y + g.skin.margin + i * g.skin.bars.h
		bar.w = self.w - g.skin.margin * 2
		bar.h = g.skin.bars.h
		bar.color = i%2==0 and color_copy(g.skin.bars.color1) or color_copy(g.skin.bars.color3)
		if self.league.promoted >= i then
			bar.color[2] = bar.color[2] + 50
		elseif self.league.promoted + self.league.playoffs >= i then
			bar.color[1], bar.color[2] = bar.color[1] + 50, bar.color[2] + 25
		elseif self.league.relegated > #self.league.teams - i then
			bar.color[1] = bar.color[1] + 50
		end
		--
		bar.alpha = g.skin.bars.alpha
		bar.ty = math.floor(bar.h / 2 - g.font.height(g.skin.bars.font[2])/2 +.5)
		bar.pos = i .. "."
		bar.logo = g.image.new("logos/128/"..t.id..".png", {mipmap = true, w = g.skin.bars.img_size, h = g.skin.bars.img_size, y = bar.y + math.floor(bar.h/2 - g.skin.bars.img_size/2 +.5) })
		bar.name = t.short_name
		bar.stats = {}
		bar.stats.pts = t.season.stats.pts
		bar.stats.gd = t.season.stats.gd
		if bar.stats.gd > 0 then bar.stats.gd = "+" .. bar.stats.gd end
		bar.stats.ga = t.season.stats.ga
		bar.stats.gf = t.season.stats.gf
		bar.stats.l = t.season.stats.l
		bar.stats.d = t.season.stats.d
		bar.stats.w = t.season.stats.w
		bar.stats.p = t.season.stats.p
		self.bars[i+1] = bar
	end
end

function league_table:draw()
	if self.league==nil then return end
	self.panel:draw()
	for i=1, #self.bars do
		local bar = self.bars[i]
		love.graphics.setColorAlpha(bar.color, bar.alpha)
		love.graphics.rectangle("fill", bar.x, bar.y, bar.w, bar.h)
		love.graphics.setColorAlpha(g.skin.bars.color2)
		if i==1 then g.font.set(g.skin.bars.font[1]) else g.font.set(g.skin.bars.font[2]) end
		love.graphics.printf(bar.pos, bar.x + g.skin.margin, bar.y + bar.ty, 30, "right")
		love.graphics.print(bar.name, bar.x + g.skin.margin * 5 + 30 + g.skin.bars.img_size, bar.y + bar.ty)
		if i>1 then g.font.set(g.skin.bars.font[3]) end
		if self.style=="default" then
			love.graphics.printf(bar.stats.pts, bar.x + bar.w - g.skin.margin - 30, bar.y + bar.ty, 30, "center")
			love.graphics.printf(bar.stats.gd, bar.x + bar.w - g.skin.margin * 2 - 60, bar.y + bar.ty, 30, "center")
			love.graphics.printf(bar.stats.ga, bar.x + bar.w - g.skin.margin * 3 - 90, bar.y + bar.ty, 30, "center")
			love.graphics.printf(bar.stats.gf, bar.x + bar.w - g.skin.margin * 4 - 120, bar.y + bar.ty, 30, "center")
			love.graphics.printf(bar.stats.l, bar.x + bar.w - g.skin.margin * 5 - 150, bar.y + bar.ty, 30, "center")
			love.graphics.printf(bar.stats.d, bar.x + bar.w - g.skin.margin * 6 - 180, bar.y + bar.ty, 30, "center")
			love.graphics.printf(bar.stats.w, bar.x + bar.w - g.skin.margin * 7 - 210, bar.y + bar.ty, 30, "center")
			love.graphics.printf(bar.stats.p, bar.x + bar.w - g.skin.margin * 8 - 240, bar.y + bar.ty, 30, "center")
		elseif self.style=="small" then
			love.graphics.printf(bar.stats.pts, bar.x + bar.w - g.skin.margin - 30, bar.y + bar.ty, 30, "center")
			love.graphics.printf(bar.stats.gd, bar.x + bar.w - g.skin.margin * 2 - 60, bar.y + bar.ty, 30, "center")
			love.graphics.printf(bar.stats.p, bar.x + bar.w - g.skin.margin * 3 - 90, bar.y + bar.ty, 30, "center")
		end
		--
		if bar.logo then
			love.graphics.setColor(255, 255, 255, 255)
			bar.logo:draw(bar.x + g.skin.margin * 3 + 30)
		end
	end
end

setmetatable(league_table, {_call = function(_, ...) return league_table.new(...) end})

return league_table