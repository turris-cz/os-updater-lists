include(utils.m4)dnl
_FEATURE_GUARD_

Install("lxc", { priority = 40 })
forInstall(lxc,attach,auto,console,copy,create,destroy,freeze,info,ls,monitor,monitord,snapshot,start,stop,unfreeze)

Install("luci-app-lxc", { priority = 40 })

Install("kmod-veth", { priority = 40 })
Install("getopt", "tar", "wget", { priority = 40 })

_END_FEATURE_GUARD_
