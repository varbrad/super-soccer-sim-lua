function love.load()
	g = {}
	-- Standard setup stuff
	g.width, g.height, g.flags = love.window.getMode()
	io.stdout:setvbuf("no")
	love.keyboard.setKeyRepeat(true)
	love.graphics.setDefaultFilter("linear","linear")
	love.graphics.setLineStyle("smooth")
	-- Libs
	g.State = require "libs.state"
	-- Skin8
	g.skin = require "skin"
	--
	g.states = {}
	--

end

function love.update(dt)
	--
end

function love.keypressed(k,ir)
	if k=="escape" then
		love.event.quit()
	end
end