DRIVERS += \
	pci \
	sdio \
	usb \
	classes


LISTS += $(patsubst %,drivers/%,$(DRIVERS))
