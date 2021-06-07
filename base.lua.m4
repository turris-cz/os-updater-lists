include(utils.m4)dnl
include(repository.m4)dnl

list_script('updater.lua')
list_script('base-min.lua')

_FEATURE_GUARD_

list_script('luci.lua')
list_script('foris.lua')
list_script('terminal-apps.lua')
list_script('webapps.lua')


-- OpenWrt package management
Install("opkg", "libustream-openssl", { priority = 40 })
Uninstall("wget-nossl", { priority = 40 }) -- opkg required SSL variant only

-- IPv6
Install("ds-lite", "6in4", "6rd", "6to4", { priority = 40 })

_END_FEATURE_GUARD_
