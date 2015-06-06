local game_financial = {}
game_financial.name = "Game Financial"

function game_financial:init()
	self.__z = 1
	--
	g.console:log("game_financial:init")
end

function game_financial:added()
	local x, y, w, h = g.skin.screen.x + g.skin.margin, g.skin.screen.y + g.skin.margin, g.skin.screen.w - g.skin.margin * 2, g.skin.screen.h - g.skin.margin * 2
	local half_w = math.floor((w-g.skin.margin)/2+.5)
	self.panel = g.ui.panel.new(g.skin.screen.x + g.skin.margin, g.skin.screen.y + g.skin.margin, g.skin.screen.w - g.skin.margin * 2, g.skin.screen.h - g.skin.margin * 2)
	self.panel:set_colors(g.skin.components.color1, g.skin.components.color3)
	--
	g.tween_alpha()
	self:set()
end

function game_financial:update(dt)

end

function game_financial:draw()
	self.panel:draw()
	--
	for i = 1, #self.labels do
		local label = self.labels[i]
		g.font.set(label.font)
		love.graphics.setColorAlpha(label.color, label.alpha or 255)
		if label.align then love.graphics.printf(label.text, label.x, label.y, label.w, label.align) else love.graphics.print(label.text, label.x, label.y) end
	end
end

function game_financial:set()
	local x, y, w, h = g.skin.screen.x, g.skin.screen.y, g.skin.screen.w, g.skin.screen.h
	--
	local cash_color = g.database.vars.finance.cash < 0 and g.skin.red or g.skin.white
	local cash_txt = g.format_currency(g.database.vars.finance.cash)
	local cash_title = { text = "Current Available Balance", x = x + g.skin.margin, y = y + g.skin.margin, w = w - g.skin.margin * 2, align = "center", color = g.skin.white, font = { "bebas", 48 }}
	cash_title.h = g.font.height(cash_title.font)
	local cash = { text = cash_txt, x = x + g.skin.margin, y = cash_title.y + cash_title.h, w = w - g.skin.margin * 2, align = "center", color = cash_color, font = {"bebas", 96 } }
	cash.h = g.font.height(cash.font)
	--
	local income = { text = "Revenue (per week)", x = x + g.skin.tab, y = cash.y + cash.h, w = w / 2 - g.skin.tab, align = "left", color = g.skin.green, font = { "bebas", 48 } }
	local expenses = { text = "Expenses (per week)", x = x + g.skin.tab + income.w, y = income.y, w = w / 2 - g.skin.tab, align = "left", color = g.skin.red, font = { "bebas", 48 } }
	income.h, expenses.h = g.font.height(income.font), g.font.height(expenses.font)
	--
	local wage_txt = g.format_currency(g.players.total_wage_bill(g.database.vars.players))
	local wage = { text = "Wages = " .. wage_txt, x = expenses.x, y = expenses.y + expenses.h, w = expenses.w, align = "left", color = g.skin.red, font = { "bebas", 24 } }
	self.labels = { cash_title, cash, income, expenses, wage }
	--
	g.ribbon:set_game("Financial Overview")
end

function game_financial:keypressed(k, ir)
	if g.ribbon.searchbox.focus then return end
end

function game_financial:mousepressed(x, y, b)

end

function game_financial:mousereleased(x, y, b)

end

return game_financial