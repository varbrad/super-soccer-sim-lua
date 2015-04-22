local font = {}

local cache = {}
local active = nil

function font.new(name, path, sizes)
	local f = {}
	for i = 1, #sizes do
		f[sizes[i]] = love.graphics.newFont(path, sizes[i])
	end
	cache[name] = f
end

function font.set(name, size)
	active = cache[name][size]
	love.graphics.setFont(active)
end

function font.height(name, size)
	if name==nil and size==nil then return active:getHeight() end
	return cache[name][size]:getHeight()
end

function font.width(text, name, size)
	if name==nil and size==nil then return active:getWidth(text) end
	return cache[name][size]:getWidth(text)
end

return font