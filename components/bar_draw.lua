local bd = {}

function bd.draw(bar)
	love.graphics.setColorAlpha(bar.color, bar.alpha)
	love.graphics.rectangle("fill", bar.x, bar.y, bar.w, bar.h)
	if bar.rects then
		for i=1, #bar.rects do
			local rect = bar.rects[i]
			love.graphics.setColorAlpha(rect.color, rect.alpha or 255)
			if rect.rounded then
				love.graphics.roundrect("fill", bar.x + rect.x, bar.y + rect.y, rect.w, rect.h, rect.rounded)
			else
				love.graphics.rectangle("fill", bar.x + rect.x, bar.y + rect.y, rect.w, rect.h)
			end
		end
	end
	if bar.labels then
		for i=1, #bar.labels do
			local label = bar.labels[i]
			g.font.set(label.font)
			love.graphics.setColorAlpha(label.color, label.alpha or 255)
			if label.align then
				love.graphics.printf(label.text, bar.x + label.x, bar.y + label.y, label.w, label.align)
			else
				love.graphics.print(label.text, bar.x + label.x, bar.y + label.y)
			end
		end
	end
	if bar.images then
		love.graphics.setColor(255, 255, 255, 255)
		for i=1, #bar.images do
			bar.images[i]:draw(bar.x, bar.y)
		end
	end
end

return bd