local skin = {}

local hex = love.graphics.hexToRgb

skin.red = hex("ff3333")
skin.green = hex("33ff33")
skin.blue = hex("3333ff")
skin.white = hex("ffffff")
skin.black = hex("333333")

-- Load fonts
g.font.new("console", "assets/fonts/consolas/regular.ttf",		{12, 14, 24, 36, 48})
g.font.new("regular", "assets/fonts/titillium/regular.otf", 	{12, 14, 24, 36, 48})
g.font.new("bold", "assets/fonts/titillium/bold.otf",			{12, 14, 24, 36, 48})
g.font.new("bebas", "assets/fonts/bebasneue/regular.otf",	 	{12, 14, 24, 36, 48})

skin.colors = {
	hex("090909ff"); -- Primary color used for navbar bg, etc
	hex("a7dbd8ff");
	hex("e0e4ccff");
	hex("f38630ff");
	hex("fa6900ff");
}

skin.margin = 4
skin.padding = 8
skin.tab = 22

skin.console = {
	margin = skin.margin;
	padding = skin.padding;
}

skin.navbar = {
	x = 0;
	y = 0;
	w = 52;
	h = g.width;
}

skin.ribbon = {
	font = { "bold", 36 };
	x = skin.navbar.w;
	y = 0;
	w = g.width - skin.navbar.w;
	h = 74;
	border = 2;
	shadow_x = 2;
	shadow_y = 2;
	large_logo_alpha = 50;
	tween_time = .4;
	tween_type = "out-quart";
	tween_ox = 0;
	tween_oy = -20;
	tween_alpha = 0;
}

return skin