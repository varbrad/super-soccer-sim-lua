local skin = {}

local hex = love.graphics.hexToRgb

skin.red = hex("ff3333")
skin.green = hex("33ff33")
skin.blue = hex("3333ff")
skin.white = hex("ffffff")
skin.black = hex("000000")

-- Load fonts
g.font.new("console", "assets/fonts/consolas/regular.ttf", {14})
g.font.new("regular", "assets/fonts/titillium/regular.otf", {12, 13, 24, 48, 96})

skin.colors = {
	hex("3e3e3e");
	hex("a7dbd8");
	hex("e0e4cc");
	hex("f38630");
	hex("fa6900");
}

skin.margin = 8
skin.padding = 6

skin.console = {
	margin = skin.margin;
	padding = skin.padding;
}

skin.navbar = {
	w = 52;
	h = g.width;
}

skin.splash = {
	margin = skin.margin;
	padding = skin.padding;
}

return skin