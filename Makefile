MAKEFLAGS += --no-builtin-rules

# This variable can be overwritten to show executed commands
Q ?= @

# Default output path. This is used when output (writable) directory is different
# than project directory. You shouldn't be setting it by hand, but it is used in
# external Makefiles.
O ?= .

# Tools
LUACHECK ?= luacheck

# Load configuration
-include $(O)/.config.mk

# Include LISTS
include lists.mk
LISTS_LUA := $(patsubst %,$(DESTDIR)/%.lua,$(LISTS))
DRIVERS_LUA := $(filter %/drivers/%.lua,$(LISTS_LUA))
PKGLISTS_LUA := $(filter %/pkglists/%.lua,$(LISTS_LUA))
CONTRACTS_LUA := $(filter %/contracts/%.lua,$(LISTS_LUA))

.PHONY: all
all: $(LISTS_LUA)


.PHONY:
help:
	@echo "Turris updater's lists make targets:"
	@echo " all         - Build all lists"
	@echo " help        - Prints this text help"
	@echo " clean       - Cleans builded files"
	@echo " distclean   - Same as clean but also removes configuration"
	@echo " check       - Executes all tests"
	@echo " lint        - Executes all code linters"
	@echo "Some enviroment variables to be defined:"
	@echo " Q           - Define emty to show executed commands"


.PHONY: clean
clean::
	@echo " CLEAN build"
	$(Q)$(RM) -r $(LISTS_LUA)

.PHONY: distclean
distclean:: clean
	@echo " CLEAN configuration"
	$(Q)$(RM) $(O)/.config.mk


$(DESTDIR)/base-min.lua: kmod.list kmod-mox.list kmod-omnia.list kmod-turris1x.list

$(DESTDIR)/%.lua: %.lua.m4 utils.m4
	@echo " M4    $@"
	@mkdir -p "$(@D)"
	$(Q)m4 \
		-D_TURRIS_OS_VERSION_="$(TOS_VERSION)" \
		-D_FEEDS_="$(FEEDS)" \
		"$<" > "$@" || (rm "$@"; exit 1)

$(DESTDIR)/%.lua: %.lua
	@echo " CP    $@"
	@mkdir -p "$(@D)"
	$(Q)cp "$<" "$@"


$(O)/.config.mk:
	$(error Please run configure script first)


include tests/tests.mk
