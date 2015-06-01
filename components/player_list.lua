local player_list = {}
player_list.__index = player_list
player_list.__type = "Component.PlayerList"

function player_list.new(x, y, w, h)
	local pl = {}
	setmetatable(pl, player_list)
	pl.x, pl.y, pl.w, pl.h = x or 0, y or 0, w or 10, h or 10
	pl.panel = g.ui.panel.new(pl.x, pl.y, pl.w, pl.h)
	pl.panel:set_colors(g.skin.components.color1, g.skin.components.color3)
	pl:set()
	return pl
end

function player_list:set()
	self.bars = {}
	local players = g.database.vars.players
	table.sort(players, function(a,b)
		if a.position_value < b.position_value then return true
		elseif a.position_value > b.position_value then return false
		else return a.rating > b.rating end
	end)
	--
	for i=1, #players do
		local player = players[i]
		local bar = { x = self.x + g.skin.margin, y = self.y + g.skin.margin + (i-1) * g.skin.bars.h , w = self.w - g.skin.margin * 2, h = g.skin.bars.h, alpha = g.skin.bars.alpha }
		bar.color = i%2==0 and g.skin.bars.color1 or g.skin.bars.color3
		bar.label_color = g.skin.bars.color2
		--
		local rect = { x = 0, y = 0, w = 60, h = g.skin.bars.h, alpha = g.skin.bars.alpha }
		local rect2 = { x = 2, y = 2, w = rect.w - 4, h = g.skin.bars.h - 4, alpha = g.skin.bars.alpha, rounded = g.skin.rounded }
		rect.color = player.position=="gk" and g.skin.yellow or player.position=="df" and g.skin.blue or player.position=="mf" and g.skin.green or g.skin.red
		rect2.color = rect.color
		local position = { text = string.upper(player.position), x = 0, y = g.skin.bars.ty, w = rect.w, align = "center", font = g.skin.bars.font[1], color = { 0, 0, 0 }, alpha = g.skin.bars.alpha }
		--
		local player_name = { text = player.first_name .. " " .. player.last_name, x = rect.x + rect.w + g.skin.img_margin, y = g.skin.bars.ty, font = g.skin.bars.font[2] }
		local cw = g.skin.bars.column_size
		local age = { text = player.age, x = 500, y = g.skin.bars.ty, w = cw, align = "center", font = g.skin.bars.font[3] }
		local nation = g.image.new("flags/"..player.nationality..".png")
		nation.x, nation.y = age.x + age.w + g.skin.margin + math.floor(cw/2 - nation.w/2 +.5), math.floor(bar.h/2 - nation.h/2 +.5)
		local rating = { text = player.rating, x = age.x + age.w * 2 + g.skin.margin * 2, y = g.skin.bars.ty - 5, w = cw, align = "center", font = {"bebas", 24} }
		rating.color = g.players.get_rating_color(player.rating)
		local rect3 = { x = rating.x, y = 2, w = cw, h = g.skin.bars.h - 4, color = rating.color, alpha = 70, rounded = g.skin.rounded }
		local rect4 = { x = nation.x - g.skin.margin, y = nation.y - g.skin.margin, w = nation.w + g.skin.margin * 2, h = nation.h + g.skin.margin * 2, color = bar.color, alpha = g.skin.bars.alpha }
		--
		bar.rects = { rect, rect2, rect3, rect4 }
		bar.labels = { position, player_name, age, rating }
		bar.images = { nation }
		--
		table.insert(self.bars, bar)
	end
end

function player_list:draw(t_alpha)
	t_alpha = t_alpha or 1
	self.panel:draw()
	for i=1, #self.bars do
		local bar = self.bars[i]
		g.components.bar_draw.draw(bar, 0, 0,  t_alpha)
	end
end

setmetatable(player_list, {_call = function(_, ...) return player_list.new(...) end})

return player_list