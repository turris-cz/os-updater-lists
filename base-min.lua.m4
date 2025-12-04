include(utils.m4)dnl
include(repository.m4)dnl

list_script('base-fix.lua')
list_script('base-conditional.lua')

-- Kernel
Package("kernel", { reboot = "delayed" })
Package("kmod-mac80211", { reboot = "delayed" })
forInstallCritical(kmod,file2args(kmod.list))
if board == "mox" then
	forInstallCritical(kmod,file2args(kmod-mox.list))
	Install("mox-support", { critical = true })
	Install("zram-swap", { priority = 40 })
elseif board == "omnia-ng" then
	forInstallCritical(kmod,file2args(kmod-omnia-ng.list))
	Install("omnia-ng-support", { critical = true })
	Install("peacockr", { priority = 40 })
	Install("turris-omnia-ng-wifi-firmware", { critical = true })
elseif board == "omnia" then
	forInstallCritical(kmod,file2args(kmod-omnia.list))
	Install("omnia-support", { critical = true })
elseif board == "turris1x" then
	forInstallCritical(kmod,file2args(kmod-turris1x.list))
	Install("turris1x-support", { critical = true })
end
Install("fstools", { critical = true })

-- Critical minimum
Install("base-files", "busybox", "procd", "ubus", "uci", { critical = true })
Install("netifd", "firewall4", "dns-resolver", { critical = true})

-- OpenWrt minimum
Install("ebtables", "dnsmasq-full", "odhcpd", "odhcp6c", { priority = 40 })
Install("urandom-seed", { priority = 40 })

-- OpenWrt package management
Install("opkg", "libustream-openssl", { priority = 40 })
Uninstall("wget-nossl", { priority = 40 }) -- opkg required SSL variant only

-- Turris minimum
Install("turris-defaults", { priority = 40 })
Install("cronie", { priority = 40 })
Install("syslog-ng", "logrotate", { priority = 40 })
Install("knot-resolver", { priority = 40 })
if board == "turris1x" then
	Install("unbound", "unbound-anchor", { priority = 40 })
	Install("turris1x-btrfs", { priority = 40 }) -- Currently only SD card root is supported
end

-- Certificates
Install("dnssec-rootkey", "cznic-repo-keys", { critical = true })
-- Note: We don't ensure safety of these CAs
Install("ca-certificates", { priority = 40 })

-- Network protocols
Install("ppp", "ppp-mod-pppoe", { priority = 40 })
Install("ds-lite", "6in4", "6rd", { priority = 40 })

_FEATURE_GUARD_

-- Network tools
Install("ip-full", "tc", "genl", "ip-bridge", "ss", "nstat", "devlink", "rdma", { priority = 40 })
Install("iputils-ping", "iputils-tracepath", { priority = 40 })
Install("nftables-json", "xtables-nft", "conntrack", { priority = 40 })
Install("bind-client", "bind-dig", { priority = 40 })
Install("umdns", { priority = 40 })

-- Admin utilities
Install("shadow", "shadow-utils", "uboot-envtools", "i2c-tools", { priority = 40 })
Install("openssh-server", "openssh-sftp-server", "openssh-moduli", { priority = 40 })
Uninstall("dropbear", { priority = 40 })
Install("pciutils", "usbutils", "lsof", "btrfs-progs", { priority = 40 })
Install("lm-sensors", { priority = 40 })
if board == "turris1x" or board == "omnia" then
	Install("haveged", { priority = 40 })
end

-- Turris utility
Install("turris-version", "start-indicator", { priority = 40 })
Install("turris-utils", "user-notify", "watchdog_adjust", { priority = 40 })
Install("turris-diagnostics", { priority = 40 })
Install("turris-diagnostics-web", { priority = 40 })
if board == "mox" then
	Install("mox-otp", { priority = 40 })
elseif board == "omnia" then
	Install("rainbow", { priority = 40 })
	Install("libatsha204", { priority = 40 })
elseif board == "turris1x" then
	Install("rainbow", { priority = 40 })
	Install("libatsha204", "update_mac", { priority = 40 })
end
if board ~= "turris1x" then
	Install("schnapps", { priority = 40 })
	Install("turris-snapshots-web", { priority = 40 })
end


-- Wifi
Install("hostapd-common", "wireless-tools", "wpad-openssl", "iw", "iwinfo", { priority = 40 })
if board == "mox" then
	Install("kmod-ath10k-ct", { priority = 40 })
	Install("mwifiex-sdio-firmware", "ath10k-firmware-qca988x-ct", { priority = 40 })
elseif board ~= "omnia-ng" then
	Install("ath10k-firmware-qca988x", { priority = 40 })
end


-- Install timezone information (required for local time to work)
for _, zone in pairs({
		"core", "atlantic", "asia", "africa", "australia-nz", "europe",
		"northamerica", "india", "pacific", "poles", "simple", "southamerica"
}) do
	Install("zoneinfo-" .. zone, { priority = 40 })
end

_END_FEATURE_GUARD_
