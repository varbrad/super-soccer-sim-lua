local game_debug = {}
game_debug.name = "Game Debug"

function game_debug:init()
	self.__z = 1
	--
	g.console:log("game_debug:init")
end

function game_debug:added()
	local x, y, w, h = g.skin.screen.x + g.skin.margin, g.skin.screen.y + g.skin.margin, g.skin.screen.w - g.skin.margin * 2, g.skin.screen.h - g.skin.margin * 2
	self.player_list = g.components.player_list.new(x, y, w, h)
	--
	g.tween_alpha()
	self:set()
end

function game_debug:update(dt)
	
end

function game_debug:draw()
	self.player_list:draw(g.tween.t_alpha)
end

function game_debug:set()
	self.player_list:set()
	--
	g.ribbon:set_team(g.database.get_player_team())
end

function game_debug:keypressed(k, ir)
	if g.ribbon.searchbox.focus then return end
end

function game_debug:mousepressed(x, y, b)

end

function game_debug:mousereleased(x, y, b)

end

return game_debug