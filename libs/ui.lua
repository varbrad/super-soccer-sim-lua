local ui = {}
ui.mx, ui.my = -1, -1

-- Some local functions
function ui.roundrect(mode, x, y, w, h, tl, tr, bl, br)
	tr, bl, br = tr or tl, bl or tl, br or tl
	local r = tl or 0
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

function ui.setColorAlpha(c, a)
	love.graphics.setColor(c[1], c[2], c[3], a)
end

function ui.set_mouse_position(mx, my)
	ui.mx, ui.my = mx or -1, my or -1
end

--

ui.__defaultMargin = 8
ui.__defaultRounded = 3
ui.__defaultColor1 = {200, 200, 200}
ui.__defaultColor2 = {163, 163, 253}
ui.__defaultColor3 = {167, 167, 167}
ui.__defaultFont = love.graphics.newFont(12)

local folder = (...):match("(.-)[^%.]+$")

ui.button = require(folder.."ui.button")
ui.button.init(ui)
ui.panel = require(folder.."ui.panel")
ui.panel.init(ui)
ui.textbox = require(folder.."ui.textbox")
ui.textbox.init(ui)

return ui