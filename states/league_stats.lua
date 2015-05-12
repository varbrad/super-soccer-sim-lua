local league_stats = {}
league_stats.name = "League Stats"

function league_stats:init()
	self.__z = 1
	--
	g.console:log("league_stats:init")
end

function league_stats:added()
	local total_w = g.skin.screen.w - g.skin.margin * 2
	local total_columns = 7
	local split_w = (total_w - g.skin.margin * (total_columns-1)) / total_columns
	self.buttons = {}
	self.buttons[1] = g.ui.button.new("Sort by Wins", { x = g.skin.screen.x + g.skin.margin, y = g.skin.screen.y + g.skin.margin, w = split_w})
	self.buttons[2] = g.ui.button.new("Sort by Draws", { x = self.buttons[1].x + self.buttons[1].w + g.skin.margin, y = self.buttons[1].y, w = split_w})
	self.buttons[3] = g.ui.button.new("Sort by Losses", { x = self.buttons[2].x + self.buttons[2].w + g.skin.margin, y = self.buttons[1].y, w = split_w})
	self.buttons[4] = g.ui.button.new("Sort by Goals For", { x = self.buttons[3].x + self.buttons[3].w + g.skin.margin, y = self.buttons[1].y, w = split_w})
	self.buttons[5] = g.ui.button.new("Sort by Goals Against", { x = self.buttons[4].x + self.buttons[4].w + g.skin.margin, y = self.buttons[1].y, w = split_w})
	self.buttons[6] = g.ui.button.new("Sort by Goal Difference", { x = self.buttons[5].x + self.buttons[5].w + g.skin.margin, y = self.buttons[1].y, w = split_w})
	self.buttons[7] = g.ui.button.new("Sort by Classification", { x = self.buttons[6].x + self.buttons[6].w + g.skin.margin, y = self.buttons[1].y, w = split_w})
	--
	self.buttons[8] = g.ui.button.new("Sort by Home Wins", { x = self.buttons[1].x, y = self.buttons[1].y + self.buttons[1].h + g.skin.margin, w = split_w})
	self.buttons[9] = g.ui.button.new("Sort by Home Draws", { x = self.buttons[2].x, y = self.buttons[8].y, w = split_w})
	self.buttons[10] = g.ui.button.new("Sort by Home Losses", { x = self.buttons[3].x, y = self.buttons[8].y, w = split_w})
	self.buttons[11] = g.ui.button.new("Sort by Home Goals For", { x = self.buttons[4].x, y = self.buttons[8].y, w = split_w})
	self.buttons[12] = g.ui.button.new("Sort by Home Goals Against", { x = self.buttons[5].x, y = self.buttons[8].y, w = split_w})
	self.buttons[13] = g.ui.button.new("Sort by Home Goal Difference", { x = self.buttons[6].x, y = self.buttons[8].y, w = split_w})
	self.buttons[14] = g.ui.button.new("Sort by Home Points", { x = self.buttons[7].x, y = self.buttons[8].y, w = split_w})
	--
	self.buttons[15] = g.ui.button.new("Sort by Away Wins", { x = self.buttons[1].x, y = self.buttons[8].y + self.buttons[8].h + g.skin.margin, w = split_w})
	self.buttons[16] = g.ui.button.new("Sort by Away Draws", { x = self.buttons[2].x, y = self.buttons[15].y, w = split_w})
	self.buttons[17] = g.ui.button.new("Sort by Away Losses", { x = self.buttons[3].x, y = self.buttons[15].y, w = split_w})
	self.buttons[18] = g.ui.button.new("Sort by Away Goals For", { x = self.buttons[4].x, y = self.buttons[15].y, w = split_w})
	self.buttons[19] = g.ui.button.new("Sort by Away Goals Against", { x = self.buttons[5].x, y = self.buttons[15].y, w = split_w})
	self.buttons[20] = g.ui.button.new("Sort by Away Goal Difference", { x = self.buttons[6].x, y = self.buttons[15].y, w = split_w})
	self.buttons[21] = g.ui.button.new("Sort by Away Points", { x = self.buttons[7].x, y = self.buttons[15].y, w = split_w})
	--
	local vals = { {"W",true}, {"D",true}, {"L",true}, {"GF",true}, {"GA",true}, {"GD", true}, {"Pos",false},
					{"HW",true},{"HD",true},{"HL",true},{"HGF",true},{"HGA",true},{"HGD",true},{"HPts",true},
					{"AW",true},{"AD",true},{"AL",true},{"AGF",true},{"AGA",true},{"AGD",true},{"APts",true}}
	for i=1, #self.buttons do
		local btn = self.buttons[i]
		btn.on_release = function(this_btn)
			self.custom_value = { vals[i][1], vals[i][2] }
			if self.pressed_info.last_button == this_btn then
				self.custom_value[2] = self.pressed_info.flip_flop
				self.pressed_info.flip_flop = not self.pressed_info.flip_flop
			else
				g.console:log("different button")
				self.pressed_info.flip_flop = not vals[i][2]
				self.pressed_info.last_button = this_btn
			end
			self:set()
		end
	end
	--
	self.custom_value = {"Pos", false}
	self.pressed_info = { last_button = nil, flip_flop = false }
	--
	self.custom_table = g.components.league_table.new(g.skin.screen.x + g.skin.margin, self.buttons[#self.buttons].y + self.buttons[#self.buttons].h + g.skin.margin, g.skin.screen.w - g.skin.margin * 2, g.skin.screen.h - g.skin.margin * 2)
	self:set()
end

function league_stats:update(dt)
	for i=1, #self.buttons do self.buttons[i]:update(dt) end
	self.custom_table:update(dt)
end

function league_stats:draw()
	for i=1, #self.buttons do self.buttons[i]:draw() end
	self.custom_table:draw()
end

function league_stats:set()
	self.league = g.db_manager.league_dict[g.vars.view.league_id]
	--
	for i=1, #self.buttons do
		local btn = self.buttons[i]
		btn:set_colors(self.league.color2, self.league.color1, self.league.color3)
	end
	--
	self.custom_table:set(self.league, g.components.league_table.style_list.full, self.custom_value[1], self.custom_value[2])
	--
	g.ribbon:set_league(self.league)
end

function league_stats:mousepressed(x, y, b)
	for i=1, #self.buttons do self.buttons[i]:mousepressed(x, y, b) end
	self.custom_table:mousepressed(x, y, b)
end

function league_stats:mousereleased(x, y, b)
	for i=1, #self.buttons do self.buttons[i]:mousereleased(x, y, b) end
	self.custom_table:mousereleased(x, y, b)
end

return league_stats