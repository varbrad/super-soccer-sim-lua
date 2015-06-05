local game_squad = {}
game_squad.name = "Game Debug"

function game_squad:init()
	self.__z = 1
	--
	g.console:log("game_squad:init")
end

function game_squad:added()
	local x, y, w, h = g.skin.screen.x + g.skin.margin, g.skin.screen.y + g.skin.margin, g.skin.screen.w - g.skin.margin * 2, g.skin.screen.h - g.skin.margin * 2
	local half_w = math.floor((w-g.skin.margin)/2+.5)
	self.player_list = g.components.player_list.new(x, y, half_w, h)
	--
	g.tween_alpha()
	self:set()
end

function game_squad:update(dt)

end

function game_squad:draw()
	self.player_list:draw(g.tween.t_alpha)
end

function game_squad:set()
	self.player_list:set()
	--
	g.ribbon:set_team(g.database.get_player_team())
end

function game_squad:keypressed(k, ir)
	if g.ribbon.searchbox.focus then return end
end

function game_squad:mousepressed(x, y, b)

end

function game_squad:mousereleased(x, y, b)

end

return game_squad