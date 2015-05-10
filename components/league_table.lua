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

function league_table:set(league, style)
	self.league = league
	self.style = style or self.style or "default"
	self.bars = {}
	self.buttons = {}
	--
	if self.league==nil then return end
	--
	g.db_manager.sort_league(league)
	local header = { x = self.x + g.skin.margin, y = self.y + g.skin.margin, w = self.w - g.skin.margin * 2, h = g.skin.bars.h, color = self.league.color2, alpha = g.skin.bars.alpha }
	header.images = { g.image.new("logos/128/"..self.league.flag..self.league.level..".png", {mipmap = true, w = g.skin.bars.img_size, h = g.skin.bars.img_size, y = g.skin.bars.iy, x = g.skin.margin * 3 + 30})}
	header.labels = {
		{ text = "Pos",		x = g.skin.margin, y = g.skin.bars.ty, w = 30, align = "center", font = g.skin.bars.font[1], color = self.league.color1 };
		{ text = "Team",	x = g.skin.margin * 5 + 30 + g.skin.bars.img_size, y = g.skin.bars.ty, font = g.skin.bars.font[1], color = self.league.color1 };
	}
	local s_list = style_list[self.style]
	local x = header.w - g.skin.margin - g.skin.bars.column_size
	for i=1, #s_list do
		local item = s_list[i]
		if type(item)=="string" then
			table.insert(header.labels, { text = item, x = x, y = g.skin.bars.ty, font = g.skin.bars.font[1], color = self.league.color1, w = g.skin.bars.column_size, align = "center" })
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
		local team_name_color = team.id == g.vars.player.team_id and g.skin.colors[3] or g.skin.bars.color2 
		bar.labels = {
			{ text = pos..".", x = g.skin.margin, y = g.skin.bars.ty, w = 30, align = "right", font = g.skin.bars.font[3], color = g.skin.bars.color2 };
			{ text = team.short_name, x = g.skin.margin * 5 + 30 + g.skin.bars.img_size, y = g.skin.bars.ty, font = g.skin.bars.font[2], color = team_name_color, w = g.font.width(team.short_name, g.skin.bars.font[2]), h = g.font.height(g.skin.bars.font[2]) };
		}
		bar.rects = {}
		local btn = g.ui.button.new("", { w = bar.labels[2].w, h = bar.labels[2].h, x = bar.x + bar.labels[2].x, y = bar.y + bar.labels[2].y } )
		btn.on_enter = function(btn) bar.labels[2].underline = true end
		btn.on_exit = function(btn) bar.labels[2].underline = false end
		btn.on_release = function(btn) g.vars.view.team_id = team.id; g.state.switch(g.states.club_overview) end
		self.buttons[#self.buttons+1] = btn
		local stats = team.season.stats
		local x = bar.w - g.skin.margin - g.skin.bars.column_size
		for i=1, #s_list do
			local item = s_list[i]
			if type(item)=="string" then
				local stat = stats[string.lower(item)]
				if (item == "GD" or item == "AGD" or item == "HGD") and stat > 0 then stat = "+" .. stat end
				if item == "Pts" or item == "HPts" or item == "APts" then
					table.insert(bar.rects, { x = x, y = 0, w = g.skin.bars.column_size, h = g.skin.bars.h, color = bar.color, alpha = g.skin.bars.alpha })
				end
				table.insert(bar.labels, { text = stat, x = x, y = g.skin.bars.ty, font = g.skin.bars.font[3], color = g.skin.bars.color2, w = g.skin.bars.column_size, align = "center" })
				x = x - g.skin.margin - g.skin.bars.column_size
			elseif type(item)=="number" then
				x = x - g.skin.tab * item
			end
		end
		--
		table.insert(self.bars, bar)
	end
end

function league_table:highlight_team(team)
	if team==nil or team.id==g.vars.player.team_id then return end
	for i=1, #self.bars do
		local bar = self.bars[i]
		if bar.labels[2].text == team.short_name then
			bar.labels[2].color = g.skin.colors[2]
		end
	end
end

function league_table:update(dt)
	for i=1, #self.buttons do self.buttons[i]:update(dt) end
end

function league_table:draw()
	self.panel:draw()
	love.graphics.setScissor(self.x + g.skin.margin, self.y + g.skin.margin, self.w - g.skin.margin * 2, self.h - g.skin.margin * 2)
	for i=1, #self.bars do
		local bar = self.bars[i]
		g.components.bar_draw.draw(bar)
	end
	--for i=1, #self.buttons do self.buttons[i]:draw() end
	love.graphics.setScissor()
end

function league_table:mousepressed(x, y, b)
	for i=1, #self.buttons do self.buttons[i]:mousepressed(x, y, b) end
end

function league_table:mousereleased(x, y, b)
	for i=1, #self.buttons do self.buttons[i]:mousereleased(x, y, b) end
end

setmetatable(league_table, {_call = function(_, ...) return league_table.new(...) end})

return league_table