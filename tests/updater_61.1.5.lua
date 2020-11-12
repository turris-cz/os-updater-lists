#!/usr/bin/env lua5.1
package.path = package.path .. ";" .. arg[0]:gsub("[^/]*%.lua$", "?.lua")
local _G = _G
local common = require "common"
local utils = require "utils"
local tools = require "tools"

-- This is updater version used in Turris OS 3.11.19. That is one of the last
-- Turris OS 3.x releases and is used in migration to newer version.
local updater_version = "61.1.5"
local tos3x_version = "3.11.19.1"

----------------------------------------------------------------------------------
local model_board = {
	["omnia"] = {"Turris Omnia", "marvell,armada385"},
	["turris1x"] = {"Turris", "fsl,P2020RDB"}
}

local board_architectures = {
	["omnia"] = {"all", "mvebu/generic"},
	["turris1x"] = {"all", "mpc85xx/p2020-nand"}
}

----------------------------------------------------------------------------------
-- These are tables with all available functions and variables in remote security
-- We implement only remote security as these are remote scripts and should be
-- always run with remote security level.
-- Note: We do not provide otherwise standard uci as we kind of emulate bootstrap
local env = {}
local wrap_env = {}

local function run_sandboxed(path, parent)
	parent = parent or {}
	local context = utils.shallow_copy(parent)
	context.path = path
	context.exported = utils.shallow_copy(parent.exported or {})
	context.env = {}
	utils.merge(context.env, utils.clone(parent.exported or {}))
	utils.merge(context.env, utils.clone(env))
	utils.merge(context.env, utils.map(wrap_env, function(name, func)
			return name, function(...) return func(context, ...) end
		end))
	context.env._G = context.env

	local func, err = loadfile(path)
	if func then
		setfenv(func, context.env)()
	else
		error(err)
	end
end

-- Note: functions in updater sometimes in reality support some variation in
-- input. That is not supported the way we implement them here. Variations are
-- allowed for backward compatibility but lists should be always the top quality
-- and should not use obsolete features so they are considered here as errors.

local function table_of_types(d, tp)
	local res = true
	if type(d) == "table" then
		for _, v in pairs(d) do
			res = res and type(v) == tp
		end
	else
		res = res and type(d) == tp
	end
	return res
end

local function verify_deps(deps)
	if type(deps) == "table" then
		if deps.tp then
			assert(deps.tp == "dep-and" or deps.tp == "dep-or" or deps.tp == "dep-not")
			verify_deps(deps.sub)
		else
			for _, dep in pairs(deps) do
				verify_deps(dep)
			end
		end
	else
		assert(type(deps) == "string")
	end
end

function Package(context, pkg_name, extra)
	assert(type(pkg_name) == "string")
	for name, value in pairs(extra or {}) do
		assert(type(name) == "string")
		if name == "virtual" then
			assert(value)
		elseif name == "deps" then
			verify_deps(value)
		elseif name == "reboot" then
			local valid = utils.arr2set({"delayed", "finished"})
			assert(valid[value])
		elseif name == "replan" then
			local valid = utils.arr2set({"finished", "immediate"})
			assert(valid[value])
		elseif name == "abi_change" or name == "abi_change_deep" then
			if type(value) == "table" then
				assert(table_of_types(value, "string"))
			else
				assert(value == true)
			end
		else
			error("Unknown extra argument: " .. name)
		end
	end
end

function Repository(context, name, repo_uri, extra)
	assert(type(name) == "string")
	assert(type(repo_uri) == "string")
	for ename, value in pairs(extra or {}) do
		assert(type(ename) == "string")
		if ename == "priority" then
			assert(type(value) == "number")
			assert(value >= 0 and value <= 100)
		elseif ename == "subdirs" then
			assert(type(value) == "table")
			for _, dir in pairs(value) do
				assert(type(dir) == "string")
			end
		else
			error("Invalid Repository extra argument: " .. ename)
		end
	end
