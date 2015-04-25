local menu = {}
menu.name = "Menu"

local function button_hover(button)
	button.color = {200, 200, 200, 255}
end

local function button_out(button)
	button.color = g.skin.white
end

local function button_pressed(button)
	if button == menu.new_game then
		g.button.remove(menu.new_game)
		--
		g.state.swap(g.states.menu, g.states.new_game_load)
	end
end

function menu:init()
	self.__z = 1
	self.timer = g.timer.new()
	--
	g.console:log("menu:init")
end

function menu:added()
	self.timer.clear() -- Clear the local timer
	--
	self.logo = g.image.new("assets/images/misc/logo.png")
	self.logo.x, self.logo.y = g.width/2 - self.logo.w/2, g.skin.margin
	--
	g.font.set("regular", 48)
	local new_game = "NEW GAME"
	local font = {"regular", 48}
	g.font.set(font[1], font[2])
	self.new_game = g.button.new(g.width/2 - 250, self.logo.y + self.logo.h + g.skin.margin, 500, 80, button_hover, button_out, button_pressed)
	self.new_game.tx, self.new_game.ty = self.new_game.w/2 - g.font.width(new_game)/2, self.new_game.h/2 - g.font.height()/2
	self.new_game.text = new_game
	self.new_game.font = font
	self.new_game.color = g.skin.white
end

function menu:update(dt)
	self.timer.update(dt)
end

function menu:draw()
	love.graphics.setColor(255,255,255,255)
	g.image.draw(self.logo)
	--
	g.font.set(self.new_game.font[1], self.new_game.font[2])
	love.graphics.setColor(0, 0, 0, 50)
	love.graphics.rectangle("fill", self.new_game.x, self.new_game.y, self.new_game.w, self.new_game.h)
	love.graphics.setColor(self.new_game.color)
	love.graphics.print(self.new_game.text, self.new_game.x + self.new_game.tx, self.new_game.y + self.new_game.ty)
end

return menu