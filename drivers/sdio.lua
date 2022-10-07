--[[
Following table is database of SDIO devices identifiers and drivers in OpenWrt to
support them. Feel free to expand it with additional devices.

Every device has to have numerical 'vendor' and 'device' identifier and list of
'packages' defined. Please also add comment with device name.
]]
local db = {
    { -- Marvell SDIO Wifi
        vendor = 0x02df,
        device = 0x9141,
    },
    { -- Marvell SDIO Bluetooth
        vendor = 0x02df,
        device = 0x9142,
    }
}

----------------------------------------------------------------------------------
if devices == nil then
	ERROR("Invalid usage of SDIO drivers, variable 'devices' is not defined.")
	return
end

for _, device in pairs(devices) do
	for _, dbdev in pairs(db) do
		if (type(device) == "string" and device == "all") or
				(type(device) == "table" and device.vendor == dbdev.vendor and device.device == dbdev.device) then
			if dbdev.packages ~= nil then
				for _, package in pairs(dbdev.packages) do
					Install(package, { priority = 40 })
				end
			end
		end
	end
end
