include(utils.m4)dnl
_FEATURE_GUARD_

-- Install Knot Resolver 6
Install("knot-resolver6", { priority = 42 })

-- Uninstall old Knot Resolver
Uninstall("knot-resolver", { priority = 42 })

_END_FEATURE_GUARD_
