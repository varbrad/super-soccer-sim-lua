local s = {}
s.name = "Shaders Library"
s.t = 0

function s.init()
	s.inverted = love.graphics.newShader("src/shaders/inverted.frag")
	s.wavy = love.graphics.newShader("src/shaders/wavy.frag")
end

function s.update(dt)
	s.t = s.t + dt
	s.wavy:send("time",s.t)
end

return s