include(utils.m4)dnl
_FEATURE_GUARD_

local luci_apps = {
	"acl",
	"acme",
	"adblock",
	"advanced-reboot",
	"ahcp",
	"aria2",
	"attendedsysupgrade",
	"banip",
	"base",
	"bcp38",
	"bmx7",
	"clamav",
	"commands",
	"cshark",
	"dcwapd",
	"ddns",
	"diag-core",
	"dnscrypt-proxy",
	"dockerman",
	"dump1090",
	"dynapoint",
	"eoip",
	"firewall",
	"frpc",
	"frps",
	"fwknopd",
	"hd-idle",
	"https-dns-proxy",
	"ksmbd",
	"lxc",
	"minidlna",
	"mjpg-streamer",
	"mwan3",
	"nextdns",
	"nft-qos",
	"nlbwmon",
	"ntpc",
	"nut",
	"ocserv",
	"olsr",
	"omcproxy",
	"openvpn",
	"opkg",
	"p910nd",
	"pagekitec",
	"polipo",
	"privoxy",
	"qos",
	"radicale",
	"radicale2",
	"rp-pppoe-server",
	"samba4",
	"ser2net",
	"shadowsocks-libev",
	"shairplay",
	"simple-adblock",
	"smartdns",
	"splash",
	"sqm",
	"squid",
	"statistics",
	"tinyproxy",
	"transmission",
	"travelmate",
	"ttyd",
	"udpxy",
	"uhttpd",
	"unbound",
	"upnp",
	"vnstat",
	"vnstat2",
	"vpnbypass",
	"vpn-policy-routing",
	"watchcat",
	"wifischedule",
	"wireguard",
	"wol",
	"xinetd",
	"yggdrasil",
}


Install("luci", "luci-base", { priority = 40 })
Install("luci-i18n-base-en", { optional = true, priority = 10 })

Install("luci-mod-dashboard", { priority = 40 })

Install("luci-app-commands", { priority = 40 })
Install("luci-proto-ipv6", "luci-proto-ppp", { priority = 40 })
-- Install resolver-debug for DNS debuging
Install("resolver-debug", { priority = 40 })

-- Conditional install requests for language packages
for _, lang in pairs({"en", unpack(l10n or {})}) do
	for _, name in pairs(luci_apps) do
		Install("luci-i18n-" .. name .. "-" .. lang, {
			priority = 10,
			optional = true,
			condition = "luci-app-" .. name
		})
	end
	Install("luci-i18n-base-" .. lang, {
		priority = 10,
		optional = true,
		condition = "luci-base"
	})
end

_END_FEATURE_GUARD_
