--[[
Various utility functions for fake updater implementations.
]]
local type = type
local pairs = pairs

module "utils"
-- luacheck: globals map set2arr arr2set merge

--[[
Run a function for each key and value in the table.
The function shall return new key and value (may be
the same and may be modified). A new table with
the results is returned.
]]
function map(table, fun)
	local result = {}
	for k, v in pairs(table) do
		local nk, nv = fun(k, v)
		result[nk] = nv
	end
	return result
end

-- Convert a set to an array
function set2arr(set)
	local idx = 0
	return map(set, function (key)
		idx = idx + 1
		return idx, key
	end)
end

function arr2set(arr)
	return map(arr, function (_, name) return name, true end)
end

-- Add all elements of src to dest
function merge(dest, src)
	for k, v in pairs(src) do
		dest[k] = v
	end
end

--[[
Make a deep copy of passed data. This does not work on userdata, on functions
(which might have some local upvalues) and metatables (it doesn't fail, it just
doesn't copy them and uses the original).
]]
function clone(data)
	local cloned = {}
	local function clone_internal(data)
		if cloned[data] ~= nil then
			return cloned[data]
		elseif type(data) == "table" then
			local result = {}
			cloned[data] = result
			for k, v in pairs(data) do
				result[clone_internal(k)] = clone_internal(v)
			end
			return result
		else
			return data
		end
	end
	return clone_internal(data)
end

-- Make a shallow copy of passed data structure. Same limitations as with clone.
function shallow_copy(data)
	if type(data) == 'table' then
		local result = {}
		for k, v in pairs(data) do
			result[k] = v
		end
		return result
	else
		return data
	end
end

return _M
