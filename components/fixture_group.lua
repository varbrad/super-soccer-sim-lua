local fixture_group = {}
fixture_group.__index = fixture_group
fixture_group.__type = "Component.FixtureGroup"

function fixture_group.new(x, y, w, h, league, round)
	local fg = {}
	setmetatable(fg, fixture_group)
	fg.x, fg.y, fg.w, fg.h = x or 0, y or 0, w or 10, h or 10
	fg.panel = g.ui.panel.new(fg.x, fg.y, fg.w, fg.h)
	fg.panel:set_colors(g.skin.components.color1, g.skin.components.color3)
	fg:set(league, round)
	return fg
end

function fixture_group:set(league, round, is_results)
	self.league, self.round = league, round
	self.bars, self.buttons = {}, {}
end

function fixture_group:update(dt)
	for i=1, #self.buttons do self.buttons[i]:update(dt) end
end

function fixture_group:draw()
	self.panel:draw()
	love.graphics.setScissor(self.panel.x+g.skin.margin, self.panel.y+g.skin.margin, self.panel.w-g.skin.margin*2, self.panel.h-g.skin.margin*2)
	for i=1, #self.bars do
		local bar = self.bars[i]
		g.components.bar_draw.draw(bar)
	end
	love.graphics.setScissor()
end

function fixture_group:mousepressed(x, y, b)
	for i=1, #self.buttons do self.buttons[i]:mousepressed(x, y, b) end
end

function fixture_group:mousereleased(x, y, b)
	for i=1, #self.buttons do self.buttons[i]:mousereleased(x, y, b) end
end

setmetatable(fixture_group, {_call = function(_, ...) return fixture_group.new(...) end})

return fixture_group