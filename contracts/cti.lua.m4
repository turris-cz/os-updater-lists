include(utils.m4)dnl
_FEATURE_GUARD_

-- Enforce contract
Install("omnia-cti-support", { priority = 60 })

-- Extra security
Install('common_passwords')

-- Data collection
Install('sentinel-i_agree_with_eula')

options = {
    ["dynfw"] = true,
    ["haas"] = true,
    ["survey"] = true,
    ["fwlogs"] = true,
    ["minipot"] = true,
}
Export("options")
Script("../pkglists/datacollect.lua")
Unexport("options")


-- Contracted routers have in boot environment set contract variable that is used
-- in boot arguments. This variable should be preserved but due to bug in rescue
-- could have been corrupted on factory reset. Those fixes should recover it and
-- update the rescue system so it wouldn't get corrupted again.
-- We request reboot as contract is applied only after reboot.
if root_dir == "/" and version_match(os_release.VERSION, "<5.2.3") then
	Install("fix-corrupted-contract-by-rescue", "fix-nor-update")
	Package("fix-corrupted-contract-by-rescue", { reboot = "delayed", replan = "finished" })
	Package("fix-nor-update", { replan = "finished" })
end


_END_FEATURE_GUARD_
