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
	g.font = require "libs.font"
	g.image = require "libs.image"
	g.state = require "libs.state"
	g.timer = require "libs.timer"
	g.ui = require "libs.ui"
	-- Src
	g.db_manager = require "src.db_manager"
	g.skin = require "src.skin"
	--
	g.states = {
		background = require "states.background";
		console = require "states.console";
		navbar = require "states.navbar";
		overview = require "states.overview";
		ribbon = require "states.ribbon";
	}
	-- Common alliases for states
	g.console = g.states.console
	g.ribbon = g.states.ribbon
	g.navbar = g.states.navbar
	--
	love.graphics.setBackgroundColor(g.skin.colors[1])
	--
	g.state.add(g.states.background)
	g.state.add(g.states.console)
	--
	g.state.add(g.states.navbar)
	g.state.add(g.states.ribbon)
	g.state.add(g.states.overview)
	--
	g.mouse = {}
	g.mouse.x = -1
	g.mouse.y = -1
	g.mouse.cursor = {}
	g.mouse.cursor.arrow = love.mouse.getSystemCursor("arrow")
	g.mouse.cursor.hand = love.mouse.getSystemCursor("hand")
	love.mouse.setCursor(g.mouse.cursor.arrow)
	--
	g.console:print("love.load finished", g.skin.green)
	g.console:hr()
end

function love.update(dt)
	g.timer.update(dt)
	g.mouse.x, g.mouse.y = love.mouse.getPosition()
	g.ui.set_mouse_position(g.mouse.x, g.mouse.y)
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
	if hex==nil then return nil end
	return { tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6)), tonumber("0x"..hex:sub(7,8)) }
end

function love.graphics.setColorAlpha(color,alpha)
	love.graphics.setColor(color[1],color[2],color[3],alpha)
end

function love.graphics.gradient(colors)
	local direction = colors.direction or "h"
	if direction=="h" then
		direction = true
	else
		direction = false
	end
	--
	local result = love.image.newImageData(direction and 1 or #colors, direction and #colors or 1)
	for i, color in ipairs(colors) do
		local x, y
		if direction then
			x, y = 0, i - 1
		else
			x, y = i - 1, 0
		end
		result:setPixel(x, y, color[1], color[2], color[3], color[4] or 255)
	end
	result = love.graphics.newImage(result)
	result:setFilter("linear", "linear")
	return result
end