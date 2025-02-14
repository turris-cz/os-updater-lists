include(utils.m4)dnl
_FEATURE_GUARD_

-- Our own version of for_l10n to override priority and use condition
local function for_l10n(package)
	for _, lang in pairs(l10n or {}) do
		Install(package .. "-l10n-" .. lang, {
			optional = true,
			priority = 10,
			condition = {package, "l10n-supported"}
		})
	end
end


-- reForis
for_l10n("reforis")
for_l10n("reforis-data-collection-plugin")
for_l10n("reforis-haas-plugin")
for_l10n("reforis-diagnostics-plugin")
for_l10n("reforis-netboot-plugin")
for_l10n("reforis-librespeed-plugin")
for_l10n("reforis-openvpn-plugin")
for_l10n("reforis-remote-access-plugin")
for_l10n("reforis-remote-devices-plugin")
for_l10n("reforis-remote-wifi-settings-plugin")
for_l10n("reforis-snapshots-plugin")

-- Package lists
for_l10n('pkglists')

-- User-notify
for_l10n("user-notify")

-- Diagnostics
for_l10n("turris-diagnostics")


_END_FEATURE_GUARD_
