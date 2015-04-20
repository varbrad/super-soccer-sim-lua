local skin = {}

local hex = love.graphics.hexToRgb

skin.red = hex("ff3333")
skin.green = hex("33ff33")
skin.blue = hex("3333ff")
skin.white = hex("ffffff")
skin.black = hex("000000")

skin.colors = {
	hex("3e3e3e");
	hex("a7dbd8");
	hex("e0e4cc");
	hex("f38630");
	hex("fa6900");
}

skin.navbar = {
	w = 52;
	h = g.width;
}

skin.console = {
	margin = 10;
	padding = 8;
}

return skin