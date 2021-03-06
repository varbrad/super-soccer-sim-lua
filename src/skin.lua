local skin = {}

local hex = love.graphics.hexToRgb

skin.red = hex("ff3333")
skin.green = hex("33ff33")
skin.blue = hex("7272ff")
skin.yellow = hex("f7ff72")
skin.white = hex("ffffff")
skin.black = hex("000000")

skin.dark_red = hex("880404")

-- Load fonts
g.font.new("console", "assets/fonts/consolas/regular.ttf",		{12, 13, 14, 24, 36, 48, 96})
g.font.new("regular", "assets/fonts/opensans/regular.ttf", 		{12, 13, 14, 24, 36, 48, 96})
g.font.new("italic", "assets/fonts/opensans/italic.ttf", 		{12, 13, 14, 24, 36, 48, 96})
g.font.new("semibold", "assets/fonts/opensans/semibold.ttf",	{12, 13, 14, 24, 36, 48, 96})
g.font.new("bold", "assets/fonts/opensans/bold.ttf",			{12, 13, 14, 24, 36, 48, 96})
g.font.new("bebas", "assets/fonts/bebasneue/regular.otf",	 	{12, 13, 14, 24, 36, 48, 96})

skin.colors = {
	hex("1a5a9fff"); -- Primary bar used for default headers
	hex("ffa523ff"); -- Highlight color for text
	hex("4595ffff"); -- Players team highlight color & selected bars
	hex("c3c3c3ff"); -- Mid-Grey - Used by the pips on team_history_graph
	hex("fa6900ff");
}

skin.margin = 4
skin.img_margin = skin.margin * 3
skin.padding = 8
skin.tab = 22
skin.rounded = 5

skin.darken = 0.8 -- 20% color reduction for darken

--
skin.header = {"bold", 48}
skin.h2 = {"bebas", 48}
skin.h3 = {"bebas", 36}
skin.bold = {"bold", 14}

skin.tween = {
	time = .5;
	type = "quartout";
	type_in = "circout";
	type_out = "circin";
	delay = 3;
}

skin.console = {
	font = { "console", 14 };
	margin = skin.margin;
	padding = skin.padding;
	alpha = 155;
	rounded = 9;
}

skin.notification = {
	x = g.width - 340;
	y = g.height - 100;
	dx = 0;
	dy = -100;
	w = 340;
	h = 100;
	font = { {"bold", 14}, {"regular", 14} };
	color1 = hex("0a0a0aff");
	color2 = hex("ffffffff");
	color3 = hex("0f0f0fff");
	alpha = 225;
	dalpha = 215;
	img_size = 100 - skin.img_margin * 2;
}
skin.notification.iy = math.floor(skin.notification.h/2 - skin.notification.img_size/2 + .5)
skin.notification.ty = math.floor(skin.notification.h/2 - g.font.height(skin.notification.font[1])/2 + .5)

skin.navbar = {
	x = 0;
	y = 0;
	w = 52;
	h = g.height;
	border = 2;
	alpha = 255;
}

skin.ribbon = {
	font = { {"bold", 36}, {"regular", 14} };
	x = skin.navbar.w;
	y = 0;
	w = g.width - skin.navbar.w;
	h = 74;
	border = 2;
	shadow_x = 2;
	shadow_y = 2;
	large_logo_alpha = 50;
	tween_time = .4;
	tween_type = "circout";
	tween_ox = 0;
	tween_oy = -20;
	tween_alpha = 0;
	--
	continue_w = 140;
	searchbox_w = 260;
	--
	tab_w = 140;
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
	alpha = 130;
	color1 = hex("1a1a1aff");
	color2 = hex("ffffffff");
	color3 = hex("1d1d1dff");
	color4 = hex("0a0a0aff");
	font = { {"bold", 14}, {"regular", 13}, {"semibold", 14} };
	img_size = 26;
	column_size = 40;
	border = 2;
}
skin.bars.iy = math.floor(skin.bars.h/2 - skin.bars.img_size/2 +.5);
skin.bars.ty = math.floor(skin.bars.h/2 - g.font.height(skin.bars.font[1])/2 + .5);

skin.small_bars = {
	h = 24;
	alpha = skin.bars.alpha;
	color1 = skin.bars.color1;
	color2 = skin.bars.color2;
	color3 = skin.bars.color3;
	color4 = skin.bars.color4;
	font = { {"bold", 12}, {"regular", 12}, {"semibold", 12} };
	img_size = 16;
	column_size = 30;
}
skin.small_bars.iy = math.floor(skin.small_bars.h/2 - skin.small_bars.img_size/2 +.5);
skin.small_bars.ty = math.floor(skin.small_bars.h/2 - g.font.height(skin.small_bars.font[1])/2 + .5);

skin.ui = {
	button = {
		font = { "regular", 12 };
	};
	panel = {
		alpha = 110;
	};
	textbox = {
		tween_type = "linear";
		tween_time = 1;
	}
}

skin.rating_colors = {
	a_plus		= hex("FF0002");
	a			= hex("F92602");
	a_minus		= hex("F44C01");
	b_plus		= hex("EE7201");
	b			= hex("E89800");
	b_minus		= hex("C9BA00");
	c_plus		= hex("ABDD00");
	c			= hex("8CFF00");
	c_minus		= hex("6CF934");
	d_plus		= hex("4CF468");
	d			= hex("2CEE9C");
	d_minus		= hex("0CE8D0");
	f			= hex("ffffff");
}

return skin