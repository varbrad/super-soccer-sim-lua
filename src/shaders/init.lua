local s = {}
s.name = "Shaders Library"
s.t = 0

local folder = (...).."."
--
s[1] = require(folder.."wispy_smoke")
s[2] = require(folder.."waves")

function s.init()
	s[1]:send("resolution", {g.width, g.height})
	s[2]:send("resolution", {g.width, g.height})
end

function s.update(dt)
	s.t = s.t + dt
	s[1]:send("time", s.t)
	s[2]:send("time", s.t)
end

return s