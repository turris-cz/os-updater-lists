--[[
Following table is database of device classes, as defined in usb.lua, pci.lua and
sdio.lua and software they require. The goal is to pull in the software needed for
devices to be of any use. Maybe even some autoconfiguration can be used in the future.

This expects variable 'classes' to be exported. It has to contain array. Keys are
the classes, that are present. Value is always set to 1.
]]

local db = {
	-- 3/4/5G modems
	{
		class = "gsm",
		packages = {
			"mwan3",
			"luci-app-mwan3",
			"modemmanager",
			"luci-proto-modemmanager",
			"modem-manager-autosetup",
			"pptpd"
		}
	},
	-- DVB tunners
	{
		class = "dvb",
		packages = { "tvheadend", "turris-webapps-tvheadend" }
	},
	-- Bluetooth
	{
		class = "bluetooth",
		packages = { "bluez-daemon", "bluez-utils" }
	}
}

for _, entry in pairs(db) do
	if classes then
		for class, _ in pairs(classes) do
			if class == entry.class then
				for _, package in pairs(entry.packages) do
					Install(package, { priority = 40 })
				end
			end
		end
	end
end
