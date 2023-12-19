include(utils.m4)dnl
_FEATURE_GUARD_

-- Install firmware-updater
Install("firmware-updater", { priority = 40 })

-- Install dependencies
if not options or options.nor ~= false then
	Install("turris-nor-update", { priority = 40 })
end
if options and options.mcu == true then
	Install("omnia-mcutool", { priority = 40 })
	Install("omnia-mcu-firmware", { priority = 40 })
end
if not options or options.factory ~= false then
	Install("schnapps", { priority = 40 })
end

_END_FEATURE_GUARD_
