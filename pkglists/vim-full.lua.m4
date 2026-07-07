include(utils.m4)dnl
_FEATURE_GUARD_

-- Vim-full install
Install("vim-full", { priority = 42 })

-- Uninstall Vim
Uninstall("vim", { priority = 42 })

_END_FEATURE_GUARD_
