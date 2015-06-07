local game_inbox = {}
game_inbox.name = "Game Inbox"

function game_inbox:init()
	self.__z = 1
	--
	g.console:log("game_inbox:init")
end

function game_inbox:added()
	local x, y, w, h = g.skin.screen.x + g.skin.margin, g.skin.screen.y + g.skin.margin, g.skin.screen.w - g.skin.margin * 2, g.skin.screen.h - g.skin.margin * 2
	local left_w = math.floor(g.skin.screen.w * .3 + .5) - g.skin.margin * 1.5
	local right_w = g.skin.screen.w - left_w - g.skin.margin * 3
	--
	self.panel1 = g.ui.panel.new(g.skin.screen.x + g.skin.margin, g.skin.screen.y + g.skin.margin, left_w, g.skin.screen.h - g.skin.margin * 2)
	self.panel1:set_colors(g.skin.components.color1, g.skin.components.color3)
	self.panel2 = g.ui.panel.new(self.panel1.x + self.panel1.w + g.skin.margin, g.skin.screen.y + g.skin.margin, right_w, g.skin.screen.h - g.skin.margin * 2)
	self.panel2:set_colors(g.skin.components.color1, g.skin.components.color3)
	--
	g.tween_alpha()
	self.show_message = nil
	self:set()
	g.ribbon:set_game("Message Inbox")
end

function game_inbox:update(dt)
	for i = 1, #self.buttons do self.buttons[i]:update(dt) end
end

function game_inbox:draw()
	self.panel1:draw()
	self.panel2:draw()
	--
	for i = 1, #self.bars do
		g.components.bar_draw.draw(self.bars[i], 0, 0, g.tween.t_alpha)
	end
	--
	for i = 1, #self.buttons do self.buttons[i]:draw(0, 0, g.tween.t_alpha) end
end

function game_inbox:set()
	local team = g.database.get_player_team()
	self.bars, self.buttons = {}, {}
	-- left-side first
	local header = { x = self.panel1.x + g.skin.margin, y = self.panel1.y + g.skin.margin, w = self.panel1.w - g.skin.margin * 2, h = g.skin.bars.h, alpha = g.skin.bars.alpha }
	header.color, header.label_color = team.color3, team.color2
	local txt = #g.database.vars.inbox .. " Messages"
	local unread = g.message.unread()
	if unread > 0 then txt = txt .. " - " .. unread .. " Unread" end
	header.labels = { { text = txt, x = g.skin.margin, y = g.skin.bars.ty, font = g.skin.bars.font[1] } }
	table.insert(self.bars, header)
	--
	for i = 1, #g.database.vars.inbox do
		local msg = g.database.vars.inbox[i]
		local bar = { x = header.x, y = header.y + i * g.skin.bars.h, w = header.w, h = g.skin.bars.h, alpha = g.skin.bars.alpha }
		bar.color = msg.urgent and g.skin.dark_red or i%2==0 and g.skin.bars.color1 or g.skin.bars.color3
		if msg == self.show_message then
			bar.color = msg.urgent and g.skin.red or g.skin.colors[3]
		end
		bar.label_color = g.skin.bars.color2
		--
		local read_rect = { x = 0, y = 0, w = g.skin.margin, h = bar.h, color = bar.label_color, alpha = g.skin.bars.alpha }
		--
		local icon_path = msg.urgent and "icons/alert.png" or msg.read and "icons/message_read.png" or "icons/message_unread.png"
		local icon = g.image.new(icon_path, {mipmap=true, w = math.floor(bar.h / 2 + .5), h = math.floor(bar.h / 2 + .5), x = read_rect.x + read_rect.w + g.skin.img_margin, y = math.floor(bar.h / 4 + .5) })
		icon.color, icon.alpha = bar.label_color, msg.read and g.skin.bars.alpha or 255
		local title = { text = msg.title, x = icon.x + icon.w + g.skin.img_margin, y = g.skin.bars.ty, font = g.skin.bars.font[msg.urgent and 1 or msg.read and 2 or 1], alpha = msg.urgent and 255 or msg.read and g.skin.bars.alpha or 255 }
		local from = { text = msg.from, y = g.skin.bars.ty, font = g.skin.bars.font[2], alpha = title.alpha }
		from.x = bar.w - g.skin.margin - g.font.width(from.text, from.font)
		--
		bar.rects = { read_rect }
		bar.labels = { title, from }
		bar.images = { icon }
		--
		local btn = g.ui.button.new("", { x = bar.x, y = bar.y, w = bar.w, h = bar.h, visible = false })
		btn.on_release = function(b)
			self:open_message(msg)
		end
		--
		table.insert(self.buttons, btn)
		table.insert(self.bars, bar)
	end
	-- Show_message
	if self.show_message then
		local msg = self.show_message
		local bar = { x = self.panel2.x + g.skin.margin, y = self.panel2.y + g.skin.margin, w = self.panel2.w - g.skin.margin * 2, alpha = g.skin.bars.alpha }
		bar.color, bar.label_color = team.color3, g.skin.bars.color2
		local title = { text = msg.title, x = g.skin.margin, y = g.skin.margin, color = team.color2, font = {"bebas", 48} }
		bar.h = g.font.height(title.font) + g.skin.margin * 2
		local content = { text = msg.content, x = g.skin.margin, y = bar.h + g.skin.margin, w = bar.w - g.skin.margin * 2, align = "justify", font = {"bold", 14 } }
		--
		bar.labels = { title, content }
		--
		local btn = g.ui.button.new("Delete", { w = "auto", image = g.image.new("icons/delete.png", {mipmap=true, w = 16, h = 16, color = g.skin.black}) } )
		btn.x, btn.y = bar.x + bar.w - g.skin.margin - btn.w, bar.y + math.floor(bar.h/2 - btn.h/2 + .5)
		btn:set_colors(g.skin.red, g.skin.black, love.graphics.darken(g.skin.red))
		btn.on_release = function(b)
			g.message.delete(self.show_message)
			self.show_message = nil
			self:set()
		end
		--
		if not self.show_message.urgent then table.insert(self.buttons, btn) end
		table.insert(self.bars, bar)
	end
end

function game_inbox:open_message(message)
	if self.show_message == message then
		self.show_message = nil
	else
		message.read = true
		self.show_message = message
	end
	--
	self:set() -- Doesn't do the tweening and stuff again, just resets instantly
end

function game_inbox:keypressed(k, ir)
	if g.ribbon.searchbox.focus then return end
	if k == "delete" then
		if self.show_message and self.show_message.urgent==false then
			g.message.delete(self.show_message)
			self.show_message = nil
			self:set()
		end
	elseif self.show_message and (k=="up" or k=="down") then
		local index = g.message.get_index(self.show_message)
		if k == "up" then index = index - 1 elseif k == "down" then index = index + 1 end
		if index < 1 then index = 1 elseif index > #g.database.vars.inbox then index = #g.database.vars.inbox end
		self.show_message = g.database.vars.inbox[index]
		self:set()
	end
end

function game_inbox:mousepressed(x, y, b)
	for i = 1, #self.buttons do self.buttons[i]:mousepressed(x, y, b) end
end

function game_inbox:mousereleased(x, y, b)
	for i = 1, #self.buttons do self.buttons[i]:mousereleased(x, y, b) end
end

return game_inbox