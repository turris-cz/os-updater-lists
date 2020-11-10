PKGLISTS += \
	3g \
	atlas \
	datacollect \
	drivers \
	dvb \
	hardening \
	luci_controls \
	lxc \
	nas \
	netboot \
	netdata \
	net_monitoring \
	nextcloud \
	openvpn \
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
