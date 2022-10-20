ENTRY_LISTS := \
	base-min base base-netboot \
	bootstrap \
	migrate3x \
	migrate5x
LISTS := \
	$(ENTRY_LISTS) \
	base-fix base-conditional repository \
	updater foris luci localization terminal-apps webapps \

include contracts/lists.mk
include drivers/lists.mk
include pkglists/lists.mk
