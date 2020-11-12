local arg = arg
local print = print
local pairs = pairs
local xpcall = xpcall
local debug = debug
local tostring = tostring
local tonumber = tonumber
local argparse = require "argparse"

module "common"
-- luacheck: globals main boards

-- All boards to run tests for
boards =  {
	"mox", "omnia", "turris1x"
}

function parser(updater_version)
	local parser = argparse(arg[0]:gsub("^.*/", ""),
		"Updater runtime environment for version " .. updater_version)
	parser:argument("entry", "Entry point.")
		:args("*")
	return parser
end


function main(parser, run_test)
	local args = parser:parse()
	local ok = true
	for _, entry in pairs(args.entry) do
		for _, board in pairs(boards) do
			print("Running board[" .. board .. "] entry[" .. entry .. "]")
			ok = xpcall(function()
				run_test(args, board, entry)
			end, function(err)
				print(debug.traceback(err, 3))
			end) and ok
		end
	end
	if ok then return 0 else return 1 end
end


return _M
