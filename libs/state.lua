local s = {}
local function __NULL__() end

local _states = {}
local _states_z = {}

local function remove_from_table(t, item)
	for i=1,#t do
		if t[i]==item then
			return table.remove(t,i)
		end
	end
end

local function sort_z()
	table.sort(_states_z, function(a,b) return a.__z < b.__z end)
end

function s.add(state, ...)
	if state.init then state.init(state) end
	state.init = nil
	_states[#_states+1] = state
	_states_z[#_states_z+1] = state
	-- Sort the z table
	sort_z()
	return (state.added or __NULL__)(state, ...)
end

function s.remove(state)
	remove_from_table(_states, state)
	remove_from_table(_states_z, state)
	return (state.removed or __NULL__)(state)
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
	if #_states==0 then return end
	local state = s.active()
	remove_from_table(_states, state)
	remove_from_table(_states_z, state)
	return (state.removed or __NULL__)(state)
end

function s.active()
	return _states[#_states]
end

function s.active_z()
	return _states_z[#_states_z]
end

function s.length()
	return #_states
end

function s.get_state(i)
	return _states[i]
end

function s.get_state_z(i)
	return _states_z[i]
end

function s.z_order()
	print("Draw (z) Order")
	for i=1,#_states_z do
		print(i, _states_z[i].name)
	end
end

function s.order()
	print("Standard State Order")
	for i=1,#_states do
		print(i, _states[i].name)
	end
end

-- Iteration functions

local function iterator(t, i)
	i = i + 1
	local v = t[i]
	if v~=nil then return i, v else return nil end
end

function s.states()
	return iterator, _states, 0
end

function s.states_z(t)
	return iterator, _states_z, 0
end

--

return s