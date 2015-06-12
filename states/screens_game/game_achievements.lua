local game_achievements = {}
game_achievements.name = "Game Youth"

function game_achievements:init()
	self.__z = 1
	--
	g.console:log("game_achievements:init")
end

function game_achievements:added()
	local x, y, w, h = g.skin.screen.x + g.skin.margin, g.skin.screen.y + g.skin.margin, g.skin.screen.w - g.skin.margin * 2, g.skin.screen.h - g.skin.margin * 2
	--
	self.panel = g.ui.panel.new(g.skin.screen.x + g.skin.margin, g.skin.screen.y + g.skin.margin, w, g.skin.screen.h - g.skin.margin * 2)
	self.panel:set_colors(g.skin.components.color1, g.skin.components.color3)
	--
	g.tween_alpha()
	self:set()
end

function game_achievements:update(dt)

end

function game_achievements:draw()
	self.panel:draw()
	--
	for i = 1, #self.bars do
		g.components.bar_draw.draw(self.bars[i], 0, 0, g.tween.t_alpha)
	end
end

function game_achievements:set()
	self.bars = {}
	local achievements = g.achievements.list()
	for i = 1, #achievements do
		local a = achievements[i]
		--
		local bar = { x = self.panel.x + g.skin.margin, y = self.panel.y + g.skin.margin + (i-1) * g.skin.bars.h, w = self.panel.w - g.skin.margin * 2, h = g.skin.bars.h, alpha = g.skin.bars.alpha }
		bar.color = i%2==0 and g.skin.bars.color1 or g.skin.bars.color3
		bar.label_color = g.skin.bars.color2
		--
		local title = { text = a.title, x = g.skin.margin, y = g.skin.bars.ty, font = g.skin.bars.font[1] }
		local desc = { text = a.desc, x = 400, y = g.skin.bars.ty, font = g.skin.bars.font[2] }
		--
		if g.achievements.is_unlocked(a.name) then
			bar.color = g.skin.colors[3]
		end
		--
		bar.labels = { title, desc }
		--
		table.insert(self.bars, bar)
	end
	--
	g.ribbon:set_game("Achievements")
end

function game_achievements:keypressed(k, ir)
	if g.ribbon.searchbox.focus then return end
end

function game_achievements:mousepressed(x, y, b)

end

function game_achievements:mousereleased(x, y, b)

end

return game_achievements