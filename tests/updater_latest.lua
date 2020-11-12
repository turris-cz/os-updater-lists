#!/usr/bin/env lua5.1
package.path = package.path .. ";" .. arg[0]:gsub("[^/]*%.lua$", "?.lua")
local _G = _G
local common = require "common"
local utils = require "utils"
local tools = require "tools"

local updater_version = "68.0.0"
local tos_version = "99.0.0"

----------------------------------------------------------------------------------
local os_release = {
	["NAME"] = "TurrisOS",
	["VERSION"] = tos_version,
	["ID"] = "turrisos",
	["ID_LIKE"] = "lede openwrt",
	["PRETTY_NAME"] = "TurrisOS " .. tos_version,
	["VERSION_ID"] = tos_version,
	["HOME_URL"] = "https://www.turris.cz/",
	["BUG_URL"] = "https://gitlab.labs.nic.cz/groups/turris/-/issues/",
	["SUPPORT_URL"] = "https://www.turris.cz/support/",
	["BUILD_ID"] = "0000000",
	["OPENWRT_TAINTS"] = "busybox",
	["OPENWRT_DEVICE_MANUFACTURER"] = "CZ.NIC",
	["OPENWRT_DEVICE_MANUFACTURER_URL"] = "https://www.turris.cz/",
	["OPENWRT_RELEASE"] = "TurrisOS " .. tos_version .. " 0000000000000000000000000000000000000000"
}
local board_os_release = {
	["mox"] = {
		["OPENWRT_BOARD"] = "mvebu/cortexa53",
		["OPENWRT_ARCH"] = "aarch64_cortex-a53",
		["OPENWRT_DEVICE_PRODUCT"] = "Turris Mox",
		["OPENWRT_DEVICE_REVISION"] = "v0",

	},
	["omnia"] = {
		["OPENWRT_BOARD"] = "mvebu/cortexa9",
		["OPENWRT_ARCH"] = "arm_cortex-a9_vfpv3-d16",
		["OPENWRT_DEVICE_PRODUCT"] = "Turris Omnia",
		["OPENWRT_DEVICE_REVISION"] = "v0",
	},
	["turris1x"] = {
		["OPENWRT_BOARD"] = "mpc85xx/p2020",
		["OPENWRT_ARCH"] = "powerpc_8540",
		["OPENWRT_DEVICE_PRODUCT"] = "Turris 1.x",
		["OPENWRT_DEVICE_REVISION"] = "v0",
	}
}
local board_architectures = {
	["mox"] = {"all", "mvebu/cortexa53"},
	["omnia"] = {"all", "mvebu/cortexa9"},
	["turris1x"] = {"all", "mpc85xx/p2020"}
}

----------------------------------------------------------------------------------
-- These are tables with all available functions and variables in remote security
-- We implement only remote security as these are remote scripts and should be
-- always run with remote security level.
-- Note: We do not provide otherwise standard uci as we kind of emulate bootstrap
local env = {}
local wrap_env = {}

local function run_sandboxed(path, parent, modify_context)
	parent = parent or {}
	local context = utils.shallow_copy(parent)
	context.path = path
	context.exported = utils.shallow_copy(parent.exported or {})
	context.env = {}
	utils.merge(context.env, utils.map(parent.exported or {}, function(variable)
		return variable, utils.clone(parent.env[variable])
	end))
	utils.merge(context.env, utils.clone(env))
	utils.merge(context.env, utils.map(wrap_env, function(name, func)
		return name, function(...) return func(context, ...) end
	end))
	context.env._G = context.env
	if modify_context then
		modify_context(context)
	end

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
			-- Note: intentional prevention of immediate replan. If needed in
			-- future it can be added here.
			local valid = utils.arr2set({"finished"})
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
	-- At the moment no extra arguments are used. This can be expanded later on
	assert(extra == nil)
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
				elseif name == "condition" then
					verify_deps(value)
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
				elseif name == "condition" then
					verify_deps(value)
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
	assert(not script_uri:match("^[^:/]+://"))
	-- There is no extra option that would make sense and be allowed in lists 
	assert(extra == nil or extra == {})
	local path = context.path:gsub("[^/]+.lua", "") .. script_uri
	run_sandboxed(path, context)
end

function Mode(context, ...)
	local valid = utils.arr2set({
		"reinstall_all", "no_removal", "optional_installs"
	})
	for _, mode in pairs({...}) do
		assert(valid[mode])
	end
end

function Export(context, variable)
	assert(type(variable) == "string")
	context.exported[variable] = true
end

local function export_value(context, variable, value)
	context.env[variable] = value
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
	self_version = updater_version,
	language_version = 1,
	features = utils.arr2set({
		'priorities',
		'provides',
		'conflicts',
		'abi_change',
		'abi_change_deep',
		'replan_string',
		'relative_uri',
		'no_returns',
		'no_error_virtual',
		'request_condition'
	}),
	os_release = os_release,
	host_os_release = os_release, -- intentionally same object as os_release
	architectures = nil, -- filled later
	installed = {}, -- we could fake something but in general it is ok with not package installed
	-- Utility functions and constants
	version_match = tools.version_match,
	version_cmp = tools.version_cmp,
	system_cas = true,
	no_crl = false,
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
			"Package", "Repository", "Install", "Uninstall", "Script", "Mode",
			"Export", "Unexport"
		}) do
	assert(_G[func])
	wrap_env[func] = _G[func]
end


----------------------------------------------------------------------------------
local function run_test(args, board, entry)
	utils.merge(os_release, board_os_release[board])
	env.architectures = board_architectures[board]

	run_sandboxed(entry, nil, function(context)
		if args.turris or args.pkglist then
			-- entry.lua
			export_value(context, "l10n", {"cs"})
			export_value(context, "for_l10n", function(fragment)
				assert(type(fragment) == "string")
			end)
			-- turris.lua
			export_value(context, "board", board)
			if args.pkglist then
				-- pkglist.lua + board same as in turris.lua
				export_value(context, "options", {"all"})
			end
		end
	end)
end


local parser = common.parser(updater_version)
parser:mutex(
	parser:flag("--turris", "Includes environment as executed from entry script on router."),
	parser:flag("--pkglist", "Include pkglist and router environment.")
)
os.exit(common.main(parser, run_test))
