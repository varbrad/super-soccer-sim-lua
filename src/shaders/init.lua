local s = {}
s.name = "Shaders Library"
s.t = 0

function s.init()
	s.inverted = love.graphics.newShader("src/shaders/test_shader.frag")
	s.wavy = love.graphics.newShader("src/shaders/wavy.frag")
	s.seascape = love.graphics.newShader("src/shaders/seascape.frag")
	s.seascape:send("iResolution", {g.width, g.height})
end

function s.update(dt)
	s.t = s.t + dt
	s.wavy:send("time",s.t)
	s.seascape:send("iGlobalTime",s.t)
end

return s