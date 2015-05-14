local club_select = {}
club_select.name = "Club Select"

function club_select:init()
	self.__z = 1
	--
	g.console:log("club_select:init")
end

function club_select:added()
	local x, y, w, h = g.skin.tab, g.skin.tab, g.width - g.skin.tab * 2, g.height - g.skin.tab * 2
	self.panel = g.ui.panel.new(x, y, w, h)
	self.panel:set_colors(g.skin.components.color1, g.skin.components.color3)
	--
	self.league = g.db_manager.league_dict[1]
	self.team = nil
	self.buttons = {}
	self:set()
end

function club_select:set()
	table.sort(self.league.teams, g.db_manager.sort_long_name)
	self.bars = {}
	--
	for i=1, #self.league.teams do
		local team = self.league.teams[i]
		local bar = { x = self.panel.x + g.skin.margin, y = self.panel.y + g.skin.margin + (i-1) * g.skin.bars.h, w = self.panel.w - g.skin.margin * 2, h = g.skin.bars.h, alpha = g.skin.bars.alpha }
		bar.color = i%2==0 and g.skin.bars.color1 or g.skin.bars.color3
		bar.label_color = g.skin.bars.color2
		bar.c1, bar.c2, bar.c3 = bar.color, team.color1, team.color2
		bar.labels, bar.images = {}, {}
		local team_logo = g.image.new("logos/128/"..team.id..".png", {mipmap=true, w = g.skin.bars.img_size, h = g.skin.bars.img_size, x = g.skin.margin, y = g.skin.bars.iy})
		local team_name = { text = team.long_name, x = team_logo.x + team_logo.w + g.skin.margin, y = g.skin.bars.ty, font = g.skin.bars.font[2] }
		table.insert(bar.labels, team_name)
		table.insert(bar.images, team_logo)
		local btn = g.ui.button.new("", { x = bar.x, y = bar.y, w = bar.w, h = bar.h })
		btn.on_enter = function(b) bar.color, bar.label_color = bar.c2, bar.c3 end
		btn.on_exit = function(b) bar.color, bar.label_color = bar.c1, g.skin.bars.color2 end
		btn.on_release = function(b)
			g.db_manager.begin()
			-- Setup g.vars (default values are set in g.db_manager)
			g.vars.player.team_id = team.id
			g.vars.view.team_id = team.id
			g.vars.view.league_id = team.league.id
			--
			g.state.add(g.states.navbar)
			g.state.add(g.states.ribbon)
			g.state.add(g.states.club_overview)
			g.in_game = true
			g.state.remove(self)
		end
		table.insert(self.buttons, btn)
		table.insert(self.bars, bar)
	end
end

function club_select:update(dt)
	for i=1, #self.buttons do self.buttons[i]:update(dt) end
end

function club_select:draw()
	self.panel:draw()
	for i=1, #self.bars do g.components.bar_draw.draw(self.bars[i]) end
end

function club_select:mousepressed(x, y, b)
	for i=1, #self.buttons do self.buttons[i]:mousepressed(x, y, b) end
end

function club_select:mousereleased(x, y, b)
	for i=1, #self.buttons do self.buttons[i]:mousereleased(x, y, b) end
end

return club_select