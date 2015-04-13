function love.conf(t)
	t.identity = "SuperSoccerSim"
	t.version = "0.9.2"
	t.console = false

	t.window.title = "Super Soccer Sim"
	t.window.width = 1920
	t.window.height = 1080
	t.window.fullscreen = true
	t.window.fullscreentype = "desktop"

	t.window.vsync = true
	t.window.msaa = 8
	
	-- Disable unneeded modules
	t.modules.joystick = false
	t.modules.physics = false
end