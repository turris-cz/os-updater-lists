include(utils.m4)dnl
_FEATURE_GUARD_

-- Install Omnia 5G Kit supporting package
Install("omnia-5g-kit", { priority = 42 })

-- Uninstall ModemManager as mode is not supported yet
Uninstall("modem-manager-autosetup", "modem-manager", { priority = 42 })

_END_FEATURE_GUARD_
