include(utils.m4)dnl
_FEATURE_GUARD_

if board ~= "turris1x" then
        Install("syncthing", { priority = 40 })
end

_END_FEATURE_GUARD_
