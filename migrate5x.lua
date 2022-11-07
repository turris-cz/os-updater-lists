-- Turris OS 5 was based on OpenWrt 19.07, Turris OS 6 is based on OpenWrt 21.02
-- and OpenWrt doesn't always use PROVIDES for old package names, so we have
-- to do it here.

Package("kcptun-c", { virtual=true, deps = "kcptun-client" })
Package("kcptun-s", { virtual=true, deps = "kcptun-server" })

Package("usbreset", { virtual=true, deps = "usbutils" })

Package("wireguard", { virtual=true, deps = { "kmod-wireguard", "wireguard-tools" }})
Package("ath10k-firmware-qca9887-ct-htt", { virtual=true, deps = { "ath10k-firmware-qca9887-ct-full-htt" }})
Package("ath10k-firmware-qca9888-ct-htt", { virtual=true, deps = { "ath10k-firmware-qca9888-ct-full-htt" }})
Package("foris", { virtual = true })

Package("kmod-bluetooth_6lowpan", { virtual=true, deps = { "kmod-bluetooth-6lowpan" }})
Package("kmod-ieee802154_6lowpan", { virtual=true, deps = { "kmod-ieee802154-6lowpan" }})
