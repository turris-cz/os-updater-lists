include(utils.m4)dnl

Install('updater-ng', 'updater-supervisor', { critical = true })
Package('updater-ng', { replan = 'finished' })


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
