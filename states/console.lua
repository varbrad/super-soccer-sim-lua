local console = {}
console.name = "Console"

local data = {}

function console:init()
	self.__z = 999
	self.visible = false
	--
	g.console:log("console:init")
end

function console:added()

end

function console:update(dt)

end

function console:draw()
	if self.visible==false then return end
	local pm = g.skin.console.padding + g.skin.console.margin
	love.graphics.setColor(0, 0, 0, 150)
	love.graphics.rectangle("fill", g.skin.console.margin, g.skin.console.margin, g.width - g.skin.console.margin*2, g.height - g.skin.console.margin*2)
	love.graphics.setColor(255, 255, 255, 255)
	g.font.set("console", 14)
	local y = g.height - g.skin.console.margin - g.skin.console.padding - g.font.height()
	for i = 1, #data do
		love.graphics.setColor(data[i].color)
		love.graphics.print(data[i].text, pm, y)
		y = y - g.font.height()
	end
	-- Display draw stats
	local stats = love.graphics.getStats()
	local arr = {}
	arr[1] = string.format("LÖVE Version: %s.%s.%s", g.v_major, g.v_minor, g.v_revision)
	arr[2] = string.format("Game Version: %s", g.version)
	arr[3] = string.format("Current FPS: %s", love.timer.getFPS())
	arr[4] = string.format("VRAM: %.2f MB", stats.texturememory/1024/1024)
	arr[5] = string.format("Loaded Images: %s (%x)", stats.images, stats.images)
	arr[6] = string.format("Loaded Fonts: %s (%x)", stats.fonts, stats.fonts)
	love.graphics.setColor(255, 255, 255, 255)
	for i=1, #arr do
		love.graphics.print(arr[i], pm, pm + (i-1)*g.font.height())
	end
end

function console:keypressed(k, ir)
	if k=="`" then self.visible = not self.visible end
end

-- Functions

function console:log(...)
	local str = ""
	local a = {...}
	for i, v in ipairs(a) do
		str = str .. tostring(v) .. "\t"
	end
	table.insert(data, 1, {text = str; color = {123,123,123,255};} )
	console:trim()
end

function console:hr()
	table.insert(data, 1, {text = "────────────────────"; color = {123, 123, 123, 255};} )
	console:trim()
end

function console:print(text, color)
	color = color or {123,123,123,255}
	table.insert(data, 1, {text = text; color = color;} )
	console:trim()
end

function console:trim()
	while #data > 50 do
		data[#data] = nil
	end
end

return console