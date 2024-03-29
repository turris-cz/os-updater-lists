include(utils.m4)dnl
_FEATURE_GUARD_

-- netmetr was an old speed measuring service, since Turris OS 6.3.0 we are using
-- librespeed instead
if options and (options.librespeed or (options.netmetr and board ~= "turris1x")) then
	Install("librespeed-cli", { priority = 40 })
end

if options and options.dev_detect then
	Install("dev-detect", { priority = 40 })
end

if options and options.pakon then
	Install("pakon", { priority = 40 })
end

if options and options.morce then
	Install("morce", { priority = 40 })
end

_END_FEATURE_GUARD_
