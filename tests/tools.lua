--[[
These are common tool functions used in updater. They are not utility because they
provide more specific functionality. In updater they are placed in backend.
]]
local table = table
local tonumber = tonumber

module "tools"
-- luacheck: globals version_cmp version_match

--[[
Compare two version strings. Return -1, 0, 1 if the first version
is smaller, equal or larger respectively.
]]
function version_cmp(v1, v2)
	--[[
	Split the version strings to numerical and non-numerical parts.
	Then compare these segments lexicographically, using numerical
	comparison if both are numbers and string comparison if at least
	one of them isn't.

	This should produce expected results when comparing two version
	strings with the same schema (and when the schema is at least somehow
	sane).
	]]
	local function explode(v)
		local result = {}
		for d, D in v:gmatch("(%d*)(%D*)") do
			table.insert(result, d)
			table.insert(result, D)
		end
		return result
	end
	local e1 = explode(v1)
	local e2 = explode(v2)
	local idx = 1
	while true do
		if e1[idx] == nil and e2[idx] == nil then
			-- No more parts of versions in either one
			return 0
		end
		local p1 = e1[idx] or ""
		local p2 = e2[idx] or ""
		if p1 ~= p2 then
			-- They differ. Decide by this one.
			if p1:match('^%d+$') and p2:match('^%d+$') then
				if tonumber(p1) < tonumber(p2) then
					return -1
				else
					return 1
				end
			else
				if p1 < p2 then
					return -1
				else
					return 1
				end
			end
		end
		-- They are the same. Try next segment of the version.
		idx = idx + 1
	end
end

--[[
Checks if given version string matches given rule. Rule is the string in format
same as in case of dependency description (text in parenthesis).
]]
function version_match(v, r)
	-- We don't expect that version it self have space in it self, any space is removed.
	local wildmatch, cmp_str, vers = r:gsub('%s*$', ''):match('^%s*(~?)([<>=]*)%s*(.*)$')
	if wildmatch == '~' then
		return v:match(cmp_str .. vers) ~= nil
	elseif cmp_str == "" then -- If no compare was located than do plain compare
		return v == r
	else
		local cmp = version_cmp(vers, v)
		local ch
		if cmp == -1 then
			ch = '>'
		elseif cmp == 1 then
			ch = '<'
		else
			ch = '='
		end
		return cmp_str:find(ch, 1, true) ~= nil
	end
end

return _M
