DRIVERS += \
	pci \
	usb


LISTS += $(patsubst %,drivers/%,$(DRIVERS))
