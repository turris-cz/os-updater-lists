include(utils.m4)dnl
_FEATURE_GUARD_

local luci_apps = {
	"acl",
	"acme",
	"adblock",
	"adblock-fast",
	"advanced-reboot",
	"antiblock",
	"apinger",
	"aria2",
	"attendedsysupgrade",
	"babeld",
	"banip",
	"base",
	"bcp38",
	"bmx7",
	"chrony",
	"clamav",
	"cloudflared",
	"commands",
	"coovachilli",
	"crowdsec-firewall-bouncer",
	"cshark",
	"dawn",
	"dcwapd",
	"ddns",
	"dockerman",
	"dump1090",
	"dynapoint",
	"email",
	"eoip",
	"example",
	"filebrowser",
	"filemanager",
	"firewall",
	"frpc",
	"frps",
	"fwknopd",
	"hd-idle",
	"https-dns-proxy",
	"irqbalance",
	"keepalived",
	"ksmbd",
	"ledtrig-rssi",
	"ledtrig-switch",
	"ledtrig-usbport",
	"libreswan",
	"lldpd",
	"lorawan-basicstation",
	"ltqtapi",
	"lxc",
	"minidlna",
	"mjpg-streamer",
	"mosquitto",
	"mwan3",
	"natmap",
	"nextdns",
	"nft-qos",
	"nlbwmon",
	"nut",
	"ocserv",
	"olsr",
	"olsr-services",
	"olsr-viz",
	"omcproxy",
	"openlist",
	"openvpn",
	"openwisp",
	"p910nd",
	"package-manager",
	"pagekitec",
	"pbr",
	"privoxy",
	"qos",
	"radicale",
	"radicale2",
	"rp-pppoe-server",
	"samba4",
	"ser2net",
	"siitwizard",
	"smartdns",
	"snmpd",
	"softether",
	"splash",
	"sqm",
	"squid",
	"sshtunnel",
	"statistics",
	"strongswan-swanctl",
	"tinyproxy",
	"tor",
	"transmission",
	"travelmate",
	"ttyd",
	"udpxy",
	"uhttpd",
	"unbound",
	"upnp",
	"usteer",
	"v2raya",
	"vnstat2",
	"watchcat",
	"wifischedule",
	"wol",
	"xfrpc",
	"xinetd",
}


Install("luci", "luci-base", { priority = 40 })
Install("luci-i18n-base-en", { optional = true, priority = 10 })

Install("luci-mod-dashboard", { priority = 40 })

Install("luci-app-commands", { priority = 40 })
Install("luci-proto-ipv6", "luci-proto-ppp", { priority = 40 })

-- Conditional install requests for language packages
for _, lang in pairs({unpack(l10n or {})}) do
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
