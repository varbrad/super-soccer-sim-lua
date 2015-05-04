local skin = {}

local hex = love.graphics.hexToRgb

skin.red = hex("ff3333")
skin.green = hex("33ff33")
skin.blue = hex("72f7ff")
skin.white = hex("ffffff")
skin.black = hex("000000")

-- Load fonts
g.font.new("console", "assets/fonts/consolas/regular.ttf",		{12, 13, 14, 24, 36, 48})
g.font.new("regular", "assets/fonts/opensans/regular.ttf", 		{12, 13, 14, 24, 36, 48})
g.font.new("semibold", "assets/fonts/opensans/semibold.ttf",	{12, 13, 14, 24, 36, 48})
g.font.new("bold", "assets/fonts/opensans/bold.ttf",			{12, 13, 14, 24, 36, 48})
g.font.new("bebas", "assets/fonts/bebasneue/regular.otf",	 	{12, 13, 14, 24, 36, 48})

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

skin.darken = 0.8 -- 20% color reduction for darken

skin.console = {
	font = { "console", 14 };
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
	tween_type = "out-circ";
	tween_ox = 0;
	tween_oy = -20;
	tween_alpha = 0;
}

skin.screen = {
	x = skin.navbar.w; -- Width of the navbar
	y = skin.ribbon.h; -- Height of the ribbon
	w = g.width - skin.navbar.w;
	h = g.height - skin.ribbon.h;
}

skin.components = {
	color1 = hex("0a0a0aff");
	color2 = hex("ffffffff");
	color3 = hex("0f0f0fff");
}

skin.bars = {
	h = 34;
	alpha = 150;
	color1 = hex("1a1a1aff");
	color2 = hex("ffffffff");
	color3 = hex("1f1f1fff");
	color4 = hex("0a0a0aff");
	font = { {"bold", 14}, {"regular", 13}, {"semibold", 14} };
	img_size = 26;
}

skin.small_bars = {
	h = 24;
	alpha = skin.bars.alpha;
	color1 = skin.bars.color1;
	color2 = skin.bars.color2;
	color3 = skin.bars.color3;
	color4 = skin.bars.color4;
	font = { {"bold", 12}, {"regular", 12}, {"semibold", 12} };
	img_size = 16;
}

skin.ui = {
	button = {
		font = { "regular", 12 };
	};
	panel = {
		alpha = 150;
	};
}

return skin