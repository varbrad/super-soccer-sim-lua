local button = {}

local list = {}

function button.new(x, y, w, h, on_hover, on_out, on_click)
	local b = {}
	b.x, b.y = math.floor(x+.5) or 0, math.floor(y+.5) or 0
	b.w, b.h = math.floor(w+.5) or 1, math.floor(h+.5) or 1
	b.on_hover = on_hover or nil
	b.on_out = on_out or nil
	b.on_click = on_click or nil
	--
	b.__hover = false
	list[#list+1] = b
	return b
end

function button.remove(button)
	for i=1,#list do
		if list[i]==button then
			return table.remove(list, i)
		end
	end
end

function button.update(mx, my)
	for i=1, #list do
		local button = list[i]
		if not button.__hover and mx >= button.x and my >= button.y and mx < button.x + button.w and my < button.y + button.h then
			button.__hover = true
			if button.on_hover then button.on_hover(button) end
		elseif button.__hover and (mx < button.x or my < button.y or mx >= button.x + button.w or my >= button.y + button.h) then
			button.__hover = false
			if button.on_out then button.on_out(button) end
		end
	end
end

function button.mousepressed(x, y, b)
	if b~="l" then return end
	for i = 1, #list do
		local button = list[i]
		if button.__hover then
			if button.on_click then button.on_click(button); return end
		end
	end
end

return button