local game_inbox = {}
game_inbox.name = "Game Inbox"

function game_inbox:init()
	self.__z = 1
	--
	g.console:log("game_inbox:init")
end

function game_inbox:added()
	local x, y, w, h = g.skin.screen.x + g.skin.margin, g.skin.screen.y + g.skin.margin, g.skin.screen.w - g.skin.margin * 2, g.skin.screen.h - g.skin.margin * 2
	local left_w = math.floor(g.skin.screen.w * .25 + .5) - g.skin.margin * 1.5
	local right_w = g.skin.screen.w - left_w - g.skin.margin * 3
	--
	self.panel1 = g.ui.panel.new(g.skin.screen.x + g.skin.margin, g.skin.screen.y + g.skin.margin, left_w, g.skin.screen.h - g.skin.margin * 2)
	self.panel1:set_colors(g.skin.components.color1, g.skin.components.color3)
	self.panel2 = g.ui.panel.new(self.panel1.x + self.panel1.w + g.skin.margin, g.skin.screen.y + g.skin.margin, right_w, g.skin.screen.h - g.skin.margin * 2)
	self.panel2:set_colors(g.skin.components.color1, g.skin.components.color3)
	--
	g.tween_alpha()
	self:set()
end

function game_inbox:update(dt)

end

function game_inbox:draw()
	self.panel1:draw()
	self.panel2:draw()
end

function game_inbox:set()
	--
	g.ribbon:set_game("Message Inbox")
end

function game_inbox:keypressed(k, ir)
	if g.ribbon.searchbox.focus then return end
end

function game_inbox:mousepressed(x, y, b)

end

function game_inbox:mousereleased(x, y, b)

end

return game_inbox