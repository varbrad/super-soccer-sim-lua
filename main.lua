g = {}
--
function love.load(args)
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
	g.flux = require "libs.flux"
	g.font = require "libs.font"
	g.image = require "libs.image"
	g.ser = require "libs.ser"
	g.state = require "libs.state"
	g.ui = require "libs.ui"
	g.utf8 = require "utf8"
	-- Src
	-- Load skin first
	g.skin = require "src.skin"
	g.achievements = require "src.achievements"
	g.board = require "src.board"
	g.database = require "src.database"
	g.engine = require "src.engine"
	g.math = require "src.math"
	g.message = require "src.message"
	g.names = require "src.names"
	g.players = require "src.players"
	g.settings = require "src.settings"
	g.shaders = require "src.shaders"
	-- Load components
	g.components = {
		bar_draw = require "components.bar_draw";
		fixture_group = require "components.fixture_group";
		fixture_list = require "components.fixture_list";
		league_table = require "components.league_table";
		player_list = require "components.player_list";
		result_grid = require "components.result_grid";
		team_league_history_graph = require "components.team_league_history_graph";
		team_league_pos_graph = require "components.team_league_pos_graph";
		teams_ribbon = require "components.teams_ribbon";
	}
	--
	g.states = {
		club_history = require "states.screens_club.club_history";
		club_overview = require "states.screens_club.club_overview";
		--
		game_achievements = require "states.screens_game.game_achievements";
		game_financial = require "states.screens_game.game_financial";
		game_inbox = require "states.screens_game.game_inbox";
		game_squad = require "states.screens_game.game_squad";
		game_youth = require "states.screens_game.game_youth";
		--
		league_full_table = require "states.screens_league.league_full_table";
		league_overview = require "states.screens_league.league_overview";
		league_past_winners = require "states.screens_league.league_past_winners";
		league_result_grid = require "states.screens_league.league_result_grid";
		league_stats = require "states.screens_league.league_stats";
		league_records = require "states.screens_league.league_records";
		--
		background = require "states.background";
		console = require "states.console";
		database_select = require "states.database_select";
		match_centre = require "states.match_centre";
		msgbox = require "states.msgbox";
		navbar = require "states.navbar";
		new_game = require "states.new_game";
		notification = require "states.notification";
		overview = require "states.overview";
		ribbon = require "states.ribbon";
		settings = require "states.settings";
	}
	--
	g.screen_groups = {
		{ g.states.club_overview, g.states.club_history };
		{ g.states.league_overview, g.states.league_stats, g.states.league_result_grid, g.states.league_past_winners, g.states.league_records };
	}
	-- Common alliases for states
	g.console = g.states.console
	g.ribbon = g.states.ribbon
	g.navbar = g.states.navbar
	g.notification = g.states.notification
	g.msgbox = g.states.msgbox
	--
	love.graphics.setBackgroundColor(g.skin.colors[1])
	g.shaders.init()
	--
	g.ui.__defaultFont = g.font.get(g.skin.ui.button.font)
	g.ui.panel.__defaultAlpha = g.skin.ui.panel.alpha
	--
	g.settings.load()
	--
	g.mouse = {}
	g.mouse.x = -1
	g.mouse.y = -1
	g.mouse.cursor = {}
	g.mouse.cursor.current = "arrow"
	g.mouse.cursor.arrow = love.mouse.getSystemCursor("arrow")
	g.mouse.cursor.hand = love.mouse.getSystemCursor("hand")
	g.mouse.cursor.ibeam = love.mouse.getSystemCursor("ibeam")
	love.mouse.setCursor(g.mouse.cursor.arrow)
	--`
	g.console:print("love.load finished", g.skin.green)
	g.console:hr()
	--
	g.tween = { t_alpha = 1 }
	--
	-- The canvas object everything gets drawn to, in order to use alpha-based shaders.
	-- This should never be drawn to or used anywhere else except main.lua
	g.canvas = love.graphics.newCanvas()
	--
	g.state.add(g.states.background) -- z = 0, navbar is 3, ribbon is 2 -- Shouldn't have any keypressed actions!
	g.state.add(g.states.msgbox) -- z = 7
	g.state.add(g.states.notification) -- z = 8 -- No Keypressed actions! 
	g.state.add(g.states.console) -- z = 9
	g.state.add(g.states.overview) -- z = 1 -- Keypressed actions are fine (Will be recieved last as active screen)
	-- All screens should be z = 1
end

function love.update(dt)
	g.mouse.x, g.mouse.y = love.mouse.getPosition()
	g.ui.set_mouse_position(g.mouse.x, g.mouse.y)
	g.ui.button.active_hover = nil
	if not g.msgbox.active then
		g.shaders.update(dt)
		g.flux.update(dt)
		--
		for i, state in g.state.states() do
			if state.update then state:update(dt) end
		end
	else
		if g.msgbox.update then g.msgbox:update(dt) end
		if g.console.update then g.console:update(dt) end
	end
	if g.mouse.cursor.current~="hand" and g.ui.button.active_hover then
		love.mouse.setCursor(g.mouse.cursor.hand)
		g.mouse.cursor.current = "hand"
	elseif g.mouse.cursor.current~="arrow" and g.ui.button.active_hover==nil and not (g.ribbon.searchbox and g.ribbon.searchbox.focus) then
		love.mouse.setCursor(g.mouse.cursor.arrow)
		g.mouse.cursor.current = "arrow"
	elseif g.mouse.cursor.current~="ibeam" and g.ui.button.active_hover==nil and g.ribbon.searchbox and g.ribbon.searchbox.focus then
		love.mouse.setCursor(g.mouse.cursor.ibeam)
		g.mouse.cursor.current = "ibeam"
	end
end

function love.draw()
	love.graphics.setCanvas(g.canvas)
	for i, state in g.state.states_z() do
		if state~=g.console and state~=g.msgbox and state.draw then state:draw() end
	end
	if g.msgbox.draw then g.msgbox:draw() end
	--
	love.graphics.setCanvas()
	if g.console.visible then
		love.graphics.setShader(g.shaders.pixelate)
	end
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.draw(g.canvas)
	love.graphics.setShader()
	love.graphics.setCanvas()
	if g.console.draw then g.console:draw() end
	--
	if g.take_screenshot then
		local screenshot = love.graphics.newScreenshot()
		local format = g.settings.screenshot_format
		love.filesystem.createDirectory("screenshots")
		local ostime = os.time()
		screenshot:encode("screenshots/" .. ostime .. "." .. format)
		g.take_screenshot = false
		g.notification:new("Screenshot Saved\n("..ostime.."." .. format .. ")", g.image.new(screenshot))
	end
end

function g.start_game(team)
	-- This is called by a button callback to start the game.
	g.database.new_game(team.id) -- Run a new_game
	g.message.welcome() -- Fire a message to welcome the player
	g.message.initial_budget()
	g.database.new_season() -- Create a new season, also gives season_targets message
	--
	g.database.save_game() -- Save the game
	--
	g.state.pop() -- Remove the current singlet state
	g.state.add(g.states.navbar) -- Add navbar
	g.state.add(g.states.ribbon) -- add ribbon
	g.state.add(g.states.club_overview) -- default to the club_overview page
	g.in_game = true -- in_game is now true
end

function g.continue_function()
	if g.message.urgent then
		--An urgent message needs to be dealt with!
		--Should display popup to tell player
		--And not run below functions (return)
	end
	g.database.advance_week()
	g.state.refresh_all()
end

function g.tween_alpha()
	g.tween.t_alpha = 0
	g.flux.to(g.tween, g.skin.tween.time, { t_alpha = 1 }):ease(g.skin.tween.type)
end

function g.convert_currency(n)
	local currency = g.settings.currency
	if currency=="£" then return math.floor(n + .5) end
	if currency=="$" then return math.floor(n * 1.53 + .5) end
	if currency=="€" then return math.floor(n * 1.37 + .5) end
end

function g.format_currency(n)
	n = g.convert_currency(n)
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return (g.settings.currency or "£")..left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

function love.keypressed(k,ir)
	-- Ensure to check if searchbox is focused in each state keypressed function (if it has one)
	-- If a state reports a button press, then no other states can recieve that keyboard event. This prevents weird double-keypress events
	-- Obviously, make sure states that can appear at the same time (Ribbon, Navbar, Any Screen, Console, etc) don't use the same events, unless it is needed
	-- to overwrite another states default keypressed handler
	if not g.msgbox.active then
		for i, state in g.state.states() do
			if state.keypressed then if state:keypressed(k,ir)==true then break end end
		end
	end
	-- Run these commands regardless of what the heck is going on!
	-- Probably should be F1 thru F12 keys only, as nothing else cares about those!
	if k=="f5" then
		if g.in_game and not g.msgbox.active and not g.busy then g.database.save_game() end
	elseif k=="f9" then
		if g.in_game and not g.msgbox.active and not g.busy then g.database.load_game(); g.state.refresh_all() end
	elseif k=="f10" then
		g.console:print(g.state.order(), g.skin.red)
		g.console:print("Active State: " .. g.state.active().name, g.skin.green)
	elseif k=="f11" then
		g.console:print(g.state.z_order(), g.skin.red)
	elseif k=="f12" then
		g.take_screenshot = true
	end
end

function love.mousepressed(x, y, b)
	if g.msgbox.active then
		if g.msgbox.mousepressed then g.msgbox:mousepressed(x, y, b) end
		return
	end
	for i, state in g.state.states() do
		if state.mousepressed then state:mousepressed(x, y, b) end
	end
end

function love.mousereleased(x, y, b)
	if g.msgbox.active then
		if g.msgbox.mousereleased then g.msgbox:mousereleased(x, y, b) end
		return
	end
	for i, state in g.state.states() do
		if state.mousereleased then state:mousereleased(x, y, b) end
	end
end

function love.textinput(t)
	if g.msgbox.active then
		if g.msgbox.textinput then g.msgbox:textinput(x, y, b) end
		return
	end
	for i, state in g.state.states() do
		if state.textinput then state:textinput(t) end
	end
end

-- New functions
function love.graphics.hexToRgb(hex)
	if hex==nil then return nil end
	hex = tostring(hex)
	return { tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6)), tonumber("0x"..hex:sub(7,8)) or 255 }
end

function love.graphics.darken(color)
	return { math.floor(color[1] * g.skin.darken + .5), math.floor(color[2] * g.skin.darken + .5), math.floor(color[3] * g.skin.darken + .5), color[4] or 255}
end

function love.graphics.setColorAlpha(color,alpha)
	love.graphics.setColor(color[1] or color.r,color[2] or color.g,color[3] or color.b,alpha)
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

local function error_printer(msg, layer)
	print(debug.traceback("Error: " .. tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", ""))
end
 
function love.errhand(msg)
	msg = tostring(msg)
 
	error_printer(msg, 2)
 
	if not love.window or not love.graphics or not love.event then
		return
	end
 
	if not love.graphics.isCreated() or not love.window.isCreated() then
		local success, status = pcall(love.window.setMode, 800, 600)
		if not success or not status then
			return
		end
	end
 
	-- Reset state.
	if love.mouse then
		love.mouse.setVisible(true)
		love.mouse.setGrabbed(false)
	end
	if love.joystick then
		-- Stop all joystick vibrations.
		for i,v in ipairs(love.joystick.getJoysticks()) do
			v:setVibration()
		end
	end
	if love.audio then love.audio.stop() end
	love.graphics.reset()
	local font = love.graphics.setNewFont(math.floor(love.window.toPixels(24)))
 
	local sRGB = select(3, love.window.getMode()).srgb
	if sRGB and love.math then
		love.graphics.setBackgroundColor(love.math.gammaToLinear(25, 25, 25))
	else
		love.graphics.setBackgroundColor(25, 25, 25)
	end
 
	love.graphics.setColor(255, 255, 255, 255)
 
	local trace = debug.traceback()
 
	love.graphics.clear()
	love.graphics.origin()
 
	local err = {}
 
	table.insert(err, "A Fatal Error Has Occured!\n")
	table.insert(err, msg.."\n\n")
 
	for l in string.gmatch(trace, "(.-)\n") do
		if not string.match(l, "boot.lua") then
			l = string.gsub(l, "stack traceback:", "Traceback\n")
			table.insert(err, l)
		end
	end
 
	local p = table.concat(err, "\n")
 
	p = string.gsub(p, "\t", "")
	p = string.gsub(p, "%[string \"(.-)\"%]", "%1")
 
	local function draw()
		local pos = love.window.toPixels(70)
		love.graphics.clear()
		love.graphics.printf(p, pos, pos, love.graphics.getWidth() - pos)
		love.graphics.present()
	end
 
	while true do
		love.event.pump()
 
		for e, a, b, c in love.event.poll() do
			if e == "quit" then
				return
			end
			if e == "keypressed" and a == "escape" then
				return
			end
		end
 
		draw()
 
		if love.timer then
			love.timer.sleep(0.1)
		end
	end
end