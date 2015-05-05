local league_table = {}
league_table.__index = league_table
league_table.__type = "Component.LeagueTable"

local style_list = {
	small = {"Pts", "GD", "P"};
	default = {"Pts", "GD", "GA", "GF", "L", "D", "W", "P"};
	full = {"Pts", "GD", "GA", "GF", "L", "D", "W", "P", 2, "APts", "AGD", "AGA", "AGF", "AL", "AD", "AW", "AP", 2, "HPts", "HGD", "HGA", "HGF", "HL", "HD", "HW", "HP"}
}

local function color_copy(c)
	return {c[1], c[2], c[3], c[4] or 255}
end

-- valid styles are
-- "min"		-> P, GD, Pts
-- "default"	-> P, W, D, L, GF, GA, GD, Pts
-- "full"		-> HP, HW, HD, HL, HGF, HGA, HGD, HPts, AP, AW, AD, AL, AGF, AGA, AGD, APts, P, W, D, L, GF, GA, GD, Pts
function league_table.new(x, y, w, h, league, style)
	local lt = {}
	setmetatable(lt, league_table)
	lt.x, lt.y, lt.w, lt.h, lt.style = x or 0, y or 0, w or 10, h or 10, style or "default"
	lt.panel = g.ui.panel.new(lt.x, lt.y, lt.w, lt.h)
	lt.panel:set_colors(g.skin.components.color1, g.skin.components.color3)
	lt:set(league)
	return lt
end

function league_table:set(league)
	self.league = league
	self.bars = {}
	--
	if self.league==nil then return end
	--
	g.db_manager.sort_league(league)
	local header = { x = self.x + g.skin.margin, y = self.y + g.skin.margin, w = self.w - g.skin.margin * 2, h = g.skin.bars.h, color = self.league.color3, alpha = g.skin.bars.alpha }
	header.images = { g.image.new("logos/128/"..self.league.flag..self.league.level..".png", {mipmap = true, w = g.skin.bars.img_size, h = g.skin.bars.img_size, y = g.skin.bars.iy, x = g.skin.margin * 3 + 30})}
	header.labels = {
		{ text = "Pos",		x = g.skin.margin, y = g.skin.bars.ty, w = 30, align = "center", font = g.skin.bars.font[1], color = self.league.color2 };
		{ text = "Team",	x = g.skin.margin * 5 + 30 + g.skin.bars.img_size, y = g.skin.bars.ty, font = g.skin.bars.font[1], color = self.league.color2 };
	}
	local s_list = style_list[self.style]
	local x = header.w - g.skin.margin - g.skin.bars.column_size
	for i=1, #s_list do
		local item = s_list[i]
		if type(item)=="string" then
			table.insert(header.labels, { text = item, x = x, y = g.skin.bars.ty, font = g.skin.bars.font[1], color = self.league.color2, w = g.skin.bars.column_size, align = "center" })
			x = x - g.skin.margin - g.skin.bars.column_size
		elseif type(item)=="number" then
			x = x - g.skin.tab * item
		end
	end
	self.bars[1] = header
	for i=1, #self.league.teams do
		local team = self.league.teams[i]
		local pos = team.season.stats.pos
		local bar = { x = self.x + g.skin.margin, y = self.y + g.skin.margin + i * g.skin.bars.h, w = self.w - g.skin.margin * 2, h = g.skin.bars.h, alpha = g.skin.bars.alpha }
		bar.color = i%2==0 and color_copy(g.skin.bars.color1) or color_copy(g.skin.bars.color3)
		-- Colorise promotion/relegation bars, etc.
		if self.league.promoted >= pos or pos==1 then
			bar.color[2] = bar.color[2] + 70
		elseif self.league.promoted + self.league.playoffs >= pos then
			bar.color[1], bar.color[2] = bar.color[1] + 70, bar.color[2] + 35
		elseif self.league.relegated > #self.league.teams - pos then
			bar.color[1] = bar.color[1] + 70
		elseif self.league.relegated + self.league.r_playoffs > #self.league.teams - pos then
			bar.color[1] = bar.color[1] + 50
		end
		--
		bar.images = { g.image.new("logos/128/"..team.id..".png", {mipmap = true, w = g.skin.bars.img_size, h = g.skin.bars.img_size, y = g.skin.bars.iy, x = g.skin.margin * 3 + 30})}
		bar.labels = {
			{ text = pos..".", x = g.skin.margin, y = g.skin.bars.ty, w = 30, align = "right", font = g.skin.bars.font[3], color = g.skin.bars.color2 };
			{ text = team.short_name, x = g.skin.margin * 5 + 30 + g.skin.bars.img_size, y = g.skin.bars.ty, font = g.skin.bars.font[2], color = g.skin.bars.color2 };
		}
		local stats = team.season.stats
		local x = bar.w - g.skin.margin - g.skin.bars.column_size
		for i=1, #s_list do
			local item = s_list[i]
			if type(item)=="string" then
				table.insert(bar.labels, { text = stats[string.lower(item)], x = x, y = g.skin.bars.ty, font = g.skin.bars.font[3], color = g.skin.bars.color2, w = g.skin.bars.column_size, align = "center" })
				x = x - g.skin.margin - g.skin.bars.column_size
			elseif type(item)=="number" then
				x = x - g.skin.tab * item
			end
		end
		--
		table.insert(self.bars, bar)
	end
	--[[
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
		if self.league.promoted >= i or i==1 then
			bar.color[2] = bar.color[2] + 70
		elseif self.league.promoted + self.league.playoffs >= i then
			bar.color[1], bar.color[2] = bar.color[1] + 70, bar.color[2] + 35
		elseif self.league.relegated > #self.league.teams - i then
			bar.color[1] = bar.color[1] + 70
		elseif self.league.relegated + self.league.r_playoffs > #self.league.teams - i then
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
	--]]
end

function league_table:draw()
	self.panel:draw()
	love.graphics.setScissor(self.x + g.skin.margin, self.y + g.skin.margin, self.w - g.skin.margin * 2, self.h - g.skin.margin * 2)
	for i=1, #self.bars do
		local bar = self.bars[i]
		g.components.bar_draw.draw(bar)
	end
	love.graphics.setScissor()
end

setmetatable(league_table, {_call = function(_, ...) return league_table.new(...) end})

return league_table