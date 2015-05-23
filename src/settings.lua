local settings = {}

function settings.default()
	settings.screenshot_format = "jpg"
	settings.background_cycle = true
	settings.background_cycle_time = 120
end

function settings.save()
	love.filesystem.write("settings", g.ser(settings))
	g.notification:new("Settings Saved!", "settings")
end

function settings.load()
	if not love.filesystem.exists("settings") then return settings.default() end
	local data, size = love.filesystem.read("settings")
	local f, err = loadstring(data)
	if f==nil then return settings.default() end
	data = f()
	settings.screenshot_format = data.screenshot_format
	settings.background_cycle = data.background_cycle
	settings.background_cycle_time = data.background_cycle_time
end

return settings