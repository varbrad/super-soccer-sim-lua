local navbar = {}
navbar.name = "Navbar"

function navbar:init()
	self.__z = 3
	--
	g.console:log("navbar:init")
end

function navbar:added()

end

function navbar:update(dt)

end

function navbar:draw()
	love.graphics.setColor(g.skin.colors[1])
	love.graphics.rectangle("fill", g.skin.navbar.x, g.skin.navbar.y, g.skin.navbar.w, g.skin.navbar.h)
end

return navbar