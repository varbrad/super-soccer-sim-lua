local league_table = {}
league_table.__index = league_table
league_table.__type = "Component.LeagueTable"

local rect = 1

local styles = {
	full = { "HP", "HW", "HD", "HL", "HGF", "HGA", "HGD", "HPts", 3,
			 "AP", "AW", "AD", "AL", "AGF", "AGA", "AGD", "APts", 3,
			 { "P", rect }, { "W", rect }, { "D", rect }, { "L", rect }, { "GF", rect }, { "GA", rect }, { "GD", rect }, { "Pts", rect } };
	default = { "P", "W", "D", "L", "GF", "GA", "GD", "Pts" };
	small = { "P", "GD", "Pts" };
}

local function color_copy(c) return {c[1], c[2], c[3], c[4] or 255} end

function league_table.new(x, y, w, h)
	local lt = {}
	setmetatable(lt, league_table)
	lt.x, lt.y, lt.w, lt.h = x or 0, y or 0, w or 10, h or 10
	lt.panel = g.ui.panel.new(lt.x, lt.y, lt.w, lt.h)
	lt.panel:set_colors(g.skin.components.color1, g.skin.components.color3)
	lt:set()
	return lt
end

function league_table:set(league, style_type, pre_sort, sortable)
	self.flux = g.flux:group()
	local teams, style = league and league.teams or nil, style_type and styles[style_type] or nil
	local pre_sort, sortable = pre_sort~=false and true or false, sortable~=false and true or false
	self.league, self.teams, self.style, self.sort_criteria = league, teams, style, nil
	self.bars, self.buttons = {}, {}
	if not league or not style then return end
	-- Sort the league table for maximum goodness if pre_sort==true
	if pre_sort then g.db_manager.sort_league(league) end
	local header = self:get_header(league, style, sortable) -- Gets the header and sets the sorting button functions
	--
	local x, y, w, h = self.x + g.skin.margin, self.y + g.skin.margin, self.w - g.skin.margin * 2, g.skin.bars.h
	for i=1, #teams do
		local team = teams[i]
		local pos = team.season.stats.pos
		local bar = { x = x, y = y + i * h, w = w, h = h, alpha = g.skin.bars.alpha }
		bar.labels, bar.rects, bar.images = {}, {}, {}
		bar.team = team
		bar.color = i%2==0 and color_copy(g.skin.bars.color1) or color_copy(g.skin.bars.color3)
		bar.label_color = g.skin.bars.color2
		-- Colorise promotion/relegation bars
		if league.promoted >= pos or pos==1 then
			bar.color[2] = bar.color[2] + 70
		elseif league.promoted + league.playoffs >= pos then
			bar.color[1], bar.color[2] = bar.color[1] + 70, bar.color[2] + 35
		elseif league.relegated > #league.teams - pos then
			bar.color[1] = bar.color[1] + 70
		elseif league.relegated + league.r_playoffs > #league.teams - pos then
			bar.color[1] = bar.color[1] + 50
		end
		-- Standard 3 #, logo and name
		local w = g.skin.bars.column_size
		local iw, ih = g.skin.bars.img_size, g.skin.bars.img_size
		local regular, semibold = g.skin.bars.font[2], g.skin.bars.font[3]
		local pos_label = { text = pos..".", x = g.skin.margin, y = g.skin.bars.ty, w = w, align = "right", font = semibold }
		table.insert(bar.labels, pos_label)
		local logo = g.image.new("logos/128/"..team.id..".png", { mipmap = true, w = iw, h = iw } )
		logo.x, logo.y = pos_label.x + pos_label.w + g.skin.img_margin, g.skin.bars.iy
		table.insert(bar.images, logo)
		local name = { text = team.short_name, x = logo.x + logo.w + g.skin.img_margin, y = g.skin.bars.ty, font = regular }
		if team.id == g.vars.player.team_id then name.color = g.skin.colors[3]
		elseif team.id == g.vars.view.team_id then name.color = g.skin.colors[2] end
		local btn = g.ui.button.new("", { x = bar.x + name.x, y = bar.y + name.y, w = g.font.width(name.text, name.font), h = g.font.height(name.font) } )
		btn.on_enter = function(b) name.underline = true end
		btn.on_exit = function(b) name.underline = false end
		btn.on_release = function(b) g.vars.view.team_id = team.id; g.state.switch(g.states.club_overview) end
		btn.visible = false
		btn.follow_bar, btn.follow_label = bar, name
		table.insert(self.buttons, btn)
		table.insert(bar.labels, name)
		-- Now lets add the custom stuff (*sigh*)
		local x = bar.w - g.skin.margin
		for i = #style, 1, -1 do
			local item = style[i]
			if type(item)=="string" then
				x = x - w
				local value = tostring(team.season.stats[string.lower(item)])
				if (item=="GD" or item=="HGD" or item=="AGD") and tonumber(value) > 0 then value = "+" .. value end
				local label = { text = value, x = x, y = g.skin.bars.ty, w = w, align = "center", font = semibold }
				table.insert(bar.labels, label)
			elseif type(item)=="number" then
				x = x - g.skin.margin * item
			elseif type(item)=="table" then
				x = x - w
				local func = item[2]
				if func == rect then
					local value = tostring(team.season.stats[string.lower(item[1])])
					if (item[1]=="GD" or item[1]=="HGD" or item[1]=="AGD") and tonumber(value) > 0 then value = "+" .. value end
					local label = { text = value, x = x, y = g.skin.bars.ty, w = w, align = "center", font = semibold }
					local rect = { x = x, y = 0, w = w, h = g.skin.bars.h, color = bar.color, alpha = bar.alpha }
					table.insert(bar.labels, label)
					table.insert(bar.rects, rect)
				end
			end
		end
		table.insert(self.bars, bar)
	end
	--
	table.insert(self.bars, header)
