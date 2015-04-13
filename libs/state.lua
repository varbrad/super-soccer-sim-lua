local s = {}
local function __NULL__() end

local states = {}

function s.add(state, ...)
	if state.init then state.init(state) end
	state.init = nil
	states[#states+1] = state
	return (state.added or __NULL__)(state, ...)
end

function s.remove(state)
	for i=1,#states do
		if states[i]==state then
			table.remove(states, i)
			return (state.removed or __NULL__)(state)
		end
	end
end

function s.switch(state, ...)
	s.pop()
	s.add(state, ...)
end

function s.refresh(...)
	-- Refreshes the active state
	local state = s.active()
	return (state.added or __NULL__)(state, ...)
end

function s.pop()
	local state = s.active()
	table.remove(states,#states)
	return (state.removed or __NULL__)(state)
end

function s.active()
	return states[#states]
end

function s.length()
	return #states
end

return s