-- Packages extensions and integrations with other with indirect dependencies
include(utils.m4)dnl

_FEATURE_GUARD_

-- Reload of OpenVPN on network restart to ensure fast reconnect
Install("openvpn-hotplug", { priority = 30, condition = "openvpn" })

-- Install emulated atsha204 when we are running in the container
if container then
	Install("libatsha204-emul", { priority = 30, condition = "libatsha204" })
end


_END_FEATURE_GUARD_
