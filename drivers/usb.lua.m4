--[[
Following table is database of USB devices identifiers and drivers in OpenWrt to
support them. Feel free to expand it with additional devices.

We do not essentially want to have here full list. It is not desirable to include
devices that are in main used as hotplug (such as USB flash stick) and devices
with generic driver (such as mass storage). It is rather desirable to have this as
list of devices such as modems, tunners and so on.

Every device has to have numberical 'vendor' and 'product' identifier and list of
'packages' defined. Please also comment with device name. There is also optional
'class' table. Those are used to enable selected subset of packages no matter if
the are present in device or not.

This expects variable 'devices' to be exported. It has to contain array. Elements
in array can be either string or table. String is considered as flag and any
device with matching flag is installed. Special flag is "all" that matches all
devices in database. Other option is table where keys are "vendor" and "product".
Values of those fields are compared with values in database and if they match then
appropriate packages are requested.
]]

include(utils.m4)dnl

local db = {
	-- Audio Adapters -----------------------------------------------------------
	{ -- C-Media Electronics, Inc. Audio Adapter
		vendor = 0x0d8c,
		product = 0x000c,
		packages = {"kmod-usb-audio"},
		class = {"audio"}
	},
	{ -- C-Media Electronics, Inc. CM106 Like Sound Device
		vendor = 0x0d8c,
		product = 0x0102,
		packages = {"kmod-usb-audio"},
		class = {"audio"}
	},
	-- DVB tunners ---------------------------------------------------------------
	{ -- TechnoTrend AG TT-connect CT-3650 CI
		vendor = 0x0b48,
		product = 0x300d,
		packages = {"kmod-dvb-usb-ttusb2", "kmod-dvb-tda10023", "kmod-dvb-tda10048", "kmod-media-tuner-tda827x"},
		class = {"dvb"}
	},
	{ -- TechniSat Digital GmbH CableStar Combo HD CI
		vendor = 0x14f7,
		product = 0x0003,
		packages = {"kmod-dvb-usb-ttusb2", "kmod-dvb-drxk", "kmod-dvb-usb-v2", "kmod-dvb-usb-az6007", "kmod-media-tuner-mt2063"},
		-- Note: additional not packaged firmware is required
		class = {"dvb"}
	},
	{ -- Computer & Entertainment, Inc. Astrometa DVB-T/T2/C FM & DAB receiver [RTL2832P]
		vendor = 0x15f4,
		product = 0x0131,
		packages = {"kmod-dvb-usb", "kmod-dvb-cxd2841er", "kmod-dvb-mn88473", "kmod-dvb-rtl2832", "kmod-dvb-usb-rtl28xxu", "kmod-media-tuner-r820t", "kmod-media-tuner-r820t"},
		class = {"dvb"}
	},
	{ -- Microsoft Corporation Xbox One Digital TV Tuner
		vendor = 0x045e,
		product = 0x02d5,
		packages = {"kmod-dvb-mn88472", "kmod-media-tuner-tda18250", "kmod-dvb-usb-dib0700"},
		-- Note: additional not packaged firmware is required
		class = {"dvb"}
	},
	-- LTE modems ----------------------------------------------------------------
	{ -- Qualcomm, Inc. Acer Gobi 2000 Wireless Modem
		vendor = 0x05c6,
		product = 0x9215,
		packages = {"kmod-usb-net-qmi-wwan", "kmod-usb-serial-qualcomm"},
		class = {"gsm"}
	},
	{ -- Huawei Technologies Co., Ltd. K5150 LTE modem
		vendor = 0x12d1,
		product = 0x1f16,
		packages = {"comgt-ncm", "umbim", "kmod-usb-net-cdc-ether"},
		class = {"gsm"}
	},
	{ -- TCL Communication Ltd Alcatel OneTouch L850V / Telekom Speedstick LTE
		vendor = 0x1bbb,
		product = 0x0195,
		packages = {"kmod-usb-net-rndis"},
		class = {"gsm"}
	},
	{ -- Neoway N75-EA
		vendor = 0x2949,
		product = 0x8247,
		packages = {"kmod-usb-serial-option"},
		class = {"gsm"}
	},
	{ -- Quectel EP-06
		vendor = 0x2c7c,
		product = 0x0306,
		packages = {"kmod-usb-net-qmi-wwan", "kmod-usb-serial-option"},
		class = {"gsm"}
	},
	{ -- Sierra Wireless WP7606
		vendor = 0x1199,
		product = 0x68c0,
		packages = {"kmod-usb-net-qmi-wwan", "kmod-usb-serial-qualcomm"},
		class = {"gsm"}
	},
	{ -- Quectel RM500U-EA
		vendor = 0x2c7c,
		product = 0x0900,
		packages = {"kmod-usb-net-cdc-ncm", "kmod-usb-serial-option"},
		class = {"gsm"}
	},
	-- WiFi dongles --------------------------------------------------------------
	{ -- Realtek Semiconductor Corp. RTL8812AU 802.11a/b/g/n/ac 2T2R DB WLAN Adapter
		vendor = 0x0bda,
		product = 0x8812,
		packages = {"kmod-rtl8812au-ct"},
		class = {"wifi"}
	},
	{ -- Ralink Technology, Corp. RT2870/RT3070 Wireless Adapter
		vendor = 0x148f,
		product = 0x3070,
		packages = {"kmod-rt2800-usb"},
		class = {"wifi"}
	},
	{ -- NETGEAR, Inc. WN111(v2) RangeMax Next Wireless [Atheros AR9170+AR9101]
		vendor = 0x0846,
		product = 0x9001,
		packages = {"kmod-carl9170"},
		class = {"wifi"}
	},
	{ -- Mediatek Inc. 802.11ac WLAN [MT7612u emulating drivers CD-ROM]
		vendor = 0x0e8d,
		product = 0x2870,
		packages = {"kmod-mt76x02-usb", "kmod-usb-roles", "usb-modeswitch", "kmod-scsi-cdrom"},
		class = {"wifi"}
	},
	{ -- Mediatek Inc. 802.11ac WLAN [MT7612u, after mode switch]
		vendor = 0x0e8d,
		product = 0x7612,
		packages = {"kmod-mt76x02-usb", "kmod-usb-roles", "usb-modeswitch", "kmod-scsi-cdrom"},
		class = {"wifi"}
	},
	-- Z-Wave --------------------------------------------------------------------
	{ -- Sigma Designs, Inc. Aeotec Z-Stick Gen5 (ZW090) - UZB
		vendor = 0x0658,
		product = 0x0200,
		packages = {"kmod-usb-acm"},
		class = {"serial", "z-wave"}
	},
	-- Zigbee --------------------------------------------------------------------
	{ -- Silicon Labs CP210x UART Bridge
		vendor = 0x10c4,
		product = 0xea60,
		packages = {"kmod-usb-serial-cp210x"},
		class = {"serial", "zigbee"}
	},
	-- Bluetooth dongles--------------------------------------------------------
	{ -- Cambridge Silicon Radio, Ltd Bluetooth Dongle (HCI mode)
		vendor = 0x0a12,
		product = 0x0001,
		packages = {"kmod-bluetooth"},
		class = {"bluetooth"}
	},
	-- Ethernet adapters ---------------------------------------------------------
	{ -- D-Link, DUB-1312 Gigabit Ethernet Adapter
		vendor = 0x2001,
		product = 0x4a00,
		packages = {"kmod-usb-net-asix-ax88179"},
		class = {"ethernet"}
	},
	-- Serial --------------------------------------------------------------------
	{ -- Future Technology Devices International Limited, Bridge(I2C/SPI/UART/FIFO)
		vendor = 0x0403,
		product = 0x6015,
		packages = {"kmod-usb-acm"},
		class = {"serial"}
	},
	{ -- Future Technology Devices International, Ltd FT232 USB-Serial (UART) IC
		vendor = 0x0403,
		product = 0x6001,
		packages = {"kmod-usb-serial-ftdi"},
		class = {"serial"}
	},
	{ -- Prolific Technology, Inc., PL2303 Serial Port
		vendor = 0x067b,
		product = 0x2303,
		packages = {"kmod-usb-serial-pl2303"},
		class = {"serial"}
	},
	-- Random number generator ---------------------------------------------------
	{ -- OpenMoko, Inc. USBtrng hardware random number generator
		vendor = 0x1d50,
		product = 0x60c6,
		packages = {"kmod-chaoskey"},
		class = {"random"}
	},
}
----------------------------------------------------------------------------------
if devices == nil then
	ERROR("Invalid usage of USB drivers, variable 'devices' is not defined.")
	return
end

-- First convert class arrays to set
for _, dbdev in pairs(db) do
	local class_set = {}
	for _, cl in pairs(dbdev.class or {}) do
		class_set[cl] = true
	end
	dbdev.class = class_set
end

-- Now request packages for requested devices and collect a list of found classes
classes = {}
Export("classes")

for _, device in pairs(devices) do
	for _, dbdev in pairs(db) do
		-- Device can be either table of devices (with product and vendor) or string "all" or string describing class
		if (type(device) == "string" and (device == "all" or dbdev.class[device])) or
				(type(device) == "table" and device.vendor == dbdev.vendor and device.product == dbdev.product) then
			for _, package in pairs(dbdev.packages) do
				Install(package, { priority = 40 })
			end
			for cl, _ in pairs(dbdev.class) do
			    classes[cl] = true
            end
		end
	end
end

list_script("classes.lua")
