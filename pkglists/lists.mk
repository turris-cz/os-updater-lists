PKGLISTS += \
	3g \
	5g-kit \
	atlas \
	datacollect \
	drivers \
	dvb \
	hardening \
	kresd6 \
	luci_controls \
	lxc \
	nas \
	netboot \
	netdata \
	net_monitoring \
	nextcloud \
	firmware_update \
	openvpn \
	syncthing \
	tor


# Following lists are obsolete and kept just for backward compatibility
PKGLISTS += \
	dev-detect \
	honeypot \
	luci-controls \
	netmetr \
	pakon \
	printserver \
	reforis


LISTS += $(patsubst %,pkglists/%,$(PKGLISTS))
