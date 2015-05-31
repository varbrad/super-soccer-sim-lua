local game_debug = {}
game_debug.name = "Game Debug"

function game_debug:init()
	self.__z = 1
	--
	g.console:log("game_debug:init")
end

function game_debug:added()
	g.tween_alpha()
	self:set()
end

function game_debug:update(dt)
end

function game_debug:draw()

end

function game_debug:set()
	self.team = g.database.get_player_team()
	--
	g.ribbon:set_team(self.team)
end

function game_debug:keypressed(k, ir)
	if g.ribbon.searchbox.focus then return end
end

function game_debug:mousepressed(x, y, b)

end

function game_debug:mousereleased(x, y, b)

end

return game_debug