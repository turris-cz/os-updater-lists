include(utils.m4)dnl
_FEATURE_GUARD_

-- These are reForis plugins to be installed as extension for specific other package
local reforis_optional_plugins = {
	["data-collection"] = "sentinel-proxy",
	["haas"] = "haas-proxy",
	["diagnostics"] = "turris-diagnostics",
	["netboot"] = "turris-netboot-tools",
	["netmetr"] = "netmetr",
	["librespeed"] = "librespeed",
	["openvpn"] = "openvpn",
	["snapshots"] = "schnapps",
	["nextcloud"] = "nextcloud",
}

----------------------------------------------------------------------------------

Install("lighttpd-https-cert", { priority = 40 })
Install("reforis", "reforis-storage-plugin", { priority = 40 })

for plugin, condition in pairs(reforis_optional_plugins) do
	Install("reforis-" .. plugin .. "-plugin", {
		priority = 40,
		condition = condition
	})
end

_END_FEATURE_GUARD_
