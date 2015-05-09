local s = {}
s.name = "Shaders Library"
s.t = 0

function s.init()
	s.inverted = love.graphics.newShader("src/shaders/test_shader.frag")
end

function s.update(dt)
	s.t = s.t + dt
end

return s