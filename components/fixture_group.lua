local fixture_group = {}
fixture_group.__index = fixture_group
fixture_group.__type = "Component.FixtureGroup"

function fixture_group.new(x, y, w, h, league, round)
	local fg = {}
	setmetatable(fg, fixture_group)
	fg.x, fg.y, fg.w, fg.h = x or 0, y or 0, w or 10, h or 10
	fg.panel = g.ui.panel.new(fg.x, fg.y, fg.w, fg.h)
	fg.panel:set_colors(g.skin.components.color1, g.skin.components.color3)
	fg:set(league, round)
	return fg
end

function fixture_group:set(league, round, is_results)
	self.league, self.round = league, round
	self.bars = {}
	if self.league==nil or self.league.season.fixtures[round]==nil then
		local no_fix = {x = self.x + g.skin.margin; y = self.y + g.skin.margin; w = self.w - g.skin.margin*2; h = g.skin.bars.h;}
		no_fix.color = g.skin.bars.color1
		no_fix.alpha = g.skin.bars.alpha
		no_fix.header=true;
		no_fix.ty = math.floor(no_fix.h/2 - g.font.height(g.skin.bars.font[1])/2 + .5)
		no_fix.images, no_fix.text = {}, { {x=0;y=no_fix.ty;w=no_fix.w;align="center";text=is_results and "No Results To Show" or "No Fixtures Scheduled"}}
		self.bars[1] = no_fix
		return
	end
	local header = {x = self.x + g.skin.margin; y = self.y + g.skin.margin; w = self.w - g.skin.margin*2; h = g.skin.bars.h; color = self.league.color3; alpha = g.skin.bars.alpha }
	header.header = true
	header.ty = math.floor(header.h/2 - g.font.height(g.skin.bars.font[1])/2 +.5)
	header.images = {}
	header.text = { {x = 0; y = header.ty; w = header.w; align="center"; text=self.league.short_name .. (is_results and " Results - Round " or " Fixtures - Round ") .. round}}
	self.bars[1] = header
	for i=1, #self.league.season.fixtures[round] do
		local fixture = self.league.season.fixtures[round][i]
		local bar = { x = self.x + g.skin.margin; y = self.y + g.skin.margin + i*g.skin.bars.h; w = self.w - g.skin.margin*2; h = g.skin.bars.h}
		bar.ty = math.floor(bar.h/2 - g.font.height(g.skin.bars.font[2])/2 + .5)
		bar.color = i%2==0 and g.skin.bars.color1 or g.skin.bars.color3
		bar.alpha = g.skin.bars.alpha
		local home_logo = g.image.new("logos/128/"..fixture.home.id..".png", {mipmap=true, w = g.skin.bars.img_size, h = g.skin.bars.img_size})
		home_logo.x = bar.x + bar.w/2 - 30 - g.skin.margin - g.skin.bars.img_size
		local away_logo = g.image.new("logos/128/"..fixture.away.id..".png", {mipmap=true, w = g.skin.bars.img_size, h = g.skin.bars.img_size})
		away_logo.x = bar.x + bar.w/2 + 30 + g.skin.margin
		local iy = bar.y + math.floor(bar.h/2 - g.skin.bars.img_size/2 + .5)
		home_logo.y, away_logo.y = iy, iy
		bar.images = {home_logo, away_logo}
		local home_text = { text = fixture.home.short_name; y = bar.ty; }
		local away_text = { text = fixture.away.short_name; y = bar.ty; }
		home_text.w = g.font.width(home_text.text, g.skin.bars.font[2])
		away_text.w = g.font.width(away_text.text, g.skin.bars.font[2])
		home_text.x = home_logo.x - g.skin.margin - home_text.w - bar.x
		away_text.x = away_logo.x + g.skin.margin + g.skin.bars.img_size - bar.x
		bar.text = {home_text, away_text}
		if fixture.finished then

		else
			local versus = { text = "v"; x = bar.w/2 - 30; y = math.floor(bar.h/2 - g.font.height(g.skin.bars.font[3])/2); w = 60; align="center"; font=g.skin.bars.font[3]}
			bar.text[#bar.text+1] = versus
		end
		self.bars[#self.bars+1] = bar
	end
end

function fixture_group:draw()
	self.panel:draw()
	love.graphics.setScissor(self.panel.x+g.skin.margin, self.panel.y+g.skin.margin, self.panel.w-g.skin.margin*2, self.panel.h-g.skin.margin*2)
	for i=1, #self.bars do
		local bar = self.bars[i]
		love.graphics.setColorAlpha(bar.color, bar.alpha)
		love.graphics.rectangle("fill", bar.x, bar.y, bar.w, bar.h)
		love.graphics.setColorAlpha(g.skin.bars.color4, bar.alpha)
		if not bar.header then love.graphics.roundrect("fill", bar.x + bar.w/2 - 30, bar.y + g.skin.margin, 60, bar.h - g.skin.margin * 2, 5) end
		love.graphics.setColorAlpha(g.skin.bars.color2)
		if bar.header then g.font.set(g.skin.bars.font[1]) else g.font.set(g.skin.bars.font[2]) end
		for i=1, #bar.text do
			local text = bar.text[i]
			if not bar.header then
				if text.font then g.font.set(text.font) else g.font.set(g.skin.bars.font[2]) end
			end 
			if text.align then
				love.graphics.printf(text.text, bar.x + text.x, bar.y + text.y, text.w, text.align)
			else
				love.graphics.print(text.text, bar.x + text.x, bar.y + text.y)
			end
		end
		for i=1, #bar.images do
			local image = bar.images[i]
			love.graphics.setColor(255, 255, 255, 255)
			image:draw()
		end
	end
	love.graphics.setScissor()
end

setmetatable(fixture_group, {_call = function(_, ...) return fixture_group.new(...) end})

return fixture_group