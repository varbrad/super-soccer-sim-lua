local console = {}
console.name = "Console"

local data = {}

function console:init()
	self.__z = 999
	self.visible = false
end

function console:added()

end

function console:update(dt)

end

function console:draw()
	if self.visible==false then return end
	love.graphics.setColor(0, 0, 0, 150)
	love.graphics.rectangle("fill", g.skin.console.margin, g.skin.console.margin, g.width - g.skin.console.margin*2, g.height - g.skin.console.margin*2)
	love.graphics.setColor(255, 255, 255, 255)
	local font = love.graphics.getFont()
	local y = g.height - g.skin.console.margin - g.skin.console.padding - font:getHeight()
	for i = 1, #data do
		love.graphics.setColor(data[i].color)
		love.graphics.print(data[i].text, g.skin.console.margin + g.skin.console.padding, y)
		y = y - font:getHeight()
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
	table.insert(data, 1, {text = "---------------------"; color = {123, 123, 123, 255};} )
	console:trim()
end

function console:print(text, color)
	table.insert(data, 1, {text = text; color = color;} )
	console:trim()
end

function console:trim()
	while #data > 50 do
		data[#data] = nil
	end
end

return console