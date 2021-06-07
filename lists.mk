ENTRY_LISTS := \
	base-min base base-netboot \
	bootstrap \
	migrate3x
LISTS := \
	$(ENTRY_LISTS) \
	base-fix base-conditional repository \
	updater foris luci terminal-apps webapps \

include contracts/lists.mk
include pkglists/lists.mk
