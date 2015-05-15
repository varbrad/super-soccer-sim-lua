local msgbox = {}
msgbox.name = "MsgBox"
msgbox.active = false

function msgbox:init()
	self.__z = 7
	self.flux = g.flux:group()
	self.skin = g.skin.notification
	self.list = {}
	--
	g.console:log("notification:init")
end

function msgbox:added()

end

function msgbox:new(title, text, options)

end

return msgbox