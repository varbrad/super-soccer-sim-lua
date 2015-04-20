g = {}
--
function love.load()
	g.version = require "version" -- Game version!
	-- Standard setup stuff
	g.width, g.height, g.flags = love.window.getMode()
	g.v_major, g.v_minor, g.v_revision, g.v_codename = love.getVersion()
	io.stdout:setvbuf("no")
	love.keyboard.setKeyRepeat(true)
	love.graphics.setDefaultFilter("linear","linear")
	love.graphics.setLineStyle("smooth")
	-- Libs
	g.csv = require "libs.csv"
	g.state = require "libs.state"
	g.timer = require "libs.timer"
	-- Src
	g.skin = require "src.skin"
	--
	g.states = {
		console = require "states.console";
		splash = require "states.splash";
	}
	-- Common alliases for states
	g.console = g.states.console
	--
	love.graphics.setBackgroundColor(g.skin.colors[1])
	--
	g.state.add(g.states.splash)
	g.state.add(g.states.console)

	--
	g.console:print("love.load finished", g.skin.green)
	g.console:hr()
end

function love.update(dt)
	g.timer.update(dt)
	--
	for i, state in g.state.states() do
		if state.update then state:update(dt) end
	end
end

function love.draw()
	for i, state in g.state.states_z() do
		if state.draw then state:draw() end
	end
end

function love.keypressed(k,ir)
	if k=="escape" then
		love.event.quit()
	end
	--
	for i, state in g.state.states() do
		if state.keypressed then state:keypressed(k,ir) end
	end
end

function love.mousepressed(x, y, b)
	for i, state in g.state.states() do
		if state.mousepressed then state:mousepressed(x, y, b) end
	end
end

-- New functions
function love.graphics.hexToRgb(hex)
	return { tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6)) }
end

function love.graphics.setColorAlpha(color,alpha)
	love.graphics.setColor(color[1],color[2],color[3],alpha)
end

-- Functions

function g.load_database(path)

end