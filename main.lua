g = {}
--
function love.load()
	g.version = 1 -- Game version!
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
	-- Skin
	g.skin = require "skin"
	--
	g.states = {
		splash = require "states.splash";
	}
	--
	love.graphics.setBackgroundColor(g.skin.colors[1])
	--
	g.state.add(g.states.splash)
end

function love.update(dt)
	g.timer.update(dt)
	--
	for i=1, g.state.length() do
		local s = g.state.get_state(i)
		if s.update then s:update(dt) end
	end
end

function love.draw()
	for i=1, g.state.length() do
		local s = g.state.get_state(i)
		if s.draw then s:draw() end
	end
end

function love.keypressed(k,ir)
	if k=="escape" then
		love.event.quit()
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