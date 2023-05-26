include(utils.m4)dnl
_FEATURE_GUARD_

-- XG
Install("ppp-mod-pppoe", "pptpd", { priority = 40 })
Install("usb-modeswitch", { priority = 40 })

-- Generic daemon to handle 3/4/5g
Install("modemmanager", {priority = 40 })

-- Luci
Install("luci-proto-3g", "luci-proto-qmi", "luci-proto-modemmanager", { priority = 40 })

_END_FEATURE_GUARD_