end

function Install(context, ...)
	for _, arg in pairs({...}) do
		if type(arg) == "table" then
			-- Table with extra options
			for name, value in pairs(arg) do
				assert(type(name) == "string")
				if name == "priority" then
					assert(type(value) == "number")
					assert(value >= 0 and value <= 100)
				elseif name == "version" then
					assert(type(value) == "string")
				elseif name == "repository" then
					assert(table_of_types(value, "string"))
				elseif name == "reinstall" or name == "critical" or name == "optional" then
					assert(value == true)
				else
					error("Unknown Install extra argument: " .. name)
				end
			end
		else
			assert(type(arg) == "string")
		end
	end
end

function Uninstall(context, ...)
	for _, arg in pairs({...}) do
		if type(arg) == "table" then
			-- Table with extra options
			for name, value in pairs(arg) do
				assert(type(name) == "string")
				if name == "priority" then
					assert(type(value) == "number")
					assert(value >= 0 and value <= 100)
				else
					error("Unknown Uninstall extra argument: " .. name)
				end
			end
		else
			assert(type(arg) == "string")
		end
	end
end

function Script(context, script_uri, extra)
	assert(type(script_uri) == "string")
	-- We allow only relative URIs in lists at the moment.
	assert(script_uri:match("^[./]*[^/]+%.lua$"))
	-- There is no extra option that would make sense and be allowed in lists 
	assert(extra == nil or extra == {})
	local path = context.path:gsub("[^/]+.lua", "") .. script_uri
	run_sandboxed(path, context)
end

function Export(context, variable)
	assert(type(variable) == "string")
	context.exported[variable] = true
end

function Unexport(context, variable)
	assert(type(variable) == "string")
	context.exported[variable] = nil
end

for _, name in pairs({'And', 'Or', 'Not'}) do
	_G[name] = function (...)
		return {
			tp = "dep-" .. name:lower(),
			sub = {...}
		}
	end
end

for _, level in pairs({"DIE", "ERROR", "WARN", "INFO", "DBG", "TRACE"}) do
	_G[level] = function(msg)
		print(level .. ": " .. msg)
		if level == "DIE" then
			error("DIE called")
		end
	end
end

----------------------------------------------------------------------------------
utils.merge(env, {
	-- State variables
	root_dir = "/",
	turris_version = tos3x_version,
	self_version = updater_version,
	language_version = 1,
	features = utils.arr2set({
		'priorities',
		'provides',
		'conflicts',
		'abi_change',
		'abi_change_deep',
		'replan_string'
	}),
	model = nil, -- filled later
	board_name = nil, -- filed later
	architectures = nil, -- filled later
	installed = {},
	-- Utility functions and constants
	version_match = tools.version_match,
	version_cmp = tools.version_cmp,
	system_cas = "uri_system_cas",
	no_crl = "uri_no_crl",
})
for _, func in pairs({
			"table", "string", "math", "assert", "error", "ipairs", "next",
			"pairs", "pcall", "select", "tonumber", "tostring", "type", "unpack",
			"xpcall", "And", "Or", "Not", "DIE", "ERROR", "WARN", "INFO", "DBG",
			"TRACE",
		}) do
	assert(_G[func])
	env[func] = _G[func]
end

for _, func in pairs({
			"Package", "Repository", "Install", "Uninstall", "Script", "Export",
			"Unexport"
		}) do
	assert(_G[func])
	wrap_env[func] = _G[func]
end


----------------------------------------------------------------------------------
local function run_test(args, board, entry)
	env.model, env.board_name = unpack(model_board[board])
	env.architectures = board_architectures[board]

	run_sandboxed(entry)
end

-- Only supported boards in Turris OS 3.x are Omnia and 1.x
common.boards = {"omnia", "turris1x"}
os.exit(common.main(common.parser(updater_version), run_test))
