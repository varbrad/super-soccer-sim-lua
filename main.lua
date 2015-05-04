g = {}
--
function love.load(args)
	print(args, #args, args[-1])
	g.version = require "version" -- Game version!
	-- Standard setup stuff
	g.width, g.height, g.flags = love.window.getMode()
	g.v_major, g.v_minor, g.v_revision, g.v_codename = love.getVersion()
	io.stdout:setvbuf("no")
	love.keyboard.setKeyRepeat(true)
	love.graphics.setDefaultFilter("linear","linear")
	love.graphics.setLineStyle("smooth")
	-- Write current os.time to a store file
	love.filesystem.write("store", os.time())
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
	-- Load components
	g.components = {
		bar_draw = require "components.bar_draw";
		fixture_group = require "components.fixture_group";
		fixture_list = require "components.fixture_list";
		league_table = require "components.league_table";
		result_grid = require "components.result_grid";
	}
	--
	g.states = {
		background = require "states.background";
		club_overview = require "states.club_overview";
		console = require "states.console";
		league_overview = require "states.league_overview";
		league_result_grid = require "states.league_result_grid";
		league_summary = require "states.league_summary";
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
	g.ui.__defaultFont = g.font.get(g.skin.ui.button.font)
	g.ui.panel.__defaultAlpha = g.skin.ui.panel.alpha
	--
	g.vars = {}
	g.vars.week = 1
	g.vars.view = {}
	g.vars.view.league_id = 1
	g.vars.view.team_id = 1
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
	elseif k=="f1" then
		g.state.switch(g.states.club_overview)
	elseif k=="f2" then
		g.state.switch(g.states.league_overview)
	elseif k=="f3" then
		g.state.switch(g.states.league_summary)
	elseif k=="f4" then
		g.state.switch(g.states.league_result_grid)
	elseif k=="f8" then
		g.console:print(g.state.order(), g.skin.red)
	elseif k=="f9" then
		g.console:print(g.state.z_order(), g.skin.red)
	elseif k==" " then
		g.db_manager.advance_week()
		g.state.refresh_all()
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

function love.mousereleased(x, y, b)
	for i, state in g.state.states() do
		if state.mousereleased then state:mousereleased(x, y, b) end
	end
end

-- New functions
function love.graphics.hexToRgb(hex)
	if hex==nil then return nil end
	return { tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6)), tonumber("0x"..hex:sub(7,8)) }
end

function love.graphics.darken(color)
	return { color[1] * g.skin.darken, color[2] * g.skin.darken, color[3] * g.skin.darken, color[4] or 255}
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

function love.graphics.roundrect(mode, x, y, w, h, tl, tr, bl, br)
	tr, bl, br = tr or tl, bl or tl, br or tl
	local r = tl
	local g = love.graphics
	x, y, h, r = math.floor(x+.5), math.floor(y+.5), math.floor(h+.5), math.floor(r+.5)
	-- Draw inner rect
	g.rectangle(mode,x+r,y+r,w-r*2,h-r*2)
	-- Draw left, right, top, bottom rects
	g.rectangle(mode,x,y+r,r,h-r*2)
	g.rectangle(mode,x+w-r,y+r,r,h-r*2)
	g.rectangle(mode,x+r,y,w-r*2,r)
	g.rectangle(mode,x+r,y+h-r,w-r*2,r)
	-- Draw arcs (top left, top right, bottom right, bottom left
	g.arc(mode,x+r,y+r,r,math.pi,math.pi*1.5)
	g.arc(mode,x+w-r,y+r,r,0,-math.pi*.5)
	g.arc(mode,x+w-r,y+h-r,r,0,math.pi*.5)
	g.arc(mode,x+r,y+h-r,r,math.pi*.5,math.pi)
end