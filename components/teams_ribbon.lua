local teams_ribbon = {}
teams_ribbon.__index = teams_ribbon
teams_ribbon.__type = "Component.TeamsRibbon"

function teams_ribbon.new(x, y, w, h)
	local rg = {}
	setmetatable(rg, teams_ribbon)
	rg.x, rg.y, rg.w, rg.h = x or 0, y or 0, w or 10, h or 10
	rg.flux = g.flux.group()
	rg.panel = g.ui.panel.new(rg.x, rg.y, rg.w, rg.h)
	rg.panel:set_colors(g.skin.components.color1, g.skin.components.color3)
	rg:set()
	return rg
end

function teams_ribbon:set(teams, sort)
	self.teams, self.text = teams, text
	self.bar, self.buttons = {}, {}
	if teams==nil then return end
	if sort then table.sort(self.teams, g.db_manager.sort_name) end
	self.bar = { x = self.x + g.skin.margin, y = self.y + g.skin.margin, w = self.w - g.skin.margin * 2, h = self.h - g.skin.margin * 2, color = g.skin.bars.color1, alpha = g.skin.bars.alpha }
	local working_area = self.w - g.skin.margin * 2
	local columns = math.floor(working_area / #teams + .5)
	local height = self.h - g.skin.margin * 2
	local image_height = height - g.skin.margin * 2
	local ix = math.floor(columns/2 - image_height/2 + .5)
	self.bar.images, self.bar.rects = {}, {}
	for i=1, #teams do
		local t = teams[i]
		local img = g.image.new("logos/128/"..t.id..".png", {w = image_height, h = image_height, x = columns * (i-1) + ix, y = g.skin.margin})
		local rect = { x = img.x - ix, y = 0, w = columns, h = height, color = t.color1, alpha = 0 }
		table.insert(self.bar.images, img)
		table.insert(self.bar.rects, rect)
		local btn = g.ui.button.new("", { w = rect.w, h = rect.h, x = self.bar.x + rect.x, y = self.bar.y + rect.y })
		btn.on_enter = function() self.flux:to(rect, g.skin.tween.time, {alpha = g.skin.bars.alpha}):ease(g.skin.tween.type_in) end
		btn.on_exit = function() self.flux:to(rect, g.skin.tween.time, {alpha = 0}):ease(g.skin.tween.type_out) end
		btn.on_release = function() g.vars.view.team_id = t.id; g.state.switch(g.states.club_overview) end
		table.insert(self.buttons, btn)
	end
end

function teams_ribbon:update(dt)
	for i=1, #self.buttons do self.buttons[i]:update(dt) end
	self.flux:update(dt)
end

function teams_ribbon:draw()
	self.panel:draw()
	love.graphics.setScissor(self.x + g.skin.margin, self.y + g.skin.margin, self.w - g.skin.margin * 2, self.h - g.skin.margin * 2)
	g.components.bar_draw.draw(self.bar)
	love.graphics.setScissor()
end

function teams_ribbon:mousepressed(x, y, b)
	for i=1, #self.buttons do self.buttons[i]:mousepressed(x, y, b) end
end

function teams_ribbon:mousereleased(x, y, b)
	for i=1, #self.buttons do self.buttons[i]:mousereleased(x, y, b) end
end

setmetatable(teams_ribbon, {_call = function(_, ...) return teams_ribbon.new(...) end})

return teams_ribbon