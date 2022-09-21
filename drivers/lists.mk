DRIVERS += \
	pci \
	sdio \
	usb


LISTS += $(patsubst %,drivers/%,$(DRIVERS))