end

function league_table:update(dt)
	self.flux:update(dt)
	for i=1, #self.buttons do
		self.buttons[i]:update(dt)
		if self.buttons[i].follow_bar then
			local btn = self.buttons[i]
			btn.x, btn.y = btn.follow_bar.x + btn.follow_label.x, btn.follow_bar.y + btn.follow_label.y
		end
	end
end

function league_table:draw()
	self.panel:draw()
	for i=1, #self.bars do g.components.bar_draw.draw(self.bars[i]) end
	for i=1, #self.buttons do self.buttons[i]:draw() end
end

function league_table:mousepressed(x, y, b)
	for i=1, #self.buttons do self.buttons[i]:mousepressed(x, y, b) end
end

function league_table:mousereleased(x, y, b)
	for i=1, #self.buttons do self.buttons[i]:mousereleased(x, y, b) end
end

--
function league_table:get_header(league, style, sortable)
	local header = {
		x = self.x + g.skin.margin,
		y = self.y + g.skin.margin,
		w = self.w - g.skin.margin * 2,
		h = g.skin.bars.h,
		color = league.color2,
		label_color = league.color1,
		alpha = g.skin.bars.alpha,
		header = true,
		labels = {},
		images = {},
		rects = {}
	}
	local font = g.skin.bars.font[1]
	local pos = { text = "#", x = g.skin.margin, y = g.skin.bars.ty, w = g.skin.bars.column_size, align = "right", font = font }
	table.insert(header.labels, pos)
	local logo = g.image.new("logos/128/"..league.flag..league.level..".png", {mipmap = true, w = g.skin.bars.img_size, h = g.skin.bars.img_size})
	logo.x, logo.y = pos.x + pos.w + g.skin.img_margin, g.skin.bars.iy
	table.insert(header.images, logo)
	local name = { text = league.short_name, x = logo.x + logo.w + g.skin.img_margin, y = g.skin.bars.ty, font = font }
	table.insert(header.labels, name)
	--
	header.columns = {} -- Also add the sortable columns below to this array! { label = label, rect = rect } -- This format for example
	local x = header.w - g.skin.margin -- Starting x
	for i = #style, 1, -1 do
		local item = style[i]
		if type(item)=="table" then item = item[1] end
		if type(item)=="string" then
			x = x - g.skin.bars.column_size
			local label = { text = item, x = x, y = g.skin.bars.ty, w = g.skin.bars.column_size, align = "center", font = font }
			local rect = { x = x, y = 0, w = g.skin.bars.column_size, h = g.skin.bars.h, color = league.color2, alpha = g.skin.bars.alpha - 30 }
			table.insert(header.labels, label)
			table.insert(header.rects, rect)
			table.insert(header.columns, { label = label, rect = rect })
			local btn = g.ui.button.new("", { x = header.x + x, y = header.y, w = g.skin.bars.column_size, h = g.skin.bars.h })
			btn.on_enter = function(b)
				self.flux:to(rect, g.skin.tween.time, { alpha = g.skin.bars.alpha }):ease(g.skin.tween.type)
			end
			btn.on_exit = function(b)
				self.flux:to(rect, g.skin.tween.time, { alpha = g.skin.bars.alpha - 30 }):ease(g.skin.tween.type)
			end
			btn.on_click = function(b)
				local ascending = false
				if self.sort_criteria == item then ascending = true end
				if self.sort_criteria == item and self.same_click then
					self:sort_bars("pos", true)
					self.sort_criteria = nil
					self.same_click = nil
					for i=1, #header.columns do header.columns[i].rect.color = league.color2 end
				else
					self:sort_bars(item, ascending)
					if self.sort_criteria == item then
						self.sort_criteria = item
						self.same_click = true
					else
						self.sort_criteria = item
						self.same_click = false
					end
					for i=1, #header.columns do header.columns[i].rect.color = league.color2 end
					rect.color = ascending and g.skin.red or g.skin.green
				end
			end
			btn.visible = false
			table.insert(self.buttons, btn)
		elseif type(item)=="number" then
			x = x - g.skin.margin * item
		end
	end
	--
	return header
end
--

function league_table:sort_bars(criteria, descending)
	criteria = string.lower(criteria)
	-- Do tweening magic here! Dont reset the bars!
	local bars = self.bars
	-- So now we need to sort the actual data in the self.teams object to the criteria
	table.sort(self.league, g.db_manager.sort_league) -- First standard sort to not get ridiculous changing
	if criteria~="pos" then
		table.sort(self.teams, function(a, b) if a.season.stats[criteria] < b.season.stats[criteria] then return descending elseif a.season.stats[criteria] > b.season.stats[criteria] then return not descending elseif a.season.stats.pos < b.season.stats.pos then return not descending else return descending end end)
	else
		table.sort(self.teams, function(a, b) return a.season.stats.pos < b.season.stats.pos end)
	end
	--
	local lookup = {}
	for i=1, #self.teams do lookup[self.teams[i].id] = i end
	for i=1, #bars do
		local bar = bars[i]
		if not bar.header then
			local index = lookup[bar.team.id]
			local new_y = self.y + g.skin.margin + index * g.skin.bars.h
			self.flux:to(bar, g.skin.tween.time, { y = new_y }):ease(g.skin.tween.type)
		end
	end
end

return league_table