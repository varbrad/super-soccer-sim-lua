local s = {}
s.name = "Shaders Library"
s.t = 0

function s.init()
	s.inverted = love.graphics.newShader("src/shaders/inverted.frag")
	s.wavy = love.graphics.newShader("src/shaders/wavy.frag")
	s.grayscale = love.graphics.newShader("src/shaders/grayscale.frag")
	s.blur = love.graphics.newShader("src/shaders/blur.frag")
	s.pixelate = love.graphics.newShader("src/shaders/pixelate.frag")
	--
	s.blur:send("resolution", {g.width, g.height})
	s.pixelate:send("resolution", {g.width, g.height})
	s.pixelate:send("pixelation", {5, 5})
end

function s.update(dt)
	s.t = s.t + dt
	s.wavy:send("time",s.t)
end

return s