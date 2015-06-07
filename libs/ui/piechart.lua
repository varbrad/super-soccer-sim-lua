local ui = 1
local piechart = {}
piechart.__index = piechart

piechart.__start = -math.pi
piechart.__tween_time = .4
piechart.__tween_type = "linear"

function piechart.init(ui_ref)
	ui = ui_ref
end

function piechart.new(settings)
	local b = {}
	setmetatable(b, piechart)
	b.__settings = settings
	b.flux = g.flux:group()
	b:reset(settings)
	return b
end

function piechart:reset(settings)
	self.settings = settings or self.__settings or {}
	self.__settings = self.settings
	self.x = self.settings.x or self.x or 0
	self.y = self.settings.y or self.y or 0
	self.radius = self.settings.radius or self.radius or 100
	self.color = self.settings.color or self.color or {0, 0, 0}
	self.alpha = self.settings.alpha or self.alpha or 255
	if self.settings.visible==false or self.visible==false then self.visible = false else self.visible = true end
	self.font = self.settings.font or self.font or ui.__defaultFont
	--
	self.arcs, self.percent = {}, 0
	return self
end

function piechart:add(color, percent, label)
	if self.percent>=100 or percent==0 then return self end
	if percent==nil then percent = 100 - self.percent end
	self.percent = self.percent + percent
	local arc = { color = color }
	-- Get the last arc finish position of 0 if no arcs
	local start = #self.arcs==0 and piechart.__start or self.arcs[#self.arcs].finish
	local finish = start + (percent/100) * math.pi * 2
	arc.finish = finish
	-- Calculate label point (even if not used)
	local mid_arc = (start + arc.finish) / 2
	local lx = self.x + math.cos(mid_arc) * self.radius / 1.5
	local ly = self.y + math.sin(mid_arc) * self.radius / 1.5
	arc.lx, arc.ly, arc.label = lx, ly, label
	--
	table.insert(self.arcs, arc)
	return self
end

function piechart:tween(time, ease)
	for i = 1, #self.arcs do
		local arc = self.arcs[i]
		local finish = arc.finish
		arc.finish = piechart.__start
		self.flux:to(arc, time or piechart.__tween_time, { finish = finish }):ease(ease or piechart.__tween_type)
	end
end

function piechart:update(dt)
	self.flux:update(dt)
end

function piechart:draw(t_alpha)
	if not self.visible then return end
	--
	love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.alpha)
	love.graphics.circle("fill", self.x, self.y, self.radius)
	--
	for i = 1, #self.arcs do
		local arc = self.arcs[i]
		love.graphics.setColor(arc.color[1], arc.color[2], arc.color[3], self.alpha)
		local start = i==1 and piechart.__start or self.arcs[i-1].finish
		love.graphics.arc("fill", self.x, self.y, self.radius, start, arc.finish)
	end
	--
	love.graphics.setColor(self.color)
	-- Draw lines between arcs
	for i = 1, #self.arcs do
		local arc = self.arcs[i]
		local start = i==1 and piechart.__start or self.arcs[i-1].finish
		local x = self.x + math.cos(start) * self.radius
		local y = self.y + math.sin(start) * self.radius
		if #self.arcs > 1 then love.graphics.line(self.x, self.y, x, y) end
		if arc.label then
			love.graphics.setFont(self.font)
			local txt = arc.label
			local fw, fh = math.floor(self.font:getWidth(txt)/2+.5), math.floor(self.font:getHeight()/2+.5)
			love.graphics.print(arc.label, arc.lx - fw, arc.ly - fh)
		end
	end
	--
	love.graphics.circle("line", self.x, self.y, self.radius)
end

return piechart