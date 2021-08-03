include(utils.m4)dnl

Install('updater-ng', 'updater-supervisor', { critical = true })
if features.request_condition then
	-- This corresponds to FEATURE_GUARD. We would skip a lot of requests and thus
	-- we would remove a lot of packages before update without this.
	Package('updater-ng', { replan = 'finished' })
else
	Package("updater-ng", { replan = "immediate" })
end

_FEATURE_GUARD_

Install("updater-drivers", { priority = 40 })
Install("updater-opkg-wrapper", { priority = 40 })
Install('switch-branch', { priority = 40 })

Package('updater-drivers', { replan = 'finished' })
Package('l10n-supported', { replan = 'finished' })
Package('updater-opkg-wrapper', { replan = 'finished' })
Package('localrepo', { replan = 'finished' })
Package('switch-branch', { replan = 'finished' })

_END_FEATURE_GUARD_
